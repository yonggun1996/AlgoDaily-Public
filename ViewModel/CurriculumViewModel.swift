//
//  CurriculumViewModel.swift
//  AlgoDaily
//
//  Created by yonggun Park on 11/8/25.
//

import Foundation
import Combine
import RealmSwift
import UniformTypeIdentifiers
import AppKit


@MainActor
class CurriculumViewModel: ObservableObject {
    @Published var curricula: [Curriculum] = [] // 생성시 미리보기 문제들
    @Published var todayProblem: [Curriculum] = [] // 오늘의 문제만 필터링해서 보여줌
    @Published var previewCurricula: [Curriculum]? = nil // 파일/텍스트 변환 후 미리보기 (Alert 트리거용)
    @Published var errorMessage: String?
    @Published var isLoading = false
    @Published var selectedFile: JSONFile?
    
    private var realmManager = RealmManager.shared
    private var todayProblemToken: NotificationToken? // 오늘의 문제 데이터가 변경됨을 감지하는 token
    
    init() {
        observeTodayProblem()
    }
    
    deinit {
        todayProblemToken?.invalidate()
    }
    
    /// 오늘의 문제를 실시간으로 관찰
    private func observeTodayProblem() {
        do {
            let results = try realmManager.fetchTodayProblem()
            
            // 초기 데이터 로드
            self.todayProblem = Array(results)
            
            // 실시간 관찰 시작
            todayProblemToken = results.observe { [weak self] changes in
                guard let self = self else { return }
                
                switch changes {
                case .initial(let results):
                    // 초기 로드
                    self.todayProblem = Array(results)
                    print("오늘의 문제 초기로드")
                    
                case .update(let results, deletions: _, insertions: _, modifications: _):
                    // 데이터 변경 시 (추가, 삭제, 수정 모두 포함)
                    print("오늘의 문제 데이터 변경")
                    self.todayProblem = Array(results)
                    
                case .error(let error):
                    // 에러 발생 시
                    self.errorMessage = "데이터 관찰 중 오류 발생: \(error.localizedDescription)"
                    print("데이터 관찰 오류: \(error)")
                }
            }
        } catch {
            errorMessage = "오늘의 문제 관찰 실패 \(error.localizedDescription)"
            print("오늘의 문제 관찰 실패: \(error)")
        }
    }
    
    /// Curriculum 배열을 한 번에 저장
    /// - Parameter curricula: 저장할 Curriculum 배열
    func addCurricula(_ curricula: [Curriculum]) {
        guard !curricula.isEmpty else {
            errorMessage = "저장할 데이터가 없습니다."
            return
        }
        
        isLoading = true
        errorMessage = nil
        
        do {
            try realmManager.addCurricula(curricula)
            
            // 저장 성공 시 로컬 리스트에도 추가 (선택사항)
            self.curricula.append(contentsOf: curricula)
            
            errorMessage = nil
        } catch {
            errorMessage = "저장 실패: \(error.localizedDescription)"
            print("저장 실패: \(error)")
        }
        
        isLoading = false
    }
    
    // 오늘의 문제를 검색
    func fetchTodayProblem() {
        isLoading = true
        errorMessage = nil
        
        do {
            let result = try realmManager.fetchTodayProblem()
            print("오늘의 문제 탐색 : \(result)")
        } catch {
            errorMessage = "오늘의 문제 탐색 실패 \(error.localizedDescription)"
            print("오늘의 문제 탐색 실패: \(error)")
        }
        
        isLoading = false
    }
    
    // 문제 해결 기록(Complete 변경)
    func updateCompleteProblem(idx: Int) {
        isLoading = true
        errorMessage = nil
        
        do {
            try realmManager.updateCompleteProblem(idx: idx)
        } catch {
            errorMessage = "문제 해결여부 변경 실패 \(error.localizedDescription)"
            print("문제 해결여부 변경 실패: \(error)")
        }
    }
    
    // 텍스트 불러오기 검증
    // 검증 성공시 [Curriculum] 배열 반환
    func bulkAddFromText(text: String) -> [Curriculum]? {
        guard let data = text.data(using: .utf8) else {
            errorMessage = "유효하지 않은 json입니다."
            return nil
        }
        
        let decoder = JSONDecoder()
        do {
            let jsonProblems = try decoder.decode([ProblemDTO].self, from: data)
            
            // ⭐ 추가: 300개 초과 체크
            if jsonProblems.count > 300 {
                errorMessage = "문제는 최대 300개까지 추가할 수 있습니다. (현재: \(jsonProblems.count)개)"
                return nil
            }
            
            // RealmManager의 getNextIdx() 사용 (옵저버 패턴으로 자동 관리됨)
            var allCurricula: [Curriculum] = []
            var currentIdx = realmManager.getNextIdx()  // 첫 번째 idx 가져오기
            
            for problem in jsonProblems {
                let curricula = Curriculum.createAllReviewStages(
                    startIdx: currentIdx,
                    problemNo: problem.problemNo,
                    problemName: problem.problemName,
                    problemLink: problem.problemLink,
                    level: problem.level
                )
                allCurricula.append(contentsOf: curricula)
                currentIdx += 4  // 신규, 1차, 2차, 3차 = 4개 회차
            }
            
            guard !allCurricula.isEmpty else {
                errorMessage = "추가할 수 있는 문제가 없습니다."
                return nil
            }
            
            errorMessage = nil
            return allCurricula
            
            // 저장
//            addCurricula(allCurricula)
        } catch {
            errorMessage = "유효하지 않은 json입니다."
            return nil
        }
    }
    
    func handleFileDrop(_ providers: [NSItemProvider]) -> Bool {
        guard let provider = providers.first else { return false }
        
        provider.loadItem(forTypeIdentifier: "public.file-url", options: nil) { [weak self] item, error in
            if let error = error {
                print("파일 로드 에러: \(error.localizedDescription)")
                return
            }
            
            guard let data = item as? Data,
                  let url = URL(dataRepresentation: data, relativeTo: nil) else {
                return
            }
            
            // 메인 스레드에서 실행
            Task { @MainActor [weak self] in
                self?.loadJSONFile(from: url)
            }
        }
        return true
    }
    
    // 파일 선택하기 버튼 클릭 시 호출되는 함수
    func selectFile() {
        let panel = NSOpenPanel()
        panel.allowsMultipleSelection = false
        panel.canChooseDirectories = false
        panel.canChooseFiles = true
        panel.allowedContentTypes = [UTType.json]
        
        panel.begin { [weak self] response in
            guard let self = self, response == .OK, let url = panel.url else { return }
            self.loadJSONFile(from: url)
        }
    }
    
    // 파일을 다시 json으로 convert하고 자동으로 변환하는 함수
    func loadJSONFile(from url: URL) {
        do {
            let data = try Data(contentsOf: url)
            let json = try JSONSerialization.jsonObject(with: data)
            let prettyData = try JSONSerialization.data(withJSONObject: json, options: .prettyPrinted)
            
            if let content = String(data: prettyData, encoding: .utf8) {
                self.selectedFile = JSONFile(url: url, content: content)
                
                // ⭐ 파일 로드 성공 시 자동으로 변환하여 previewCurricula에 저장
                // curricula는 건드리지 않음 (기존 저장된 데이터 보존)
                if let converted = bulkAddFromText(text: content) {
                    self.previewCurricula = converted  // ✅ 미리보기 전용
                    print("✅ 파일 변환 성공: \(converted.count / 4)개 문제")
                } else {
                    // 변환 실패 시 nil 설정하여 에러 Alert 트리거
                    self.previewCurricula = nil
                    print("❌ 파일 변환 실패")
                }
            }
            print("파일의 json형식 : \(String(describing: self.selectedFile?.content))")
        } catch {
            self.errorMessage = "파일 로드 실패: \(error.localizedDescription)"
            self.previewCurricula = nil
        }
    }
    
    // JSONFile에서 데이터를 저장하는 함수
    private func saveJSONFile() {
        guard let jsonFile = selectedFile else {
            errorMessage = "선택된 파일이 없습니다."
            return
        }
        
        // JSONFile의 content를 bulkAddFromText로 전달
        bulkAddFromText(text: jsonFile.content)
    }
}

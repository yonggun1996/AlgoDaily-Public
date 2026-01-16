//
//  RealmManager.swift
//  AlgoDaily
//
//  Created by yonggun Park on 11/8/25.
//

import Foundation
import RealmSwift

class RealmManager {
    
    // 싱글톤 인터페이스
    // 사용법 : RealmManager.shared.add(curriculum)
    static let shared = RealmManager()
    
    private var cachedMaxIdx: Int?
    private var allCurriculaToken: NotificationToken?
    
    // Realm 인스턴스를 반환하는 computed property
    // 예외 발생시
    private var realm: Realm {
        get throws {
            try Realm()
        }
    }
    
    private init() {
        if let url = Realm.Configuration.defaultConfiguration.fileURL {
//            print("Realm 파일 경로: \(url.path)")
        }
        
        let config = Realm.Configuration(
            fileURL: Realm.Configuration.defaultConfiguration.fileURL,
            schemaVersion: 3, // 스키마 버전(구조가 변경될 때 마다 바뀜)
            deleteRealmIfMigrationNeeded: true
//            migrationBlock: { migration, oldSchemaVersion in
//                // 스키마 버전이 변경됐을때 실행되는 로직들
//            }
        )
        
        Realm.Configuration.defaultConfiguration = config
        
        // 모든 Curriculum을 관찰하여 idx 변경 감지
        observeAllCurricula()
    }
    
    // 모든 Curriculum을 관찰
    private func observeAllCurricula() {
        do {
            let realm = try self.realm
            let allCurricula = realm.objects(Curriculum.self)
            
            // 초기 maxIdx 계산
            cachedMaxIdx = allCurricula.max(ofProperty: "idx") as Int? ?? 0
            
            // 변경사항 관찰
            allCurriculaToken = allCurricula.observe { [weak self] changes in
                guard let self = self else { return }
                
                switch changes {
                case .initial(let results):
                    self.cachedMaxIdx = results.max(ofProperty: "idx") as Int? ?? 0
                    
                case .update(let results, deletions: _, insertions: _, modifications: _):
                    self.cachedMaxIdx = results.max(ofProperty: "idx") as Int? ?? 0
                    print("최대 idx 자동 업데이트: \(self.cachedMaxIdx ?? 0)")
                    
                case .error(let error):
                    print("Curriculum 관찰 오류: \(error)")
                }
            }
        } catch {
            print("Curriculum 관찰 초기화 실패: \(error)")
        }
    }
    
    func getNextIdx() -> Int {
        return (cachedMaxIdx ?? 0) + 1
    }
    
    //새로운 Curriculum을 데이터베이스에 추가
    //idx는 자동으로 할당되며, 복습 일정도 자동으로 설정됨
    
    /// 이미 생성된 Curriculum 배열을 Realm에 저장
    /// - Parameters:
    ///   - curricula: 저장할 Curriculum 배열
    ///   - update: 기본키 중복 시 업데이트 정책 (기본값: .error)
    /// - Throws: Realm 작업 중 발생하는 에러
    func addCurricula(
        _ curricula: [Curriculum],
        update: Realm.UpdatePolicy = .error
    ) throws {
        guard !curricula.isEmpty else { return }
        
        let realm = try self.realm
        
        try realm.write {
            realm.add(curricula, update: update)
        }
    }
    
    func fetchTodayProblem() throws -> Results<Curriculum> {
        let realm = try self.realm
        
        let calendar = Calendar.current
        // 테스트가 필요한 경우 해당 라인 주석 해제 후 실행
//        let testDate = calendar.date(from: DateComponents(year: 2025, month: 12, day: 16))!
//        let today = calendar.startOfDay(for: testDate)
        let today = calendar.startOfDay(for: Date())
        let tomorrow = calendar.date(byAdding: .day, value: 1, to: today)!
        
        let todayProblem = realm.objects(Curriculum.self)
            .filter("targetDate >= %@ AND targetDate < %@", today, tomorrow)
            .sorted(byKeyPath: "problemNo", ascending: true)
        
        return todayProblem
    }
    
    func updateCompleteProblem(idx: Int) throws {
        let realm = try self.realm
        
        if let problem = realm.objects(Curriculum.self).filter("idx == %@", idx).first {
            try! realm.write{
                problem.complete.toggle()
            }
        }
    }
    
}

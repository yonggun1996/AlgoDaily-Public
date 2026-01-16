//
//  IndividualAddView.swift
//  AlgoDaily
//
//  Created by yonggun Park on 10/18/25.
//

import SwiftUI

struct IndividualAddView: View {
    @ObservedObject var viewModel: CurriculumViewModel
    
    @State private var problemNumber = ""
    @State private var problemName = ""
    @State private var problemLink = ""
    @State private var selectedDifficulty = ""
    let defualtDropdownMenu = "난이도를 입력하세요"
    @State var curriculumPreviewList: [Curriculum] = []
    
    // Alert 관련 State
    @State private var showAlert = false
    @State private var alertText = ""
    
    let difficulties = ["브론즈", "실버", "골드", "플래티넘", "다이아몬드"]
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // 문제 번호 입력
                InputFieldView(
                    title: "문제 번호",
                    placeholder: "문제 번호를 입력하세요",
                    text: $problemNumber
                )
                
                // 문제 이름 입력
                InputFieldView(
                    title: "문제 이름",
                    placeholder: "문제 이름을 입력하세요",
                    text: $problemName
                )
                
                // 문제 링크 입력
                InputFieldView(
                    title: "문제 링크",
                    placeholder: "문제 링크(URL)를 입력하세요",
                    text: $problemLink
                )
                
                // 난이도 선택
                DropdownView(
                    title: "난이도",
                    selectedDifficulty: $selectedDifficulty,
                    defalutDropdownMenu: defualtDropdownMenu,
                    difficulties: difficulties
                )
                
                // 추가하기 버튼
                Button(action: {
                    addProblem()
                }) {
                    Text("추가하기")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(width: 77, height: 44)
                        .background(Color.blue)
                        .cornerRadius(22)
                }
                .buttonStyle(PlainButtonStyle())
                .frame(maxWidth: .infinity, alignment: .trailing)
                .padding(.horizontal, 24)
                
                ProblemListView(
                    curriculumList: curriculumPreviewList,
                    isPreview: true,
                    onCheckboxTapped: nil,
                    onPlayTapped: nil,
                    onSave: {  // 저장 클로저 추가
                        saveCurriculaToRealm(routineName: "")
                    }
                )
            }
            .padding(.horizontal, 40)
            .padding(.top, 24)
        }
        .background(Color.black)
//        .textFieldAlert(  // Alert 추가
//            isPresented: $showAlert,
//            title: "루틴 이름 설정",
//            text: $alertText,
//            placeholder: "루틴 이름을 입력하세요",
//            onConfirm: { text in
//                saveCurriculaToRealm(routineName: text)
//            },
//            onCancel: {
//                showAlert = false
//            }
//        )
    }
    
    private func addProblem() {
        print("문제 추가:")
        print("- 번호: \(problemNumber)")
        print("- 이름: \(problemName)")
        print("- 링크: \(problemLink)")
        print("- 난이도: \(selectedDifficulty)")
        
        // 현재 Realm의 다음 idx + 이미 추가된 미리보기 리스트의 개수
        let idx = RealmManager.shared.getNextIdx() + curriculumPreviewList.count
        print("- 인덱스: \(idx)")
        
        let curricula = Curriculum.createAllReviewStages(
            startIdx: idx,
            problemNo: problemNumber,
            problemName: problemName,
            problemLink: problemLink,
            level: selectedDifficulty
        )
        
        curriculumPreviewList.append(contentsOf: curricula)
        
//        viewModel.addCurriculum(
//            problemNo: problemNumber,
//            problemName: problemName,
//            problemLink: problemLink,
//            level: selectedDifficulty
//        )
        
        // 폼 초기화
        problemNumber = ""
        problemName = ""
        problemLink = ""
        selectedDifficulty = ""
    }
    
    private func showSaveAlert() {
        alertText = ""  // 초기화
        showAlert = true  // Alert 표시
    }
    
    private func saveCurriculaToRealm(routineName: String) {
        print("루틴 이름: \(routineName)")
        
        // 저장할 데이터에 루틴을 공통으로 세팅
        curriculumPreviewList.forEach { $0.routineName = routineName }
        
        print("저장할 데이터: \(curriculumPreviewList)")
        
        // 여기서 실제 저장 로직 실행
        viewModel.addCurricula(curriculumPreviewList)
        
        // 저장 후 초기화
        curriculumPreviewList.removeAll()
        problemNumber = ""
        problemName = ""
        problemLink = ""
        selectedDifficulty = ""
    }
}

//#Preview {
////    let previewViewModel = CurriculumViewModel()
////    IndividualAddView(viewModel: previewViewModel)
//}

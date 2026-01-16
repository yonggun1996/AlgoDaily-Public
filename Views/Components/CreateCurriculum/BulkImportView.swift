//
//  BulkImportView.swift
//  AlgoDaily
//
//  Created by yonggun Park on 10/18/25.
//

import SwiftUI

struct BulkImportView: View {
    @ObservedObject var viewModel: CurriculumViewModel
    
    @State private var webURL = ""
    @State private var jsonText = ""
    @State private var fileImportPlaceholder = "JSON파일을 이곳에 드래그하거나"
    @State private var isDragOver = false
    @State private var dividerViewText = "또는"
    @State private var exampleJSON = CommonMSG().BulkImportExmpleJSON
    
    // 에러 Alert용
    @State private var showErrorAlert = false
    
    // 성공 확인 Alert용
    @State private var showConfirmAlert = false
    
    // 변환된 Curriculum 리스트를 저장
    @State private var previewCurricula: [Curriculum] = []
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // 웹 URL에서 가져오기
                WebURLImportView(webURL: $webURL)
                
                // 구분선
                DividerView(text: dividerViewText)
                
                // 파일에서 가져오기
                FileImportView(viewModel: viewModel, placeholder:fileImportPlaceholder, isDragOver: .constant(false))
                
                // 구분선
                DividerView(text: dividerViewText)
                
                // 텍스트 붙여넣기
                TextEditorView(
                    title: "텍스트 붙여넣기",
                    jsonText: $jsonText,
                    exampleJSON: exampleJSON,
                    description: CommonMSG().BulkImportExampleDesc
                )
                
                Spacer(minLength: 50)
                
                // 데이터 가져오기 버튼
                Button(action: {
                    importData()
                }) {
                    Text("데이터 저장하기")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                        .background(Color.blue)
                        .cornerRadius(28)
                }
                .padding(.horizontal, 24)
            }
            .padding(.horizontal, 40)
            .padding(.top, 24)
        }
        .background(Color.black)
        // ⭐ 파일 선택 감지 - previewCurricula가 변경되면 자동으로 Alert 표시
        .onChange(of: viewModel.previewCurricula) { preview in
            if let curricula = preview {
                // ✅ 변환 성공 - ExtraLarge Alert 표시
                previewCurricula = curricula
                showConfirmAlert = true
            } else if viewModel.errorMessage != nil {
                // ❌ 변환 실패 - Small Alert 표시
                showErrorAlert = true
            }
        }
        // 에러 Alert (Small 사이즈)
        .customAlert(
            isPresented: $showErrorAlert,
            title: "변환 실패",
            message: viewModel.errorMessage ?? "알 수 없는 오류가 발생했습니다.",
            size: .small,
            primaryButton: .init(title: "확인")
        ) {
            EmptyView()
        }
        // 성공 확인 Alert (Large 사이즈)
        .customAlert(
            isPresented: $showConfirmAlert,
            title: "데이터 저장",
            message: "\(previewCurricula.count / 4)개의 문제를 저장하시겠습니까?",
            size: .extraLarge,
            primaryButton: .init(title: "저장", action: {
                confirmImport()
            }),
            secondaryButton: .init(title: "취소", role: .cancel)
        ) {
            // SimpleProblemListView를 활용한 미리보기
            SimpleProblemListView(problems: convertToSimpleProblems(previewCurricula))
        }
    }
    
    private func importData() {
        print("데이터 가져오기:")
        print("- 웹 URL: \(webURL)")
        print("- JSON 텍스트: \(jsonText)")
        
        let textToCurriculum = viewModel.bulkAddFromText(text: jsonText)
        // 텍스트를 curriculum 리스트로 반환을 못할경우 에러메시지를 띄움
        if textToCurriculum == nil {
            showErrorAlert = true
            return
        }
        
        // 반환에 성공할 경우 SimpleProblemListView를 활용한 alert을 띄움
        previewCurricula = textToCurriculum!
        showConfirmAlert = true
    }
    
    private func confirmImport() {
        // DB에 저장
        viewModel.addCurricula(previewCurricula)
        
        // 저장 성공 시 폼 초기화
        if viewModel.errorMessage == nil {
            webURL = ""
            jsonText = ""
            previewCurricula = []
            print("✅ 데이터 저장 완료 및 폼 초기화")
        } else {
            print("❌ 데이터 저장 실패: \(viewModel.errorMessage ?? "알 수 없는 오류")")
        }
    }
    
    // [Curriculum]을 SimpleProblemListView에서 사용할 수 있는 형태로 변환
    // 신규(review: 0)인 문제만 추출
    private func convertToSimpleProblems(_ curricula: [Curriculum]) -> [(name: String, level: String)] {
        return curricula
            .filter { $0.reviewCount == "신규" } // 신규 문제만
            .map { (name: $0.problemName, level: $0.level) }
    }
}

//#Preview {
//    BulkImportView()
//        .background(Color.black)
//}

//
//  FileImportView.swift
//  AlgoDaily
//
//  Created by yonggun Park on 10/18/25.
//

import SwiftUI

struct FileImportView: View {
    @ObservedObject var viewModel: CurriculumViewModel
    let placeholder: String
    @Binding var isDragOver: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("파일에서 가져오기")
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(.white)
            
            VStack(spacing: 16) {
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isDragOver ? Color.blue : Color.gray, style: StrokeStyle(lineWidth: 2, dash: [5]))
                    .frame(height: 120)
                    .overlay(
                        VStack(spacing: 8) {
                            Image(systemName: "doc.badge.plus")
                                .font(.system(size: 40))
                                .foregroundColor(.gray)
                            
                            Text(placeholder)
                                .font(.system(size: 14))
                                .foregroundColor(.gray)
                        }
                    )
                    .onDrop(of: [.fileURL], isTargeted: $isDragOver) { providers in
                        return viewModel.handleFileDrop(providers)
                    }
                
                Button("파일 선택") {
                    viewModel.selectFile()
                }
                .buttonStyle(PlainButtonStyle())
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(.white)
                .padding(.horizontal, 20)
                .padding(.vertical, 12)
                .background(Color.blue)
                .cornerRadius(12)
            }
        }
    }
}

//#Preview {
//    FileImportView(placeholder: "JSON 파일을 이곳에 드래그하거나",
//        isDragOver: .constant(false))
//        .padding()
//        .background(Color.black)
//}

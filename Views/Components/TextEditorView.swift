//
//  TextImportView.swift
//  AlgoDaily
//
//  Created by yonggun Park on 10/18/25.
//

import SwiftUI

struct TextEditorView: View {
    let title: String
    @Binding var jsonText: String
    let exampleJSON: String
    let description: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(.white)
            
            TextEditor(text: $jsonText)
                .font(.system(size: 14))
                .padding(12)
                .frame(minHeight: 200)
                .background(Color.gray.opacity(0.2))
                .foregroundColor(.white)
                .cornerRadius(12)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                )
            
            Text(description)
                .font(.system(size: 12))
                .foregroundColor(.gray)
                .padding(.horizontal, 4)
        }
        .onAppear {
            if jsonText.isEmpty {
                jsonText = exampleJSON
            }
        }
    }
}

#Preview {
    TextEditorView(title: "텍스트 붙여넣기 입니다", jsonText: .constant(""), exampleJSON: "JSON예시 1",
    description: "`id`, `title`, `url` 필드는 필수입니다. `difficulty` 필드는 선택 사항입니다.")
}

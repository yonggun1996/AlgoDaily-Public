//
//  WebURLImportView.swift
//  AlgoDaily
//
//  Created by yonggun Park on 10/18/25.
//

import SwiftUI

struct WebURLImportView: View {
    @Binding var webURL: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("웹 URL에서 가져오기")
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(.white)
            
            HStack(spacing: 12) {
                TextField("https://example.com/problems.json", text: $webURL)
                    .textFieldStyle(PlainTextFieldStyle())
                    .font(.system(size: 16))
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                    .background(Color.gray.opacity(0.2))
                    .foregroundColor(.white)
                    .cornerRadius(12)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                    )
                
                Button("불러오기") {
                    loadFromURL()
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
    
    private func loadFromURL() {
        print("웹 URL에서 데이터 불러오기: \(webURL)")
        // 실제 URL 로딩 로직 구현
    }
}

#Preview {
    WebURLImportView(webURL: .constant(""))
        .padding()
        .background(Color.black)
}

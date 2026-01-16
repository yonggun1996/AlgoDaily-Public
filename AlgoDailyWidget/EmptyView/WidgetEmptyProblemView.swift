//
//  WidgetEmptyProblemView.swift
//  AlgoDailyWidgetExtension
//
//  Created by yonggun Park on 1/1/26.
//

import SwiftUI
import WidgetKit

/// 위젯 환경에서 사용되는 EmptyProblemView 구현
struct WidgetEmptyProblemView: View {
    var onAddButtonTapped: (() -> Void)?
    var urlScheme: String
    
    init(onAddButtonTapped: (() -> Void)? = nil, urlScheme: String = "appscheme://create") {
        self.onAddButtonTapped = onAddButtonTapped
        self.urlScheme = urlScheme
    }
    
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "tray")
                .font(.system(size: 60))
                .foregroundColor(.gray)
            
            Text("문제를 추가해주세요!")
                .font(.system(size: 20, weight: .semibold))
                .foregroundColor(.primary)
            
            if let url = URL(string: urlScheme) {
                Link(destination: url) {
                    Image(systemName: "plus.circle.fill")
                        .font(.system(size: 50))
                        .foregroundColor(.blue)
                }
                .buttonStyle(PlainButtonStyle())
            } else {
                // Fallback: URL이 유효하지 않을 경우
                Image(systemName: "plus.circle.fill")
                    .font(.system(size: 50))
                    .foregroundColor(.gray.opacity(0.5))
            }
        }
        .frame(maxWidth: .infinity)
        .padding(40)
        .background(
            RoundedRectangle(cornerRadius: 24)
                .stroke(Color.blue.opacity(0.3), lineWidth: 1)
                .background(
                    RoundedRectangle(cornerRadius: 24)
                        .fill(Color.white.opacity(0.1)) // 위젯: 약간의 반투명 배경
                )
        )
        .shadow(color: Color.black.opacity(0.05), radius: 12, x: 0, y: 6)
    }
}

#Preview {
    WidgetEmptyProblemView()
}

//
//  AppEmptyProblemView.swift
//  AlgoDaily
//
//  Created by yonggun Park on 1/1/26.
//

import SwiftUI

/// 앱 환경에서 사용되는 EmptyProblemView 구현
struct AppEmptyProblemView: View {
    var onAddButtonTapped: (() -> Void)?
    
    init(onAddButtonTapped: (() -> Void)? = nil) {
        self.onAddButtonTapped = onAddButtonTapped
    }
    
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "tray")
                .font(.system(size: 60))
                .foregroundColor(.gray)
            
            Text("문제를 추가해주세요!")
                .font(.system(size: 20, weight: .semibold))
                .foregroundColor(.primary)
            
            Button(action: {
                onAddButtonTapped?()
            }) {
                Image(systemName: "plus.circle.fill")
                    .font(.system(size: 50))
                    .foregroundColor(.blue)
            }
            .buttonStyle(PlainButtonStyle())
        }
        .frame(maxWidth: .infinity)
        .padding(40)
        .background(
            RoundedRectangle(cornerRadius: 24)
                .stroke(Color.blue.opacity(0.3), lineWidth: 1)
                .background(
                    RoundedRectangle(cornerRadius: 24)
                        .fill(Color(red: 0.2, green: 0.2, blue: 0.22))
                )
        )
        .shadow(color: Color.black.opacity(0.05), radius: 12, x: 0, y: 6)
    }
}

#Preview {
    AppEmptyProblemView(onAddButtonTapped: {
        print("Add button tapped")
    })
}


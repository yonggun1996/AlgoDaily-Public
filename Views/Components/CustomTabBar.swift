//
//  CustomTabBar.swift
//  AlgoDaily
//
//  Created by yonggun Park on 10/18/25.
//

import SwiftUI

struct CustomTabBar: View {
    @Binding var selectedTab: Int
    var body: some View {
        HStack(spacing: 0) {
            TabButton(
                title: "개별 추가",
                isSelected: selectedTab == 0,
                action: {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        selectedTab = 0
                    }
                }
            )
            
            TabButton(
                title: "일괄 가져오기",
                isSelected: selectedTab == 1,
                action: {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        selectedTab = 1
                    }
                }
            )
        }
        .background(Color.black)
    }
}
    
struct TabButton: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
        
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Text(title)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(isSelected ? .blue : .gray)
                    
                Rectangle()
                    .frame(height: 2)
                    .foregroundColor(isSelected ? .blue : .clear)
            }
        }
        .buttonStyle(PlainButtonStyle())
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .background(isSelected ? Color.blue.opacity(0.1) : Color.clear)
        .cornerRadius(8)
    }
}
    
#Preview {
    CustomTabBar(selectedTab: .constant(0))
}

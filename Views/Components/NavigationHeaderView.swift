//
//  NavigationHeaderView.swift
//  AlgoDaily
//
//  Created by yonggun Park on 10/18/25.
//

import SwiftUI

struct NavigationHeaderView: View {
    var body: some View {
            HStack {
                Button(action: {
                    // 뒤로가기 액션
                    print("뒤로가기 버튼이 눌렸습니다")
                }) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 18, weight: .medium))
                        .foregroundColor(.white)
                }
                
                Spacer()
                
                Text("나만의 커리큘럼 만들기")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.white)
                
                Spacer()
                
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
            .background(Color.black)
        }
}

#Preview {
    NavigationHeaderView()
}

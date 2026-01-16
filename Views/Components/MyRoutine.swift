//
//  SearchRoutine.swift
//  AlgoDaily
//
//  Created by yonggun Park on 11/17/25.
//

import SwiftUI

struct MyRoutine: View {
    let subtitle: String
    let title: String
    
    var body: some View {
        Button(action: {
            print("루틴 버튼 클릭")
        }) {
            HStack {
                VStack(alignment: .leading, spacing: 8) {
                    Text(subtitle)
                        .font(.system(size: 16, weight: .regular))
                        .foregroundColor(.white.opacity(0.7))
                    
                    Text(title)
                        .font(.system(size: 32, weight: .bold))
                        .foregroundColor(.white)
                }
                
                Spacer()
                
                Image(systemName: "gearshape.fill")
                    .font(.system(size: 24))
                    .foregroundColor(.gray)
            }
            .padding(.horizontal, 40)
            .padding(.vertical, 40)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color(red: 0.2, green: 0.2, blue: 0.22))
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    MyRoutine(subtitle: "내 루틴",title: "루틴이름")
}

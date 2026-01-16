//
//  DividerView.swift
//  AlgoDaily
//
//  Created by yonggun Park on 10/18/25.
//

import SwiftUI

struct DividerView: View {
    let text: String
    var body: some View {
        HStack {
            Rectangle()
                .frame(height: 1)
                .foregroundColor(.gray.opacity(0.3))
            
            Text("또는")
                .font(.system(size: 14))
                .foregroundColor(.gray)
                .padding(.horizontal, 16)
            
            Rectangle()
                .frame(height: 1)
                .foregroundColor(.gray.opacity(0.3))
        }
    }
}

#Preview {
    DividerView(text: "또는")
        .padding()
        .background(Color.black)
}

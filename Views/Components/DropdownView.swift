//
//  DifficultyPickerView.swift
//  AlgoDaily
//
//  Created by yonggun Park on 10/18/25.
//

import SwiftUI

struct DropdownView: View {
    let title: String
    @Binding var selectedDifficulty: String
    let defalutDropdownMenu: String
    let difficulties: [String]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(.white)
            
            Menu {
                ForEach(difficulties, id: \.self) { difficulty in
                    Button(difficulty) {
                        selectedDifficulty = difficulty
                    }
                }
            } label: {
                HStack {
                    Text(selectedDifficulty.isEmpty ? defalutDropdownMenu : selectedDifficulty)
                        .font(.system(size: 16))
                        .foregroundColor(selectedDifficulty.isEmpty ? .gray : .white)
                    
                    Spacer()
                    
                    Image(systemName: "chevron.down")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.gray)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background(Color.gray.opacity(0.2))
                .cornerRadius(12)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                )
            }
            .buttonStyle(FullWidthMenuButtonStyle())
        }
    }
}

// 커스텀 ButtonStyle
struct FullWidthMenuButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .frame(maxWidth: .infinity, alignment: .leading)
    }
}

#Preview {
    DropdownView(
        title: "난이도",
        selectedDifficulty: .constant(""),
        defalutDropdownMenu: "난이도를 선택해주세요",
        difficulties: ["브론즈", "실버", "골드", "플래티넘", "다이아몬드"]
    )
    .padding()
    .background(Color.black)
}

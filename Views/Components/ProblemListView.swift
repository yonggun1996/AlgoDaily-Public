//
//  ProblemListView.swift
//  AlgoDaily
//
//  Created by yonggun Park on 11/16/25.
//

import SwiftUI

// MARK: - 재사용 가능한 리스트 아이템 컴포넌트
struct ProblemListItemView: View {
    let curriculum: Curriculum
    let isPreview: Bool
    let onCheckboxTapped: ((Curriculum) -> Void)?
    let onPlayTapped: ((Curriculum) -> Void)?
    
    var body: some View {
        HStack(spacing: 16) {
            // 체크박스
            if !isPreview {
                Button(action: {
                    onCheckboxTapped?(curriculum)
                }) {
                    Image(systemName: curriculum.complete ? "checkmark.square.fill" : "square")
                        .font(.title2)
                        .foregroundColor(curriculum.complete ? .blue : .gray)
                }
                .buttonStyle(PlainButtonStyle())
            } else {
                // 체크박스 비활성화 (항상 체크 표시)
                Image(systemName: "checkmark.square.fill")
                    .font(.title2)
                    .foregroundColor(.blue.opacity(0.5))
            }
            
            // 중앙 컨텐츠
            VStack(alignment: .leading, spacing: 4) {
                Text(curriculum.problemName)
                    .font(.title3)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                
                HStack(spacing: 8) {
                    // 레벨 뱃지
                    Text(curriculum.level)
                        .font(.caption)
                        .foregroundColor(.gray)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 4)
                        .background(Color.gray.opacity(0.2))
                        .cornerRadius(12)
                    
                    // 상태 뱃지
                    Text(curriculum.reviewCount)
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundColor(getTextColor(reviewCount: curriculum.reviewCount))
                        .padding(.horizontal, 10)
                        .padding(.vertical, 4)
                        .background(getBGColor(reviewCount: curriculum.reviewCount))
                        .cornerRadius(12)
                }
            }
            
            Spacer()
            
            // 재생 버튼
            if !isPreview {
                Button(action: {
                    onPlayTapped?(curriculum)
                }) {
                    Circle()
                        .fill(Color.blue)
                        .frame(width: 40, height: 40)
                        .overlay(
                            Image(systemName: "play.fill")
                                .foregroundColor(.white)
                                .font(.system(size: 14))
                                .offset(x: 2)
                        )
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
        .padding(16)
        .background(Color(white: 0.15))
        .cornerRadius(16)
    }
    
    private func getTextColor(reviewCount: String) -> Color {
        switch reviewCount {
        case "신규":
            return Color(red: 59/255, green: 130/255, blue: 246/255)
        case "1차":
            return Color(red: 21/255, green: 128/255, blue: 61/255)
        case "2차":
            return Color(red: 202/255, green: 138/255, blue: 4/255)
        case "3차":
            return Color(red: 190/255, green: 24/255, blue: 93/255)
        default:
            return Color.black
        }
    }
    
    private func getBGColor(reviewCount: String) -> Color {
        switch reviewCount {
        case "신규":
            return Color(red: 219/255, green: 234/255, blue: 254/255)
        case "1차":
            return Color(red: 220/255, green: 252/255, blue: 231/255)
        case "2차":
            return Color(red: 254/255, green: 249/255, blue: 195/255)
        case "3차":
            return Color(red: 252/255, green: 231/255, blue: 243/255)
        default:
            return Color.black
        }
    }
}

struct ProblemListView: View {
    let curriculumList: [Curriculum]    // 저장한 커리큘럼 리스트
    let isPreview: Bool                 // 미리보기 여부
    let onCheckboxTapped: ((Curriculum) -> Void)?
    let onPlayTapped: ((Curriculum) -> Void)?
    let onSave: (() -> Void)?  // 저장 클로저 추가
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {  // 전체를 VStack으로 감싸고 왼쪽 정렬
            if isPreview {
                Text("미리보기")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.white)
            }
            ScrollView {
                VStack(alignment: .leading, spacing: 8) {
                    ForEach(
                        isPreview
                            ? curriculumList.filter { $0.reviewCount == "신규" }
                            : curriculumList,
                        id: \.idx
                    ) { curriculum in
                        ProblemListItemView(
                            curriculum: curriculum,
                            isPreview: isPreview,
                            onCheckboxTapped: onCheckboxTapped,
                            onPlayTapped: onPlayTapped
                        )
                    }
                }
                .padding(.horizontal)
                .padding(.vertical, 8)
            }
            if !curriculumList.isEmpty && isPreview {
                Button(action: {
                    saveProblem()
                }) {
                    Text("저장")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(width: 77, height: 44)
                        .background(Color.blue)
                        .cornerRadius(22)
                }
                .buttonStyle(PlainButtonStyle())
                .frame(maxWidth: .infinity, alignment: .trailing)
                .padding(.horizontal, 24)
            }
        }
        .background(Color.black)
    }
    
    private func saveProblem() {
        onSave?()
    }
}

// MARK: alert에 사용할 문제 리스트
struct SimpleProblemListView: View {
    let problems: [(name: String, level: String)]
    
    var body: some View {
        ScrollView {
            VStack(spacing: 12) {
                ForEach(problems, id: \.name) { problem in
                    HStack(spacing: 12) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(problem.name)
                                .font(.body)
                                .fontWeight(.semibold)
                                .foregroundColor(.white)
                            
                            Text(problem.level)
                                .font(.caption)
                                .foregroundColor(.gray)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 3)
                                .background(Color.gray.opacity(0.2))
                                .cornerRadius(8)
                        }
                        
                        Spacer()
                    }
                    .padding(12)
                    .background(Color(white: 0.15))
                    .cornerRadius(12)
                }
            }
            .padding(.horizontal, 8)
        }
    }
}

#Preview {
    SimpleProblemListView(problems: [
        (name: "두 수의 합", level: "Easy"),
        (name: "배열 정렬", level: "Medium"),
        (name: "이진 탐색", level: "Hard"),
        (name: "연결 리스트", level: "Medium"),
        (name: "스택 구현", level: "Easy"),
        (name: "해시 테이블", level: "Medium"),
        (name: "트리 순회", level: "Hard"),
        (name: "큐 구현", level: "Easy"),
        (name: "그래프 탐색", level: "Hard")
    ])
    .background(Color.black)
}

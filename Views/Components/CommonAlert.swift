//
//  CommonAlert.swift
//  AlgoDaily
//
//  Created by yonggun Park on 11/16/25.
//

import SwiftUI

struct CustomAlert<Content: View>: View {
    @Binding var isPresented: Bool
    let title: String
    let message: String?
    @ViewBuilder let content: () -> Content // 실질적으로 보여질 콘텐츠는 해당 ui를 호출하는 시점에서 전달
    let primaryButton: AlertButton
    let secondaryButton: AlertButton?
    let size: AlertSize // 크기 옵션 추가
    
    struct AlertButton {
        let title: String
        let role: ButtonRole?
        let action: () -> Void
        
        init(title: String, role: ButtonRole? = nil, action: @escaping () -> Void = {}) {
            self.title = title
            self.role = role
            self.action = action
        }
    }
    
    enum ButtonRole {
        case destructive
        case cancel
    }
    
    // Alert 크기 옵션
    enum AlertSize {
        case small      // 간단한 텍스트, 확인/취소만
        case medium     // TextField, 작은 폼
        case large      // 이미지, 중간 리스트
        case extraLarge // ProblemListView 같은 큰 컨텐츠
        case custom(width: CGFloat?, height: CGFloat?, horizontalPadding: CGFloat) // 완전 커스텀
        
        var maxWidth: CGFloat? {
            switch self {
            case .small: return 320
            case .medium: return 380
            case .large: return 480
            case .extraLarge: return 600
            case .custom(let width, _, _): return width
            }
        }
        
        var maxHeight: CGFloat? {
            switch self {
            case .small: return 250
            case .medium: return 350
            case .large: return 500
            case .extraLarge: return 650
            case .custom(_, let height, _): return height
            }
        }
        
        var horizontalPadding: CGFloat {
            switch self {
            case .small, .medium: return 40
            case .large: return 30
            case .extraLarge: return 20
            case .custom(_, _, let padding): return padding
            }
        }
        
        var contentPadding: CGFloat {
            switch self {
            case .small, .medium: return 24
            case .large, .extraLarge: return 16
            case .custom: return 16
            }
        }
    }
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.3)
                .ignoresSafeArea()
                .onTapGesture {
                    isPresented = false
                }
            
            VStack(spacing: 20) {
                // 제목
                Text(title)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.white)
                    .padding(.top, 24)
                
                // 메시지 (옵셔널)
                if let message = message, !message.isEmpty {
                    Text(message)
                        .font(.system(size: 14))
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, size.contentPadding)
                }
                
                // 커스텀 컨텐츠
                content()
                    .padding(.horizontal, size.contentPadding)
                    .frame(maxHeight: .infinity) // 남은 공간을 모두 사용하도록
                
                // 버튼들
                HStack(spacing: 12) {
                    if let secondaryButton = secondaryButton {
                        Button(action: {
                            secondaryButton.action()
                            isPresented = false
                        }) {
                            Text(secondaryButton.title)
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(buttonColor(for: secondaryButton.role))
                                .frame(maxWidth: .infinity)
                                .frame(height: 44)
                                .background(Color.gray.opacity(0.2))
                                .cornerRadius(12)
                        }
                    }
                    
                    Button(action: {
                        primaryButton.action()
                        isPresented = false
                    }) {
                        Text(primaryButton.title)
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 44)
                            .background(buttonBackground(for: primaryButton.role))
                            .cornerRadius(12)
                    }
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 24)
            }
            .frame(maxWidth: size.maxWidth ?? .infinity)
            .frame(maxHeight: size.maxHeight)
            .background(Color(white: 0.15))
            .cornerRadius(20)
            .padding(.horizontal, size.horizontalPadding)
        }
    }
    
    private func buttonColor(for role: ButtonRole?) -> Color {
        switch role {
        case .destructive: return .red
        case .cancel: return .gray
        case .none: return .white
        }
    }
    
    private func buttonBackground(for role: ButtonRole?) -> Color {
        role == .destructive ? .red : .blue
    }
}

// View Extension
extension View {
    func customAlert<Content: View>(
        isPresented: Binding<Bool>,
        title: String,
        message: String? = nil,
        size: CustomAlert<Content>.AlertSize = .medium, // 기본값 medium
        primaryButton: CustomAlert<Content>.AlertButton,
        secondaryButton: CustomAlert<Content>.AlertButton? = nil,
        @ViewBuilder content: @escaping () -> Content
    ) -> some View {
        self.overlay {
            if isPresented.wrappedValue {
                CustomAlert(
                    isPresented: isPresented,
                    title: title,
                    message: message,
                    content: content,
                    primaryButton: primaryButton,
                    secondaryButton: secondaryButton,
                    size: size
                )
            }
        }
    }
}


// MARK: - Medium Alert (TextField)
#Preview("Medium Alert - TextField") {
    struct PreviewView: View {
        @State private var showAlert = true
        @State private var text = ""
        
        var body: some View {
            Color.black.ignoresSafeArea()
                .customAlert(
                    isPresented: $showAlert,
                    title: "문제 이름 수정",
                    message: "새로운 문제 이름을 입력하세요",
                    size: .medium,
                    primaryButton: .init(title: "확인"),
                    secondaryButton: .init(title: "취소", role: .cancel)
                ) {
                    TextField("문제 이름", text: $text)
                        .textFieldStyle(PlainTextFieldStyle())
                        .padding()
                        .background(Color.gray.opacity(0.2))
                        .foregroundColor(.white)
                        .cornerRadius(12)
                }
        }
    }
    return PreviewView()
}

// MARK: - Large Alert (이미지)
#Preview("Large Alert - Image") {
    struct PreviewView: View {
        @State private var showAlert = true
        let sampleProblems = [
            (name: "두 수의 합", level: "Easy"),
            (name: "배열 정렬", level: "Medium"),
            (name: "이진 탐색", level: "Hard"),
            (name: "연결 리스트", level: "Medium"),
            (name: "스택 구현", level: "Easy"),
            (name: "해시 테이블", level: "Medium"),
            (name: "트리 순회", level: "Hard")
        ]
        
        var body: some View {
            Color.black.ignoresSafeArea()
                .customAlert(
                    isPresented: $showAlert,
                    title: "문제 이미지",
                    message: nil,
                    size: .large,
                    primaryButton: .init(title: "닫기")
                ) {
                    SimpleProblemListView(problems: sampleProblems)
                        .frame(height: 200)
                }
        }
    }
    return PreviewView()
}

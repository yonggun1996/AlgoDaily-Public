//
//  OnbordingView.swift
//  AlgoDaily
//
//  Created by yonggun Park on 10/18/25.
//

import SwiftUI

struct OnbordingView: View {
    
    var navigationPath: (() -> Void)? // macOS 13.0+용 클로저
    var shouldNavigateToMain: Binding<Bool>? // macOS 12.0용
    
    var body: some View {
        ZStack {
            // 배경색 (검은색)
            Color.black
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                Spacer()
                
                // 상단 콘텐츠 영역
                VStack(spacing: 24) {
                    // 코드 브래킷 아이콘
                    HStack(spacing: 8) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 32, weight: .bold))
                            .foregroundColor(.blue)
                        Image(systemName: "chevron.right")
                            .font(.system(size: 32, weight: .bold))
                            .foregroundColor(.blue)
                    }
                    
                    // 앱 제목
                    Text("AlgoDaily")
                        .font(.system(size: 36, weight: .bold))
                        .foregroundColor(.white)
                    
                    // 슬로건
                    VStack(spacing: 4) {
                        Text("매일의 작은 습관이")
                            .font(.system(size: 18, weight: .medium))
                            .foregroundColor(.white)
                        Text("당신의 코딩 실력을 완성합니다.")
                            .font(.system(size: 18, weight: .medium))
                            .foregroundColor(.white)
                    }
                }
                
                Spacer()
                
                // 하단 버튼
                Button(action: {
                    print("🔘 시작하기 버튼 클릭")
                    if #available(macOS 13.0, *), let navPath = navigationPath {
                        print("🚀 Using navigationPath closure (OnbordingView)")
                        navPath() // AlgoDailyApp.swift에서 main으로 이동하는 핸들러를 실행
                    } else if let shouldNavigate = shouldNavigateToMain {
                        print("🔄 Using shouldNavigateToMain")
                        shouldNavigate.wrappedValue = true
                    }
                }) {
                    Text("시작하기")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                        .background(Color.blue)
                        .cornerRadius(28)
                }
                .buttonStyle(PlainButtonStyle())
                .padding(.horizontal, 24)
                .padding(.bottom, 50)
            }
        }
    }
}

#Preview {
    OnbordingView()
}

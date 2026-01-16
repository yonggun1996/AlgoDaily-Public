//
//  AlgoDailyApp.swift
//  AlgoDaily
//
//  Created by yonggun Park on 10/18/25.
//

import SwiftUI

@main
struct AlgoDailyApp: App {
    
    // macOS 12.0용 상태 변수
    @State private var shouldNavigateToMain = false
    @State private var shouldNavigateToCreate = false
    
    // 중복호출을 막기 위한 변수
    @State private var lastProcessedURLTime: Date?
    
    var body: some Scene {
        WindowGroup {
            if #available(macOS 13.0, *) {
                // macos 13이상은 네비게이션 뷰를 따로 생성
                ModernNavigationView(lastProcessedURLTime: $lastProcessedURLTime)
            } else {
                // ⭐ macOS 12.0: NavigationView 사용
                NavigationView {
                    OnbordingView(
                        navigationPath: nil,
                        shouldNavigateToMain: $shouldNavigateToMain
                    )
                    .background(
                        NavigationLink(
                            destination: MainView(
                                navigationPath: nil,
                                shouldNavigateToCreate: $shouldNavigateToCreate
                            ),
                            isActive: $shouldNavigateToMain,
                            label: { EmptyView() }
                        )
                        .hidden()
                    )
                    .onOpenURL { url in
                        handleLegacyURL(url)
                    }
                }
            }
        }
    }
    
    // macOS 12.0용 URL 핸들러
    private func handleLegacyURL(_ url: URL) {
        let now = Date()
        if let lastTime = lastProcessedURLTime,
           now.timeIntervalSince(lastTime) < 0.5 {
            print("중복 URL 호출 무시: \(url.absoluteString)")
            return
        }
        
        // url scheme으로 들어올 경우 특정 페이지 랜딩
        if url.scheme == "appscheme" && url.host == "create" {
            lastProcessedURLTime = now
            print("URL Scheme 처리: \(url.absoluteString)")
            shouldNavigateToMain = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                shouldNavigateToCreate = true
            }
        } else if url.scheme == "appscheme" && url.host == "main" {
            shouldNavigateToMain = true
        }
    }
}

// macOS 13.0+ 전용 뷰
@available(macOS 13.0, *)
struct ModernNavigationView: View {
    @State private var navigationPath = NavigationPath()
    @Binding var lastProcessedURLTime: Date?
    
    var body: some View {
        NavigationStack(path: $navigationPath) {
            OnbordingView(
                navigationPath: {
                    print("📍 OnbordingView: Navigating to main")
                    navigationPath.append("main")
                },
                shouldNavigateToMain: nil
            )
            // 네비게이션스택 핸들러의 경로 감지(destination)에 따른 페이지 랜딩
            .navigationDestination(for: String.self) { destination in
                if destination == "main" {
                    MainView(
                        navigationPath: {
                            print("📍 MainView: Navigating to create")
                            navigationPath.append("create")
                        },
                        shouldNavigateToCreate: nil
                    )
                } else if destination == "create" {
                    CurriculumCreateView()
                } else {
                    Text("Unknown destination: \(destination)")
                }
            }
            .onOpenURL { url in
                handleURL(url)
            }
        }
    }
    
    // macos 13이상에서 특정 앱 스킴으로 들어올 경우 특정 페이지로 랜딩
    private func handleURL(_ url: URL) {
        let now = Date()
        if let lastTime = lastProcessedURLTime,
           now.timeIntervalSince(lastTime) < 0.5 {
            print("중복 URL 호출 무시: \(url.absoluteString)")
            return
        }
        
        if url.scheme == "appscheme" && url.host == "create" {
            lastProcessedURLTime = now
            print("URL Scheme 처리: \(url.absoluteString)")
            navigationPath.append("main")
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                navigationPath.append("create")
            }
        } else if url.scheme == "appscheme" && url.host == "main" {
            navigationPath.append("main")
        }
    }
}

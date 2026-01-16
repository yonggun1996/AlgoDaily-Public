//
//  MainView.swift
//  AlgoDaily
//
//  Created by yonggun Park on 11/17/25.
//

import SwiftUI

struct MainView: View {
    @ObservedObject var viewModel = CurriculumViewModel()
    @State private var showCreateView = false
    
    // macOS 13.0+용 네비게이션 클로저
    var navigationPath: (() -> Void)?
    // macOS 12.0용 바인딩
    var shouldNavigateToCreate: Binding<Bool>?
    
    // 네비게이션 클로저와 해당 변수 초기화
    init(navigationPath: (() -> Void)? = nil, shouldNavigateToCreate: Binding<Bool>? = nil) {
        self.navigationPath = navigationPath
        self.shouldNavigateToCreate = shouldNavigateToCreate
        print("🏗️ MainView initialized with navigationPath: \(navigationPath != nil ? "YES" : "NO")")
    }
    
    private var completeCount: Int {
        viewModel.todayProblem.filter { $0.complete }.count
    }
    
    private var problemCount: Int {
        viewModel.todayProblem.count
    }
    
    // 진행률
    private var progress: Double {
        problemCount == 0 ? 0 : Double(completeCount) / Double(problemCount)
    }
    
    var body: some View {
        GeometryReader { geo in
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    Text("오늘의 문제")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(.primary)
                    
                    // 파란 박스 영역 (목표 달성도 + 리스트)
                    VStack(alignment: .leading, spacing: 16) {
                        HStack {
                            Text("목표 달성도")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(.primary)
                            
                            Spacer()
                            
                            Text("\(completeCount)/\(problemCount)")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(.gray)
                        }
                        
                        ProgressView(value: progress)
                            .progressViewStyle(LinearProgressViewStyle(tint: Color.blue))
                        
                        if (problemCount == 0) {
                            // EmptyProblemView에 버튼 액션 전달
                            EmptyProblemView(onAddButtonTapped: {
                                print("🔘 EmptyProblemView 버튼 클릭")
                                if #available(macOS 13.0, *), let navPath = navigationPath {
                                    print("🚀 Using navigationPath closure")
                                    navPath()
                                } else {
                                    print("🔄 Using showCreateView")
                                    showCreateView = true
                                }
                            })
                        } else {
                            // 문제 리스트
                            ProblemListView(
                                curriculumList: viewModel.todayProblem,
                                isPreview: false,
                                onCheckboxTapped: { item in
                                    // 체크박스 액션 처리
                                    viewModel.updateCompleteProblem(idx: item.idx)
                                },
                                onPlayTapped: { item in
                                    // 재생 버튼 액션 처리
                                    if let problemLink = URL(string: item.problemLink) {
                                        NSWorkspace.shared.open(problemLink)
                                    }
                                },
                                onSave: nil  // 필요 시 저장 로직
                            )
                            .frame(maxWidth: .infinity)
                            .background(Color.white)
                            .cornerRadius(16)
                            
                            Button(action: {
                                print("🔘 문제 추가하기 버튼 클릭")
                                if #available(macOS 13.0, *), let navPath = navigationPath {
                                    print("🚀 Using navigationPath closure")
                                    navPath()
                                } else {
                                    print("🔄 Using showCreateView")
                                    showCreateView = true
                                }
                            }) {
                                HStack {
                                    Image(systemName: "plus.circle.fill")
                                        .font(.system(size: 18))
                                    Text("문제 추가하기")
                                        .font(.system(size: 18, weight: .semibold))
                                }
                                .foregroundColor(.white)
                                .frame(height: 44)
                                .frame(maxWidth: .infinity)
                                .background(Color.blue)
                                .cornerRadius(22)
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                    .padding(20)
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
                .padding(.horizontal, geo.size.width * 0.05)  // 좌우 10% 여백
                .padding(.top, 32)
                .padding(.bottom, 60)
            }
            .background(Color.black)
        }
        .background(
            Group {
                if #available(macOS 13.0, *) {
                    EmptyView()
                } else {
                    NavigationLink(
                        destination: CurriculumCreateView(),
                        isActive: Binding(
                            get: { showCreateView || (shouldNavigateToCreate?.wrappedValue ?? false) },
                            set: { showCreateView = $0 }
                        ),
                        label: { EmptyView() }
                    )
                    .hidden()
                }
            }
        )
        .onAppear {
            viewModel.fetchTodayProblem()
            print("오늘의 문제 : \(viewModel.todayProblem)")
            
            // 위젯에서 들어올 경우 자동으로 CurriculumCreateView로 이동 (macOS 12.0)
            if !showCreateView, let shouldNavigate = shouldNavigateToCreate, shouldNavigate.wrappedValue {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    showCreateView = true
                }
            }
        }
    }
}

//#Preview {
//    MainView()
//}

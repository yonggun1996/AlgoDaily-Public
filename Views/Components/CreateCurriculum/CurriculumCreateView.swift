//
//  CurriculumCreateView.swift
//  AlgoDaily
//
//  Created by yonggun Park on 10/18/25.
//

import SwiftUI

struct CurriculumCreateView: View {
    @State private var selectedTab = 0
    
    @StateObject private var curriculumVM = CurriculumViewModel()
    
    var body: some View {
        VStack(spacing: 0) {
            // 상단 네비게이션 헤더
            NavigationHeaderView()
            
            // 커스텀 탭 바
            CustomTabBar(selectedTab: $selectedTab)
            
            // 탭 콘텐츠 (macOS 전용)
            Group {
                if selectedTab == 0 {
                    IndividualAddView(viewModel: curriculumVM)
                } else {
                    BulkImportView(viewModel: curriculumVM)
                }
            }
            .animation(.easeInOut(duration: 0.3), value: selectedTab)
        }
        .frame(minWidth: 600, minHeight: 500)
        .background(Color.black)
    }
}

#Preview {
    CurriculumCreateView()
}

//
//  SwiftUIView.swift
//  AlgoDailyWidgetExtension
//
//  Created by yonggun Park on 1/1/26.
//

import SwiftUI

/// 비어있는 문제 화면을 보여주기 위한 공통인터페이스 설계
/// 해당 브릿지는 App타겟에서만 연결되며 AppEmptyProblemView.swift에서 선언한 ui구현을
/// AlgoDailyWidget에서 문제가 없을 경우 이렇게 연결된 화면을 채우도록 구현
/// 공통 인터페이스, 타겟별 분리, 코드 일관성이라는 장점이 있음
typealias EmptyProblemView = WidgetEmptyProblemView

//
//  WidgetIntent.swift
//  AlgoDaily
//
//  Created by yonggun Park on 12/13/25.
//

import Foundation
import WidgetKit
import AppIntents

struct ConfigurationAppIntent: WidgetConfigurationIntent {
    static var title: LocalizedStringResource = "Configuration"
    static var description = IntentDescription("This is an example widget.")

    // An example configurable parameter.
    @Parameter(title: "Favorite Emoji", default: "😃")
    var favoriteEmoji: String
}

// ⭐ 추가: CurriculumCreateView를 여는 AppIntent
struct OpenCreateViewIntent: AppIntent {
    static var title: LocalizedStringResource = "문제 추가하기"
    static var description = IntentDescription("앱을 열고 문제 추가 화면으로 이동합니다.")
    
    func perform() async throws -> some IntentResult {
        // URL Scheme을 통해 앱 열기
        if let url = URL(string: "appscheme://create") {
            NSWorkspace.shared.open(url)
        }
        return .result()
    }
}

//
//  AlgoDailyWidget.swift
//  AlgoDailyWidget
//
//  Created by yonggun Park on 12/13/25.
//

import WidgetKit
import SwiftUI

struct Provider: TimelineProvider {
    typealias Entry = SimpleEntry
    
    func placeholder(in context: Context) -> SimpleEntry {
        // ⭐ 수정: 더미 데이터로 placeholder 생성
        SimpleEntry(
            date: Date(),
            todayProblems: [],
            completeCount: 0,
            problemCount: 0
        )
    }
    
    func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> Void) {
        // ⭐ 수정: 현재 데이터로 스냅샷 생성
        let (problems, completeCount, problemCount) = fetchTodayProblems()
        let entry = SimpleEntry(
            date: Date(),
            todayProblems: problems,
            completeCount: completeCount,
            problemCount: problemCount
        )
        completion(entry)
    }
    
    func getTimeline(in context: Context, completion: @escaping (Timeline<SimpleEntry>) -> Void) {
        // 오늘의 문제 데이터 가져오기
        let (problems, completeCount, problemCount) = fetchTodayProblems()
        
        let currentDate = Date()
        let entry = SimpleEntry(
            date: currentDate,
            todayProblems: problems,
            completeCount: completeCount,
            problemCount: problemCount
        )
        
        // 1시간마다 업데이트
        let nextUpdate = Calendar.current.date(byAdding: .hour, value: 1, to: currentDate)!
        let timeline = Timeline(entries: [entry], policy: .after(nextUpdate))
        print("get timeline")
        completion(timeline)
    }
    
    // ⭐ 추가: Realm에서 오늘의 문제 가져오기
    private func fetchTodayProblems() -> ([Curriculum], Int, Int) {
        do {
            let realmManager = RealmManager.shared
            let results = try realmManager.fetchTodayProblem()
            let problems = Array(results)
            let completeCount = problems.filter { $0.complete }.count
            let problemCount = problems.count
            
            return (problems, completeCount, problemCount)
        } catch {
            print("위젯 데이터 로드 실패: \(error)")
            return ([], 0, 0)
        }
    }
}

struct SimpleEntry: TimelineEntry {
    let date: Date
    let todayProblems: [Curriculum]
    let completeCount: Int
    let problemCount: Int
}

struct AlgoDailyWidgetEntryView : View {
    var entry: Provider.Entry

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("오늘의 문제")
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(.primary)
            
            if entry.problemCount == 0 {
                // ⭐ 수정: URL Scheme을 전달 (macOS 12.0 호환)
                EmptyProblemView(urlScheme: "appscheme://create")
                    .scaleEffect(0.7) // 위젯 크기에 맞게 축소
            } else {
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text("목표 달성도")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(.primary)
                        
                        Spacer()
                        
                        Text("\(entry.completeCount)/\(entry.problemCount)")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundColor(.gray)
                    }
                    
                    ProgressView(value: entry.problemCount > 0 ? Double(entry.completeCount) / Double(entry.problemCount) : 0)
                        .progressViewStyle(LinearProgressViewStyle(tint: .blue))
                    
                    // ⭐ ProblemListView 재사용 (위젯에서는 인터랙션 불가하므로 nil 전달)
                    ProblemListView(
                        curriculumList: Array(entry.todayProblems.prefix(3)), // 최대 3개만
                        isPreview: true, // 미리보기 모드로 설정 (버튼 비활성화)
                        onCheckboxTapped: nil, // 위젯에서는 클릭 불가
                        onPlayTapped: nil, // 위젯에서는 클릭 불가
                        onSave: nil
                    )
                    .frame(maxHeight: 150) // 위젯 크기에 맞게 높이 제한
                    
                    if entry.problemCount > 3 {
                        Text("+ \(entry.problemCount - 3)개 더...")
                            .font(.system(size: 10))
                            .foregroundColor(.gray)
                            .padding(.top, 4)
                    }
                }
                .padding(12)
                .background(Color(white: 0.1))
                .cornerRadius(12)
            }
        }
        .padding()
//        .widgetURL(URL(string: entry.problemCount == 0 ? "algodaily://create" : "algodaily://"))
    }
}

struct AlgoDailyWidget: Widget {
    let kind: String = "AlgoDailyWidget"

    var body: some WidgetConfiguration {
        // ⭐ 수정: StaticConfiguration 사용 (macOS 12.0 호환)
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            AlgoDailyWidgetEntryView(entry: entry)
                .containerBackground(.fill.tertiary, for: .widget)
        }
        .supportedFamilies([.systemLarge])
        .configurationDisplayName("오늘의 문제")
        .description("오늘 풀어야 할 문제를 확인하세요.")
    }
}

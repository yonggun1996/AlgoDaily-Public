//
//  Curriculum.swift
//  AlgoDaily
//
//  Created by yonggun Park on 11/8/25.
//

import Foundation
import RealmSwift

class Curriculum: Object, ObjectKeyIdentifiable {
    @Persisted(primaryKey: true) var idx: Int   // 인덱스
    @Persisted var problemNo: String            // 문제 번호
    @Persisted var problemName: String          // 문제이름
    @Persisted var problemLink: String          // 문제링크
    @Persisted var level: String                // 난이도
    @Persisted var complete: Bool               // 목표 달성 여부
    @Persisted var targetDate: Date?            // 신규 목표일 (1일 뒤)
    @Persisted var reviewCount: String          // 복습 차수
    @Persisted var createDate: Date             // 문제 생성일
    @Persisted var routineName: String          // 루틴이름 ex) BFS문제, 구현문제 등등
    
    // 초기화 편의 생성자
    convenience init(
        idx: Int,
        problemNo: String,
        problemName: String,
        problemLink: String,
        level: String,
        reviewCount: String,
        targetDate: Date?,
        createDate: Date,
        complete: Bool = false,
        routineName: String?
    ) {
        self.init()
        self.idx = idx
        self.problemNo = problemNo
        self.problemName = problemName
        self.problemLink = problemLink
        self.level = level
        self.reviewCount = reviewCount
        self.targetDate = targetDate
        self.complete = complete
        self.createDate = Date()
        self.routineName = routineName ?? ""
    }
    
    /// 신규, 1차, 2차, 3차 복습 회차를 모두 생성하는 정적 팩토리 메서드
    /// - Parameters:
    ///   - startIdx: 시작 인덱스 (신규 회차의 idx)
    ///   - problemNo: 문제 번호
    ///   - problemName: 문제 이름
    ///   - problemLink: 문제 링크
    ///   - level: 난이도
    /// - Returns: 생성된 Curriculum 객체 배열 (신규, 1차, 2차, 3차 순서)
    static func createAllReviewStages(
        startIdx: Int,
        problemNo: String,
        problemName: String,
        problemLink: String,
        level: String
    ) -> [Curriculum] {
        let calendar = Calendar.current
        let createDate = Date()
        
        // 각 회차별 설정: (reviewCount, 날짜 추가 일수)
        let reviewSettings: [(String, Int)] = [
            ("신규", 1),
            ("1차", 3),
            ("2차", 7),
            ("3차", 30)
        ]
        
        return reviewSettings.enumerated().map { index, setting in
            let (reviewCount, daysToAdd) = setting
            let targetDate = calendar.date(byAdding: .day, value: daysToAdd, to: createDate)
            
            return Curriculum(
                idx: startIdx + index,
                problemNo: problemNo,
                problemName: problemName,
                problemLink: problemLink,
                level: level,
                reviewCount: reviewCount,
                targetDate: targetDate,
                createDate: createDate,
                routineName: nil
            )
        }
    }
}

public struct ProblemDTO: Codable {
    let problemNo: String
    let problemName: String
    let problemLink: String
    let level: String
}

struct JSONFile: Identifiable {
    let id = UUID()
    let url: URL
    let name: String
    let content: String
    
    init(url: URL, content: String) {
        self.url = url
        self.name = url.lastPathComponent
        self.content = content
    }
}

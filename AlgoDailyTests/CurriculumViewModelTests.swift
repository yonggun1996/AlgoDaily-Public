//
//  CurriculumViewModelTests.swift
//  AlgoDailyTests
//
//  Created by yonggun Park on 12/6/25.
//

import XCTest
import RealmSwift
@testable import AlgoDaily

final class CurriculumViewModelTests: XCTestCase {
    
    var viewModel: CurriculumViewModel!
    var testRealm: Realm!

    @MainActor override func setUpWithError() throws {
        // 테스트용 Realm 설정 (인메모리)
        let config = Realm.Configuration(
            inMemoryIdentifier: "test-realm",
            schemaVersion: 3,
            deleteRealmIfMigrationNeeded: true
        )
        Realm.Configuration.defaultConfiguration = config
        
        testRealm = try Realm()
        
        // ViewModel 초기화
        viewModel = CurriculumViewModel()
    }

    override func tearDownWithError() throws {
        viewModel = nil
        testRealm = nil
    }

    func testExample() throws {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        // Any test you write for XCTest can be annotated as throws and async.
        // Mark your test throws to produce an unexpected failure when your test encounters an uncaught error.
        // Mark your test async to allow awaiting for asynchronous code to complete. Check the results with assertions afterwards.
    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    
    // MARK: 텍스트 일괄추가 올바르게 입력한 경우
    @MainActor func testBulkAddFromText_ValidJSON() throws {
        let validJSON = """
        [
          {
            "problemNo": "1000",
            "problemName": "A+B",
            "problemLink": "https://www.acmicpc.net/problem/1000",
            "level": "브론즈"
          },
          {
            "problemNo": "1001",
            "problemName": "A-B",
            "problemLink": "https://www.acmicpc.net/problem/1001",
            "level": "브론즈"
          }
        ]
        """
        
        viewModel.bulkAddFromText(text: validJSON)
        
        // 에러가 없어야 함
        XCTAssertNil(viewModel.errorMessage, "유효한 JSON은 에러가 없어야 합니다")
        
        // 2개 문제 × 4개 회차 = 8개 Curriculum이 생성되어야 함
        XCTAssertEqual(viewModel.curricula.count, 8, "2개 문제는 8개 회차로 생성되어야 합니다")
    }
    
    // MARK: - 유효하지 않은 JSON 테스트
    @MainActor func testBulkAddFromText_InvalidJSON() throws {
        let invalidJSON = "이것은 유효하지 않은 JSON입니다"
        
        viewModel.bulkAddFromText(text: invalidJSON)
        
        // 에러 메시지가 설정되어야 함
        XCTAssertNotNil(viewModel.errorMessage, "유효하지 않은 JSON은 에러 메시지가 있어야 합니다")
        XCTAssertTrue(viewModel.errorMessage?.contains("유효하지 않은 json") == true)
    }
    
    // MARK: - 빈 배열 테스트
    @MainActor func testBulkAddFromText_EmptyArray() throws {
        let emptyJSON = "[]"
        
        viewModel.bulkAddFromText(text: emptyJSON)
        
        // 에러 메시지가 설정되어야 함
        XCTAssertNotNil(viewModel.errorMessage, "빈 배열은 에러 메시지가 있어야 합니다")
        XCTAssertTrue(viewModel.errorMessage?.contains("추가할 수 있는 문제가 없습니다") == true)
    }
    
    // MARK: - 잘못된 JSON 형식 테스트
    @MainActor func testBulkAddFromText_MalformedJSON() throws {
        let malformedJSON = """
        {
          "problemNo": "1000",
          "problemName": "A+B"
        }
        """
        
        viewModel.bulkAddFromText(text: malformedJSON)
        
        // 에러 메시지가 설정되어야 함
        XCTAssertNotNil(viewModel.errorMessage, "잘못된 JSON 형식은 에러 메시지가 있어야 합니다")
    }
    
    // MARK: 텍스트 일괄추가 필드명 일부가 틀릴 경우
    @MainActor func testBulkAddFromText_PartialFieldMismatch() throws {
        let validJSON = """
        [
          {
            "id": "1000",
            "problemName": "A+B",
            "problemLink": "https://www.acmicpc.net/problem/1000",
            "level": "브론즈"
          },
          {
            "problemNo": "1001",
            "problemName": "A-B",
            "link": "https://www.acmicpc.net/problem/1001",
            "level": "브론즈"
          }
        ]
        """
        
        viewModel.bulkAddFromText(text: validJSON)
        
        // 에러가 없어야 함
        XCTAssertNotNil(viewModel.errorMessage, "유효한 JSON은 에러가 없어야 합니다")
        print(viewModel.errorMessage ?? "")
    }
    
    @MainActor func testBulkAddFromText_Exceeds300Problems() async throws {
        var problems: [[String: String]] = []
        for i in 1...301 {
            problems.append([
                "problemNo": "\(i)",
                "problemName": "Problem \(i)",
                "problemLink": "https://www.acmicpc.net/problem/\(i)",
                "level": "브론즈"
            ])
        }
        
        let jsonData = try JSONSerialization.data(withJSONObject: problems)
        let jsonString = String(data: jsonData, encoding: .utf8)!
        
        await MainActor.run {
            viewModel.bulkAddFromText(text: jsonString)
        }
        
        XCTAssertNotNil(viewModel.errorMessage)
        print(viewModel.errorMessage ?? "")
        XCTAssertTrue(viewModel.errorMessage?.contains("300개까지") == true)
    }

}

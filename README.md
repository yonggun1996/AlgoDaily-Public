# AlgoDaily 프로젝트 구조

> 알고리즘 문제 반복 학습을 위한 macOS 애플리케이션

## 📁 프로젝트 구성

### 1️⃣ Models
**데이터 모델 정의**

- `Curriculum.swift`: 알고리즘 문제 데이터 모델
  - Realm Object 기반 영속성 모델
  - 문제 번호, 이름, 링크, 난이도, 복습 차수(신규/1차/2차/3차) 등 관리
  - `createAllReviewStages()`: 한 문제에 대한 4단계 복습 자동 생성 (1일, 3일, 7일, 30일 간격)
  - `ProblemDTO`: JSON 파싱용 데이터 전송 객체

**주요 특징**
- 에빙하우스 망각곡선 기반 복습 주기 설정
- 문제별 목표일 자동 계산
- 루틴 분류 지원 (BFS, 구현, DP 등)

---

### 2️⃣ Repository
**데이터 영속성 계층**

- `RealmManager.swift`: Realm 데이터베이스 관리 싱글톤
  - CRUD 작업 전담
  - 오늘의 문제 조회 (`fetchTodayProblem()`)
  - 자동 idx 관리 및 캐싱
  - 실시간 데이터 변경 감지 (NotificationToken)
  - 스키마 버전 관리

**설계 패턴**
- Singleton 패턴으로 전역 접근성 보장
- Repository 패턴으로 데이터 레이어 분리
- Observer 패턴으로 실시간 동기화

---

### 3️⃣ ViewModel
**비즈니스 로직 및 상태 관리**

- `CurriculumViewModel.swift`: SwiftUI 뷰와 데이터 레이어 중재
  - `@Published` 프로퍼티로 뷰 자동 업데이트
  - 오늘의 문제 실시간 관찰 (`observeTodayProblem()`)
  - JSON/텍스트 파일 파싱 및 미리보기
  - 개별/일괄 문제 추가 로직
  - 문제 완료 상태 토글

**주요 기능**
- Combine 프레임워크 기반 반응형 상태 관리
- Realm 데이터 변경 시 자동 UI 동기화
- 파일 import 지원 (JSON, TXT)

---

### 4️⃣ Views
**사용자 인터페이스**

#### 메인 화면
- `MainView.swift`: 오늘의 문제 대시보드
  - 목표 달성도 진행바
  - 문제 리스트 및 체크박스
  - 문제 추가 버튼

- `OnbordingView.swift`: 첫 실행 시 온보딩 화면

#### 문제 추가
- `CurriculumCreateView.swift`: 문제 추가 탭 컨테이너
  - `IndividualAddView`: 개별 문제 추가 폼
  - `BulkImportView`: JSON/TXT 파일 일괄 등록

#### 네비게이션
- `AlgoDailyApp.swift`: 앱 진입점 및 라우팅
  - macOS 12.0/13.0+ 버전 대응 (NavigationView/NavigationStack)
  - URL Scheme 딥링크 처리 (`algodaily://create`)
  - 위젯에서 앱으로 화면 전환

**기술 스택**
- SwiftUI 기반 선언형 UI
- GeometryReader로 반응형 레이아웃
- macOS 버전별 조건부 컴파일

---

### 5️⃣ AlgoDailyWidget
**macOS 위젯 확장**

- `AlgoDailyWidget.swift`: 위젯 메인 로직
  - Timeline Provider로 1시간마다 자동 갱신
  - Realm 데이터 직접 조회
  - 오늘의 문제 개수 및 달성도 표시

- `WidgetIntent.swift`: App Intent 정의
  - `ConfigurationAppIntent`: 위젯 설정
  - `OpenCreateViewIntent`: 위젯 클릭 시 문제 추가 화면으로 딥링크

**특징**
- Shared App Group으로 앱-위젯 데이터 공유
- 위젯에서 앱 특정 화면으로 바로 이동

---

### 6️⃣ AlgoDailyTests
**단위 테스트**

- `CurriculumViewModelTests.swift`: ViewModel 로직 검증
  - 문제 추가/삭제 테스트
  - 파일 파싱 테스트
  - 날짜 계산 정확성 검증

**테스트 전략**
- XCTest 프레임워크 사용
- Mock 데이터로 Realm 의존성 분리
- 비동기 작업 테스트 (async/await)

---

## 🛠 기술 스택

| 분야 | 기술 |
|------|------|
| 언어 | Swift 5.0+ |
| UI | SwiftUI (macOS 12.0+) |
| 데이터베이스 | RealmSwift |
| 아키텍처 | MVVM + Repository Pattern |
| 상태관리 | Combine + ObservableObject |
| 위젯 | WidgetKit + App Intents |
| 테스트 | XCTest |

---

## 📊 아키텍처 다이어그램

```
┌─────────────────────────────────────────────────┐
│                   Views                          │
│  (MainView, CreateView, OnboardingView)         │
└────────────────┬────────────────────────────────┘
                 │ @ObservedObject
┌────────────────▼────────────────────────────────┐
│              ViewModel                           │
│        (CurriculumViewModel)                     │
│     - @Published properties                      │
│     - Business logic                             │
└────────────────┬────────────────────────────────┘
                 │
┌────────────────▼────────────────────────────────┐
│             Repository                           │
│          (RealmManager)                          │
│     - CRUD operations                            │
│     - Data caching                               │
└────────────────┬────────────────────────────────┘
                 │
┌────────────────▼────────────────────────────────┐
│              Models                              │
│           (Curriculum)                           │
│     - Realm Object                               │
│     - Data structure                             │
└─────────────────────────────────────────────────┘
```

---

## 🎯 핵심 기능

1. **간격 반복 학습**: 에빙하우스 망각곡선 기반 복습 주기 (1일, 3일, 7일, 30일)
2. **오늘의 문제**: 목표일이 오늘인 문제만 필터링하여 표시
3. **진행도 추적**: 실시간 목표 달성률 시각화
4. **일괄 등록**: JSON/TXT 파일로 여러 문제 한 번에 추가
5. **위젯 연동**: 데스크탑에서 빠르게 오늘의 문제 확인
6. **딥링크**: 위젯 → 앱 특정 화면 직접 이동

---

## 📝 코드 컨벤션

- **명명규칙**: Swift API Design Guidelines 준수
- **주석**: 복잡한 로직에만 선택적으로 사용
- **파일구조**: 기능별 폴더 분리 (Models, Views, ViewModels, Repository)
- **버전 대응**: `@available` 속성으로 macOS 12.0/13.0+ 분기

---

## 🚀 실행 방법

```bash
# Realm 의존성 설치
pod install  # 또는 Swift Package Manager

# Xcode에서 실행
open AlgoDaily.xcworkspace
⌘ + R
```

---

**개발자**: yonggun Park  
**개발 기간**: 2025년 10월 ~ 12월  
**플랫폼**: macOS 12.0+

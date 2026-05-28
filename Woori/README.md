# Woori (우리) - 커플 전용 iOS 앱

커플 둘만을 위한 특별한 공간. SwiftUI + Firebase 기반의 iOS 앱입니다.

## 주요 기능

| 기능 | 설명 |
|------|------|
| **홈** | D+N 카운터, 오늘의 한마디, 빠른 통계 |
| **기념일** | 사귄 날 자동 등록, 커스텀 기념일, D-day 뱃지 |
| **편지** | 실시간 편지 주고받기, 읽음 확인 |
| **우리 지도** | 데이트 장소 저장, 카테고리별 마커, 코스 경로 표시 |
| **데이트 코스** | 코스 계획, 장소 순서 관리, 방문 체크 |
| **가계부** | 지출 기록, 월별 통계, 더치페이 잔액 계산 |

## 기술 스택

- **UI**: SwiftUI (UIKit 미사용)
- **최소 iOS**: 17.0+
- **언어**: Swift 5.9
- **아키텍처**: MVVM + Repository Pattern
- **백엔드**: Firebase (Anonymous Auth + Firestore)
- **지도**: MapKit (SwiftUI Map API)
- **동시성**: Swift Concurrency (async/await)
- **패키지**: Swift Package Manager

## 프로젝트 설정

### 1. Firebase 프로젝트 생성

1. [Firebase Console](https://console.firebase.google.com)에서 새 프로젝트 생성
2. iOS 앱 추가 (Bundle ID: `com.yourname.Woori`)
3. `GoogleService-Info.plist` 다운로드
4. 다운로드한 파일을 `Woori/Resources/` 폴더에 추가

### 2. Firebase 서비스 활성화

**Authentication:**
- Firebase Console → Authentication → Sign-in method
- "Anonymous" 활성화

**Firestore:**
- Firebase Console → Firestore Database → Create Database
- 보안 규칙 설정:

```
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /couples/{coupleId}/{document=**} {
      allow read, write: if request.auth != null;
    }
  }
}
```

### 3. Xcode 프로젝트 설정

1. Xcode에서 프로젝트 열기
2. **SPM 패키지 추가:**
   - File → Add Package Dependencies
   - URL: `https://github.com/firebase/firebase-ios-sdk`
   - 선택 제품: `FirebaseAuth`, `FirebaseFirestore`, `FirebaseMessaging`

3. **Capabilities 추가:**
   - Signing & Capabilities → + Capability
   - `Push Notifications`
   - `Background Modes` → Remote notifications 체크

4. **Info.plist 추가:**
   ```xml
   <key>NSLocationWhenInUseUsageDescription</key>
   <string>데이트 장소를 저장하기 위해 위치 접근이 필요합니다</string>
   ```

5. `GoogleService-Info.plist`을 Xcode 프로젝트에 드래그하여 추가
   - "Copy items if needed" 체크
   - Target Membership에 Woori 체크

### 4. 빌드 & 실행

```bash
# Xcode에서 열기
open Woori.xcodeproj

# 또는 SPM resolve 후 빌드
xcodebuild -resolvePackageDependencies
xcodebuild build -scheme Woori -destination 'platform=iOS Simulator,name=iPhone 15'
```

## 프로젝트 구조

```
Woori/
├── App/                    # 앱 진입점, TabRouter, ContentView
├── Core/
│   ├── Models/             # Firestore 데이터 모델 (Codable)
│   ├── Repositories/       # Protocol + Firebase 구현체
│   ├── Services/           # Auth, Firestore, Notification, Map
│   └── Utils/              # DateHelper, CoupleSession, Constants
├── Features/
│   ├── Setup/              # 첫 실행 커플 설정
│   ├── Home/               # 홈 (D-day, 오늘의 한마디, 통계)
│   ├── Anniversary/        # 기념일 관리
│   ├── Letters/            # 편지 주고받기
│   ├── Map/                # 우리 지도
│   └── Date/               # 데이트 코스 + 가계부
├── SharedUI/               # 공통 컴포넌트 & 모디파이어
├── DesignSystem/           # 색상, 타이포그래피, 간격
└── Resources/              # GoogleService-Info.plist, Assets
```

## 앱 사용 흐름

1. 앱 실행 → Firebase 익명 로그인 (자동)
2. 한 명이 "커플 시작하기" → 6자리 코드 생성 → 코드 공유
3. 상대방이 "코드 입력하기" → 코드 입력 → 커플 연결 완료
4. 이후 모든 데이터는 coupleKey 기준으로 공유

## 빌드 주의사항

- **iOS 17+** 필수 (Map API, Observation 등)
- `GoogleService-Info.plist` 없으면 Firebase 초기화 실패
- Firebase Anonymous Auth가 Console에서 활성화되어야 함
- 시뮬레이터에서는 Push Notification 미지원 (로컬 알림은 동작)
- 실기기 테스트 시 Apple Developer Account 필요

## 라이선스

MIT License

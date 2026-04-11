# Woori - 커플 전용 iOS 앱

SwiftUI + Firebase 기반의 커플 전용 iOS 앱입니다.

## 요구 사항

- Xcode 15.0+
- iOS 17.0+
- Swift 5.9+
- Firebase 프로젝트

## 설치 및 실행

### 1. Xcode 프로젝트 생성

1. Xcode → File → New → Project → iOS App
2. Product Name: `Woori`
3. Interface: SwiftUI
4. Language: Swift
5. Minimum Deployments: iOS 17.0

### 2. 프로젝트에 소스 파일 추가

`Woori/` 폴더 내의 모든 Swift 파일을 Xcode 프로젝트에 드래그하여 추가합니다.

### 3. SPM 패키지 추가

Xcode → File → Add Package Dependencies:

| 패키지 | URL | 버전 |
|--------|-----|------|
| Firebase iOS SDK | `https://github.com/firebase/firebase-ios-sdk` | 11.x |
| Kingfisher (선택) | `https://github.com/onevcat/Kingfisher` | 7.x |

Firebase SDK에서 다음 제품을 선택합니다:
- FirebaseAuth
- FirebaseFirestore
- FirebaseStorage
- FirebaseMessaging

### 4. Firebase 설정

1. [Firebase Console](https://console.firebase.google.com)에서 새 프로젝트 생성
2. iOS 앱 추가 (Bundle ID 입력)
3. `GoogleService-Info.plist` 다운로드
4. Xcode 프로젝트의 `Woori/Resources/`에 추가

### 5. Firebase Console에서 활성화할 서비스

- **Authentication**: Email/Password 로그인 활성화
- **Cloud Firestore**: 데이터베이스 생성 (아시아 리전 권장)
- **Storage**: 이미지 저장소 활성화
- **Cloud Messaging**: 푸시 알림 설정

### 6. Firestore 보안 규칙

```
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /couples/{coupleId} {
      allow read, write: if request.auth != null &&
        (resource.data.user1Id == request.auth.uid ||
         resource.data.user2Id == request.auth.uid);

      match /{subcollection}/{docId} {
        allow read, write: if request.auth != null;
      }
    }
  }
}
```

### 7. Xcode 설정

- Signing & Capabilities → Push Notifications 추가
- Signing & Capabilities → Background Modes → Remote notifications 체크
- Info.plist → Privacy - Location When In Use Usage Description 추가

### 8. 빌드 및 실행

1. 실제 기기 또는 시뮬레이터 선택
2. `Cmd + R`로 빌드 및 실행

## 아키텍처

```
MVVM + Repository Pattern
├── Models (Codable Structs)
├── Repositories (Protocol + Firebase 구현체)
├── ViewModels (@MainActor, async/await)
└── Views (SwiftUI)
```

## 주요 기능

- **홈**: D-day 카드, 오늘의 한마디, 빠른 통계
- **기념일**: 기념일 등록/관리, D-day 카운트다운
- **갤러리**: 사진 업로드/관리, 장소별 필터링
- **편지**: 실시간 편지 주고받기, 푸시 알림
- **지도**: 데이트 장소 저장, 카테고리별 마커

## 빌드 시 주의사항

1. `GoogleService-Info.plist`가 반드시 프로젝트에 포함되어야 합니다
2. 푸시 알림 테스트는 실제 기기에서만 가능합니다
3. 지도 기능은 위치 권한이 필요합니다
4. 이미지 업로드 시 자동으로 1MB 이하로 압축됩니다

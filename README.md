# TCMPushSolution SDK

iOS 푸시 알림 SDK - Firebase Cloud Messaging(FCM) 기반의 푸시 알림 통합 솔루션

## 개요

TCMPushSolution은 iOS 앱에서 푸시 알림을 쉽게 구현할 수 있도록 도와주는 SDK입니다. Firebase Messaging을 래핑하여 디바이스 등록, 푸시 수신 처리, 토픽 구독 관리 등의 기능을 제공합니다.

### 주요 기능

- 디바이스 등록 및 관리
- 푸시 알림 수신 및 처리
- 토픽 구독/해지 관리
- 푸시 알림함 조회
- Rich Push (이미지 첨부) 지원
- AES 암호화 기반 보안

## 요구사항

| 항목 | 버전 |
|------|------|
| iOS | 16.0+ |
| Swift | 5.0+ |
| Xcode | 14.0+ |
| Firebase Messaging | 12.0.0+ |

## 설치

### Swift Package Manager (SPM)

1. Xcode에서 **File > Add Package Dependencies...** 선택
2. 패키지 URL 입력:
   ```
   http://211.62.111.247:7100/tcm/ios-sdk.git
   ```
3. **Add Package** 클릭

또는 `Package.swift`에 직접 추가:

```swift
dependencies: [
    .package(url: "http://211.62.111.247:7100/tcm/ios-sdk.git", from: "0.1.0")
]
```

## 설정

### 1. Info.plist 설정

앱의 `Info.plist`에 다음 키를 추가합니다:

```xml
<!-- 필수 설정 -->
<key>CompanyID</key>
<string>YOUR_COMPANY_ID</string>

<key>SysCd</key>
<string>YOUR_SYSTEM_CODE</string>

<!-- 서버 URL -->
<key>DEV_SERVER</key>
<string>https://dev.example.com</string>

<key>PRD_SERVER</key>
<string>https://api.example.com</string>
```

### 2. Firebase 설정

1. Firebase Console에서 iOS 앱 등록
2. `GoogleService-Info.plist` 파일 다운로드
3. Xcode 프로젝트에 파일 추가

### 3. Capabilities 설정

Xcode에서 다음 Capabilities를 활성화합니다:

- **Push Notifications**
- **Background Modes > Remote notifications**

## 빠른 시작

### 1. AppDelegate 설정

```swift
import UIKit
import TCMPushSolution

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {

        // SDK 초기화
        TCMPush.shared.initializePushConfig(
            authorizationOptions: [.alert, .badge, .sound],
            serverType: .dev  // 또는 .prd
        )

        // Delegate 설정
        TCMPush.shared.pushDelegate = self
        UNUserNotificationCenter.current().delegate = TCMPush.shared

        // 디버그 모드 (개발 시에만)
        TCMPush.shared.setDebugModeEnable(debugMode: true)

        return true
    }

    // APNS 토큰 수신
    func application(_ application: UIApplication,
                     didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        TCMPush.shared.setApnsToken(deviceToken)
    }

    // APNS 등록 실패
    func application(_ application: UIApplication,
                     didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("APNS 등록 실패: \(error.localizedDescription)")
    }
}
```

### 2. 푸시 수신 Delegate 구현

```swift
extension AppDelegate: TCMPushMessageDelegate {

    // Foreground에서 푸시 수신 시
    func willPresentReceiveInfo(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                userId: String,
                                deviceId: String,
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        print("Foreground 푸시 수신")
        print("userId: \(userId), deviceId: \(deviceId)")

        // 알림 표시 (iOS 14+)
        completionHandler([.banner, .sound, .badge])
    }

    // Background에서 푸시 탭 시
    func didReceiveInfo(_ center: UNUserNotificationCenter,
                        didReceive response: UNNotificationResponse,
                        userId: String,
                        deviceId: String,
                        withCompletionHandler completionHandler: @escaping () -> Void) {
        print("Background 푸시 탭")
        print("userId: \(userId), deviceId: \(deviceId)")

        // 푸시 데이터 처리
        let userInfo = response.notification.request.content.userInfo
        // ... 화면 이동 등 처리

        completionHandler()
    }
}
```

### 3. 디바이스 등록

```swift
// 로그인 시 사용자 ID와 함께 등록
TCMPush.shared.registeredUserIdWithDevice(
    userId: "user123",
    apnsPushToken: TCMPush.shared.getApnsToken(),
    fcmPushToken: TCMPush.shared.getFcmToken(),
    pushReceiveYn: "Y",
    marketingAgreeYn: "Y",
    nightNotiYn: "N"
) { success, response in
    if success {
        print("디바이스 등록 성공")
    } else {
        print("디바이스 등록 실패: \(response)")
    }
}
```

### 4. 토픽 구독

```swift
// 토픽 구독/해지
let topics = [
    TCMTopicInfo(topicName: "news", topicYn: "Y"),    // 구독
    TCMTopicInfo(topicName: "promo", topicYn: "N")   // 해지
]

TCMPush.shared.manageTopic(topics: topics) { success, response in
    if success {
        print("토픽 설정 완료")
    }
}

// async/await 버전
Task {
    let response = try await TCMPush.shared.manageTopic(topics: topics)
    print("토픽 설정: \(response.rsltCd)")
}
```

## Rich Push (이미지 첨부)

푸시 알림에 이미지를 첨부하려면 Notification Service Extension을 설정해야 합니다.

### 1. Extension 생성

Xcode에서:
1. **File > New > Target**
2. **Notification Service Extension** 선택
3. Product Name 입력 (예: `PushExtensionService`)

### 2. Extension 코드 작성

```swift
import UserNotifications
import TCMPushSolution

class NotificationService: UNNotificationServiceExtension {

    var contentHandler: ((UNNotificationContent) -> Void)?
    var bestAttemptContent: UNMutableNotificationContent?

    override func didReceive(_ request: UNNotificationRequest,
                             withContentHandler contentHandler: @escaping (UNNotificationContent) -> Void) {
        self.contentHandler = contentHandler
        self.bestAttemptContent = request.content.mutableCopy() as? UNMutableNotificationContent

        // SDK 헬퍼 사용
        TCMNotificationHelper.processNotification(request: request) { content in
            contentHandler(content)
        }
    }

    override func serviceExtensionTimeWillExpire() {
        if let contentHandler = contentHandler,
           let bestAttemptContent = bestAttemptContent {
            contentHandler(bestAttemptContent)
        }
    }
}
```

### 3. Extension에 SDK 연결

Extension 타겟의 **Build Phases > Link Binary With Libraries**에 `TCMPushSolution.xcframework` 추가

### 4. 푸시 페이로드

```json
{
  "aps": {
    "alert": {
      "title": "새 소식",
      "body": "이미지가 포함된 알림입니다."
    },
    "mutable-content": 1
  },
  "contentImgurl": "https://example.com/image.jpg"
}
```

## 주요 클래스

| 클래스 | 설명 |
|--------|------|
| `TCMPush` | SDK 메인 클래스 (싱글톤) |
| `TCMNotificationHelper` | Rich Push 헬퍼 |
| `TCMConfiguration` | 설정 상수 |
| `TCMTopicInfo` | 토픽 정보 모델 |

## 주요 메서드

```swift
// 초기화
TCMPush.shared.initializePushConfig(authorizationOptions:serverType:)

// 사용자 관리
TCMPush.shared.setUserId(value:)
TCMPush.shared.getUserId() -> String
TCMPush.shared.setLogoff()

// 디바이스 등록
TCMPush.shared.registeredDevice(...)
TCMPush.shared.registeredUserIdWithDevice(...)

// 토픽 관리
TCMPush.shared.saveTopic(topics:) async throws -> TCMBaseResponse
TCMPush.shared.checkTopic() async throws -> TCMTopicListResponse
TCMPush.shared.manageTopic(topics:) async throws -> TCMBaseResponse

// 푸시 설정
TCMPush.shared.setPushEnabled(_:) async throws -> TCMBaseResponse
TCMPush.shared.getPushList() async throws -> TCMPushListResponse
```

## 문제 해결

### FCM 토큰이 없는 경우

Firebase 초기화가 완료되지 않았을 수 있습니다. `GoogleService-Info.plist` 파일이 올바르게 추가되었는지 확인하세요.

### 푸시가 수신되지 않는 경우

1. APNS 인증서/키가 Firebase에 등록되어 있는지 확인
2. `registerForRemoteNotifications()` 호출 확인
3. 디바이스가 정상적으로 등록되었는지 확인

### Rich Push 이미지가 표시되지 않는 경우

1. `mutable-content: 1` 플래그가 페이로드에 포함되어 있는지 확인
2. Extension이 앱과 동일한 App Group을 사용하는지 확인
3. 이미지 URL이 HTTPS인지 확인

## 버전 히스토리

- **v0.1.0** - 초기 테스트 릴리스
  - 디바이스 등록 및 푸시 수신
  - 토픽 구독/해지
  - Rich Push 지원
  - NotificationService Extension 헬퍼

## 라이선스

Copyright (c) 2026 TA9. All rights reserved.

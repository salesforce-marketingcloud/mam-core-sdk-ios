# Mobile App Messaging SDK - LearningApp Examples

Example apps demonstrating configuration and implementation best practices for the Salesforce Mobile App Messaging (MAM) iOS SDKs.

This bundle includes three app variants:

| Variant | Scheme | Description |
|---------|--------|-------------|
| **LearningApp** | `LearningApp` | Full SDK integration (MCE + MAM + Push + In-App Messaging) |
| **LearningAppMPP** | `LearningAppMPP` | Full SDK integration with Firebase Cloud Messaging |
| **LearningAppMAM** | `LearningAppMAM` | Mobile App Messaging only (no Marketing Cloud Engagement) |

Choose the variant that matches your integration needs. If you are using both MAM and MCE, start with **LearningApp**. If you only need mobile app messaging features, use **LearningAppMAM**.

## Features Demonstrated

* Configuring the SDK with SFMC credentials
* Enabling push notifications
* Supporting Rich Push via Notification Service and Content Extensions
* Handling Marketing Cloud push URLs
* Setting contact values via SDK registration
* Logging SDK diagnostic information via sdkState
* In-App Message callbacks
* App inbox messaging
* Custom event tracking
* Mobile App Messaging integration (LearningApp, LearningAppMPP, and LearningAppMAM)

## Requirements

* Xcode 16+
* iOS 12.0+
* [CocoaPods](https://cocoapods.org/)

## Setup

1. Clone or download the repository.

2. Navigate to the examples directory and install CocoaPods dependencies:

        $ cd <path to>/examples
        $ pod install

3. Open the workspace in Xcode:

        $ open LearningAppBundle.xcworkspace

4. Open `AppDelegate.swift` in the variant you want to run and replace the placeholder values for `appId`, `accessToken`, `appEndpoint`, and `mid`. Find these values on the MobilePush Administration screen in Marketing Cloud.

        let appID = "<your appID here>"
        let accessToken = "<your accessToken here>"
        let appEndpoint = URL(string: "<your appEndpoint here>")!
        let mid = "<your account MID here>"

5. Select the desired scheme in Xcode (e.g., `LearningApp`, `LearningAppMAM`, or `LearningAppMPP`).

6. In the Project Editor, select the app target. On the General tab, set your unique Bundle Identifier and Signing values.

7. Build and run.

### LearningAppMPP (Firebase variant)

The LearningAppMPP variant requires a Firebase project. Before building:

1. Create a Firebase project at https://console.firebase.google.com/
2. Download `GoogleService-Info.plist` and add it to the `LearningAppMPP` target in Xcode.
3. Add the Firebase pod to the Podfile (see the `#Add firebase Pod` comment) and run `pod install` again.

## Documentation

* [Mobile App Messaging iOS SDK Documentation](https://developer.salesforce.com/docs/marketing/mobile-messaging-sdks/guide/mam-sdk-intro.html)
* [API Reference (Appledoc)](https://salesforce-marketingcloud.github.io/MarketingCloudSDK-iOS/docs/appledocs.html)

## iOS SDK Development Notes

* **Development builds** (debugging to a connected device): Use an Apple Push Notification service SSL (Sandbox) certificate on the MobilePush Administration screen in Marketing Cloud.
* **Production builds** (TestFlight, enterprise distribution): Use an Apple Push Notification service SSL (Sandbox & Production) certificate.
* **Simulator**: Push notifications and inbox messages are not delivered from Marketing Cloud when running in a simulator.
* To create certificates, review Apple's documentation: https://help.apple.com/developer-account/#/dev82a71386a

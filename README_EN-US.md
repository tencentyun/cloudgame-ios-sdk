[中文文档](README.md)
# Tencent cloud rendering for iOS
## I.Introduction
This project provides a simple application example of integrating the Formos SDK, allowing you to quickly experience the running effect of the cloud rendering.

At the same time, it also provides a quick start integration guide to help you quickly complete the access of the iOS SDK.

If you need to implement some advanced functions, we also provide advanced guidance.

## II、Quick start
1、Experience Cloud Rendering Quickly

Enter the project directory under Demo, run **pod install** to install the SDK library files, then open the generated **.xcworkspace** (not the .xcodeproj) and run it to quickly experience the Cloud Rendering example. Once the SDK library files are updated, run **pod update**.

2、Virtual key quick start

If you need to integrate a flexible and configurable game button layout in your application, please refer to[VirtualKeyQuickStart](Doc/Virtual_Key_Quick_Start_EN-US.md)。

## III、SDK integrated

### Integration Method
Add the following to your Podfile:

```pod 'TCRSDK', :git => "https://github.com/tencentyun/cloudgame-ios-sdk.git"```

Optional library for virtual keys
```pod 'TCRVKey', :git => "https://github.com/tencentyun/cloudgame-ios-sdk.git"```

### Package Size
The total size of the iOS framework is approximately 7MB.

### Version
We will regularly update the SDK's features, and you can obtain the latest version in the SDK directory of this project.

You can also check the SDK's release history to understand the changes in each version.


## IV、See also
[CAR](https://www.tencentcloud.com/document/product/1158)  
[API DOC](https://tencentyun.github.io/cloudgame-ios-sdk/)



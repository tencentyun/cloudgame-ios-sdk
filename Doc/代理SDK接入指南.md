# TcrProxy iOS SDK 接入说明

本文档介绍如何通过 TcrProxy iOS SDK，将本地 iOS 设备变成云端实例的网络代理，实现访问客户端网络的能力。适用于访问局域网 NAS 等设备场景。

## 接入声明

> **重要提示：**  
> 当代理功能开启后，云端实例的所有网络访问流量将会经由本地客户端设备转发，即“云端应用请求 → 互联网 → 真机客户端 → 互联网 → 真机客户端 → 互联网 → 云端应用响应”。  
> 由于链路较长，并且受限于客户端设备的上行带宽，极有可能导致云端实例访问网页时出现卡顿、延迟甚至无法联网等问题。请务必根据实际网络环境评估代理能力，避免因带宽瓶颈影响业务体验。

## 目录

- [功能简介](#功能简介)
- [集成准备](#集成准备)
- [权限与配置](#权限与配置)
- [代理服务接入流程](#代理服务接入流程)
- [连接状态监听](#连接状态监听)
- [代码示例](#代码示例)
- [Proxy接口说明](#proxy接口说明)

---

## 功能简介

- **本地代理**：将本地设备变为云端实例的网络出口，所有云端流量通过本地设备转发。

---

## 集成准备

1. **添加依赖**

   使用 [CocoaPods](https://cocoapods.org/):

   ```ruby
   pod 'TCRPROXYSDK', :git => 'https://github.com/tencentyun/cloudgame-ios-sdk.git', :tag => 'TCRPROXYSDK/1.2.4'
   ```

   安装依赖：

   ```
   pod install
   ```

2. 导入头文件

   ```objc
   #import <TCRPROXYSDK/Proxy.h>
   ```

---

## 权限与配置

iOS 无需特殊权限，亦无需在 Info.plist 中声明特殊内容，但请确保应用具备网络访问能力，已配置必要的权限（如本地网络、蜂窝数据、Wi-Fi）。

---

## 代理服务接入流程

### 1. 监听代理中继信息下发

在接入 TCR SDK 时，需要监听 `TcrSessionObserver` 回调的 `PROXY_RELAY_AVAILABLE` 事件。当收到此事件时可获取到云端下发的代理中继信息 (`relayInfoString`)。

**示例：**

```objc
#pragma mark --- TcrSessionObserver ---
- (void)onEvent:(TcrEvent)event eventData:(id)eventData {
    switch (event) {
        case PROXY_RELAY_AVAILABLE: {
            NSString *relayInfo = (NSString *)eventData;
            BOOL ok = [[Proxy sharedInstance] initWithRelayInfoString:relayInfo];
            NSLog(@"Proxy 初始化%@", ok ? @"成功" : @"失败");
            break;
        }
        default:
            break;
    }
}
```

> **备注：**  
> 必须收到并成功初始化后，才能启动代理服务。

### 2. 启动代理

初始化成功后，可调用如下接口启动代理：

```objc
[[Proxy sharedInstance] startProxy];
```

### 3. 停止代理

不再需要代理或生命周期结束时，请及时调用：

```objc
[[Proxy sharedInstance] stopProxy];
```

> **建议调用顺序：**  
> 1. 初始化（收到 PROXY_RELAY_AVAILABLE 并调用 `initWithRelayInfoString:`）  
> 2. 启动代理（`startProxy`）  
> 3. 停止代理（`stopProxy`）  

---

## 连接状态监听

> Proxy 新增连接状态监听能力，可以实时获知代理服务器的连接状态，包括断开、重连中、连接完成等，有助于业务流程和体验优化。

### 设置连接状态监听

引入头文件：

```objc
#import <TCRPROXYSDK/Proxy.h>
#import <TCRPROXYSDK/ProxyConnectionDelegate.h>
```

实现监听协议：

```objc
@interface MyProxyConnectionObserver : NSObject <ProxyConnectionDelegate>
@end

@implementation MyProxyConnectionObserver

- (void)onConnectionStateChanged:(ConnectionState)state message:(NSString *)message {
    NSLog(@"Proxy连接状态: %ld, 描述: %@", (long)state, message);
    // 可根据状态处理UI/业务
}

@end
```

注册监听：

```objc
MyProxyConnectionObserver *observer = [[MyProxyConnectionObserver alloc] init];
[[Proxy sharedInstance] setConnectionDelegate:observer];
```

> 若不再需要监听，可调用 `setConnectionDelegate:nil`，即可移除。

#### 状态枚举说明

SDK 定义的 `ConnectionState` 枚举：

| 枚举           | 值   | 描述           |
|----------------|------|---------------|
| Disconnected   | 0    | 连接断开       |
| Connecting     | 1    | 连接中/重连中  |
| Connected      | 2    | 连接完成       |

若需获取状态文本描述，可使用：

```objc
NSString *desc = [ConnectionStateHelper descriptionForConnectionState:state];
```

#### 典型场景示例
- **连接完成后通知业务层可以进行云端访问**  
- **UI层展示当前连接进度/告警**

---

## 代码示例

```objc
// 1. 监听代理中继信息回调（以 TcrSessionObserver 示例）
- (void)onEvent:(TcrEvent)event eventData:(id)eventData {
    if (event == PROXY_RELAY_AVAILABLE) {
        NSString *relayInfoString = (NSString *)eventData;
        // 1.初始化代理
        BOOL ok = [[Proxy sharedInstance] initWithRelayInfoString:relayInfoString];
        if (ok) {
            // 2. 设置连接状态监听
            MyProxyConnectionObserver *observer = [[MyProxyConnectionObserver alloc] init];
            [[Proxy sharedInstance] setConnectionDelegate:observer];
            // 3. 启动代理
            [[Proxy sharedInstance] startProxy];
        }
    }
}

// 4. 不再需要代理及监听时
[[Proxy sharedInstance] stopProxy];
[[Proxy sharedInstance] setConnectionDelegate:nil];
```

---

## Proxy接口说明

| 方法名                                                                                                    | 说明                | 参数说明                                                      | 返回值    | 备注                 |
| ------------------------------------------------------------------------------------------------------ | ----------------- | --------------------------------------------------------- | ------ | ------------------ |
| `+ (instancetype)sharedInstance`                                                                       | 获取单例，日志默认级别4 | 无                                                         | Proxy* | 单例模式               |
| `+ (instancetype)sharedInstanceWithLogLevel:(NSInteger)logLevel`                                       | 获取单例，指定日志级别  | logLevel: 2-VERBOSE, 3-DEBUG, 4-INFO, 5-WARNING, 6-ERROR  | Proxy* | 仅本地调试时用到           |
| `- (BOOL)initWithRelayInfoString:(NSString *)relayInfoString`                                          | 初始化代理服务           | relayInfoString: 云端下发的代理中继信息                              | BOOL   | 必须在 startProxy 前调用 |
| `- (BOOL)initWithBandwidth:(nullable NSString *)bandwidth relayInfoString:(NSString *)relayInfoString` | 初始化代理服务并限制带宽 | bandwidth: @"1MB"/@"500KB"（最大 4MB）<br>relayInfoString: 同上 | BOOL   | 必须在 startProxy 前调用 |
| `- (void)startProxy`                                                                                   | 启动代理服务              | 无                                                         | 无      | 必须已成功调用初始化方法       |
| `- (void)stopProxy`                                                                                    | 停止代理服务              | 无                                                         | 无      |                    |
| `- (void)setConnectionDelegate:(nullable id<ProxyConnectionDelegate>)delegate`                         | 设置连接状态监听器        | delegate: 连接状态变化监听器，传nil可清除监听                          | 无      | 需监听代理连接状态场景适用 |

---

### ProxyConnectionDelegate 协议

```objc
@protocol ProxyConnectionDelegate <NSObject>
/// 连接状态变化回调
/// @param state 当前连接状态（枚举）
/// @param message 状态描述字符串
- (void)onConnectionStateChanged:(ConnectionState)state message:(NSString *)message;
@end
```

---

### 其他说明

- iOS SDK 采用全局单例模式设计，建议在应用合适生命周期同步初始化、关闭代理，避免后台无故长时间占用资源。

---
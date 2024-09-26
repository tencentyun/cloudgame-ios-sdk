[English document](README_EN-US.md)
# 腾讯云云游戏 iOS
## 一、仓库介绍
该工程提供了集成云游SDK的简单应用示例，能够让您快速体验云游戏的运行效果。

同时还提供了快速入门的集成指引，帮您快速完成云游SDK的接入。

如果您需要实现一些进阶的功能，我们还提供了使用进阶指引。

## 二、快速入门
1、快速体验云游戏
进入Demo下的工程目录, **pod update** 更新SDK库文件，运行对应的工程即可快速体验云游示例

2、虚拟按键快速接入
如果您需要在您的应用中集成灵活可配置的游戏按键布局，请参考[虚拟接入文档](Doc/自定义虚拟按键.md)。

## 三、SDK集成

### 集成方式
在Podfile中添加
```
pod 'TCRSDK', :git => "https://github.com/tencentyun/cloudgame-ios-sdk.git"

# 虚拟按键可选库
# pod 'TCRVKey', :git => "https://github.com/tencentyun/cloudgame-ios-sdk.git"
```
### 包大小
ios framework合计大小约7MB

### 版本
我们会定期更新SDK的功能，您可以在本工程SDK目录下获取最新的版本。

你还可以查看SDK的发布历史，了解各版本的变更信息。


## 四、相关链接
[腾讯云云游戏解决方案](https://cloud.tencent.com/solution/gs)  
[API详细文档](https://tencentyun.github.io/cloudgame-ios-sdk/)

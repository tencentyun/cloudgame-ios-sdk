# 腾讯云云游戏 iOS
## 一、仓库介绍
该工程提供了集成云游SDK的简单应用示例，能够让您快速体验云游戏的运行效果。

同时还提供了快速入门的集成指引，帮您快速完成云游SDK的接入。

如果您需要实现一些进阶的功能，我们还提供了使用进阶指引。

## 二、快速入门
1、快速体验云游戏

进入Demo下的工程目录, **pod update** 更新SDK库文件，运行对应的工程即可快速体验云游示例，如果有疑问请参考[Demo运行说明](Demo/README.md)。

2、端游快速接入

如果您需要在您的应用中集成云端游的功能，请参考[端游接入文档](Doc/端游接入说明.md)。

3、手游快速接入

如果您需要在您的应用中集成云手游的功能，请参考[手游接入文档](Doc/手游接入说明.md)。

4、虚拟按键快速接入

如果您需要在您的应用中集成灵活可配置的游戏按键布局，请参考[虚拟接入文档](Doc/自定义虚拟按键.md)。

## 三、SDK集成

在Podfile中添加
```
pod 'TCGSDK', :git => "https://github.com/yujunleik/test_pod.git"

# 虚拟按键可选库
# pod 'TCGVKey', :git => "https://github.com/yujunleik/test_pod.git"
```

我们会定期更新SDK的功能，您可以在本工程SDK目录下获取最新的版本。

你还可以查看SDK的发布历史，了解各版本的变更信息。


## 四、相关链接
[腾讯云云游戏解决方案](https://cloud.tencent.com/solution/gs)

[构建端到端整体方案说明](https://docs.qq.com/doc/DSFBvWlhQTkVKZUlQ?wwapp_deviceid=bec61743-e9f5-4075-8f18-776a84374f56&wwapp_vid=1688850546831822&wwapp_cst=D3DCAAA8762E2D7554CAF70E75334B554A78709E24D3CD8E08DCAFFB909C1657D5168566444E3F1533E95090B7EED354)

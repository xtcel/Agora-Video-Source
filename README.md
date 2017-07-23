# Agora Video Source iOS (Object-C) && GPUImage实时美颜

声网并没有提供Object-C版本的自定义拍摄数据流，我照着官网Demo用OC实现了一遍。并且使用GPUImage加实时美颜功能(其实大部分用户应该都是想加入第三方美颜吧，官方提供的效果比较不好，发热严重)。

这个开源示例项目演示了如何使用自采集的摄像头数据和使用GPUImage实时美颜，并通过Agora视频SDK实现视频通话。

在这个示例项目中包含了以下功能：
- GPUImage实时美颜
- 加入通话和离开通话；
- 静音和解除静音；
- 自己采集摄像头数据，并使用Agora视频SDK传输；
- 切换前置摄像头和后置摄像头；
- 关闭摄像头和打开摄像头；

## 运行示例程序
首先在 [Agora.io 注册](https://dashboard.agora.io/cn/signup/) 注册账号，并创建自己的测试项目，获取到 AppID。

## 运行环境
* XCode 8.0 +
* iOS 真机设备
* 不支持模拟器

## 代码许可

The MIT License (MIT).

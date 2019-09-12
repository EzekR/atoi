# atoi iOS端app

## 技术栈

atoi基于谷歌发布的flutter框架构建，采用混合开发的方式，将前端页面与底层逻辑分开。前端调用统一UI库，可保证UI在iOS以及安卓系统下的一致性；底层逻辑采用原生语言编写（iOS：Objective-C，android：Java、Kotlin），可保证系统的可扩展性与可维护性。性能方面，前端UI库是基于canvas的，而canvas可直接调用手机GPU进行渲染，某种意义上比传统原生APP速度更快。

关于flutter的文档，可参考：

- [flutter china](https://flutterchina.club/get-started/install/)
- [official flutter api](https://api.flutter.dev/index.html)

iOS端采用的包管理器为pod，安卓端采用gradle

## 环境配置（macOS）

* xcode

Xcode是开发iOS APP必不可少的软件，版本要求：10.0.0以上

* 环境变量设置
  
因为国内屏蔽了谷歌系网站，所以需要将以下国内镜像加入到环境变量：
步骤：打开terminal，输入
export PUB_HOSTED_URL=https://pub.flutter-io.cn
export FLUTTER_STORAGE_BASE_URL=https://storage.flutter-io.cn

* 下载flutter SDK

下载地址：

- [download flutter](https://flutter.io/sdk-archive/#macos)

下载好之后解压flutter SDK，同时将flutter/bin目录添加至系统环境变量：
export PATH=`pwd`/flutter/bin:$PATH
设置好之后运行：flutter doctor，按提示进行依赖配置

* IDE

由于是谷歌发布的框架，建议IDE采用谷歌android studio（下载地址：https://developer.android.com/studio/index.html）
android studio可以同时编译iOS app与android app

也可选择微软visual studio code（下载地址：https://code.visualstudio.com/），同时安装flutter与dart插件

全部设置完之后，可cd到atoi根目录，运行：flutter run（macos需打开simulator）

## 编程语言简介

flutter采用的语言是dart。dart是谷歌发布的，针对下一代操作系统fuschia的编程语言。dart是面对对象，动态类型的，写过Java、
C#甚至js的程序员均可在短时间内上手dart并进行开发。
关于dart语言，可参考：

-[dart语言基础](https://www.jianshu.com/p/9e5f4c81cc7d)

## 项目代码结构

* lib
  
主要页面文件所在

- main.dart: 项目入口文件
- login_page.dart: 登录页
- home_page.dart: 超管入口
- engineer_home_page.dart: 管理员入口
- user_home_page.dart: 用户入口
- models: 控制全局状态
- utils: 常用function封装
- widgets: 通用组件

* iOS

iOS底层文件位置，可用xcode打开iOS/runner.xcworkspace,即可在xcode中对项目底层进行开发



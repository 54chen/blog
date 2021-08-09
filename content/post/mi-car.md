---
title: "利用手柄和安卓给娃“再造”小米赛车"
author: "54chen"
cover: "/img/post/car.jpg"
tags: ["phone car", "小米赛车"]
date: 2021-04-24T14:30:00+08:00
---

很多看起来炫酷的产品，都经不起时间的检验。比如说这款赛车，用手机上的android app操作的，产于2012年，由于保存完好，9年后想再拿出来玩的时候，已经没有地方下载app了，官网也打不开了，估摸着是厂家倒闭了。

![小米赛车](/img/post/car.jpg)

<!--more-->

在网上各种关键词搜啊搜，企图找到历史上的操作app的蛛丝马迹，果真在一个全部是广告的下载站，下载到了apk，遗憾的是，已经不能正常在现在的安卓版本上运行了。关键词提示：FonCar下载--不知道是哪个文盲上传的apk，可能是phone写成了fon。

第一步，反编译apk，找到赛车的控制协议
--------------------------------------

用三个神器，apktool解开apk包，dex2jar将apktool里的class反编译为java，jd-gui查看dex2jar结果的java文件可视化工具，均可使用brew在mac下安装: 

```shell 
 brew install apktool dex2jar jd-gui
```

分别执行apktool得到class.dex，执行dex2jar得到java，最后执行jd-gui看到java代码。

```shell

 apktool d -s foncar.apk
 cd phonefeiche
 dex2jar classes.dex
 jd-gui 
```

第二步，找到协议
-----------------

```java
CarComm.this.sendWithPwd(Commands.getCommand(CarComm.this.orientations), CarComm.this.speed);
```

通过阅读代码，找到控制小米赛车的代码，原来是利用了udp协议，直接发二进制，方向有8个，速度有0-9。这样一来，就很简单了。下一步就是考虑用什么来搞，安卓界面不擅长，家里正好还有一个小米游戏的手柄，是蓝牙协议的。灵机一动，正好，废物再利用。

![小米游戏手柄](/img/post/controller.jpg)

第三步，串上手柄
----------------

弄开手柄也没找到啥可以编程的地方，只有一个蓝牙的机会，于是打开手柄连手机，手机跑代码连赛车，于是乎，一套手机做主机，小米游戏手柄+小米赛车的方案就写成了。直接借用了安卓官方文档，十分详尽，https://developer.android.com/training/game-controllers/controller-input?hl=zh-cn#java 。弄了个初版给娃试用，然后问清哪个按钮要啥功能，直接整了一系列定制。

第四步，上代码,小区调试
-----------------------

 * 功能1. 电量显示
 * 功能2. 限速与解禁
 * 功能3. 左右摇杆模式
 * 功能4. 左右2速模式
 * 功能5. 刹车油门模式

开着我的手机做主机，蓝牙手柄连手机，手机wifi连赛车。娃成了小区最受小朋友们追随的崽。

最终效果如下：

![手柄驱车](/img/post/car2.jpg)

代码github下载：

https://github.com/54chen/MuMuCarApp 

---
title: "ZTEZXV10B860AV1.1机顶盒刷机手记"
author: "54chen"
cover: "/img/post/zte-1.jpg"
tags: ["软R", "旁R"]
date: 2021-06-13T21:10:10+08:00
draft: true
---

每次换宽带，都会遗留下来各种奇形怪状的盒子，ZTEB86AV1.1是几年前的北京电信天翼宽带留下的产物，后来北京移动来抢生意，价格只有四分之一，网速还更快，所以就换了。这些盒子都是标准的技术架构，OS Kernel依靠ARM的一整套方案，有些包着海思的皮，所有的driver+kernel烧到芯片里，上面加上android framework, 所以在网上实际上都可以找到对应的固件来直接刷写到ROM中。

![zte](/img/post/zte-2.jpg)

<!--more-->

为啥要刷的原因是他官方的太恶心了，不给开adbd不说，还经常自己偷偷下些东西。所以就有了xxx纯净版这种固件（像极了早期的android手机市场）。

下面进入正题，如何将ZTEB860AV1.1中兴的电视盒子变废为宝，完成后，效果不错。

第一步 花5-10块不等买CH340 USB转TTL连接线一根
---------------------------------------------

正二八经刷机专用的，基本上这些盒子也好、R器也好，都支持，一般TTL的接线就三条主要的：GND地线，RXD收数据，TXD发数据。很少需要给板子供电才能玩的(某些开源硬件需要)。

第二步 拆机中兴，接线
----------------------

找个起子，找缝就撬就对了，总能弄开的，弄开后就一块板子，cpu、rom、ram、hdmi、usb、wifi、蓝牙啥的全齐活，收废品还是有芯片的，要说中国芯片不足，找收废品的试试。

![zte](/img/post/zte-3.jpg)

按上图进行接线到你的ch340，接上电脑。

Mac用户不需要像Windows用户整个putty啥的，直接命令行 screen -L /dev/tty.usbserial-1410 115200，后面一个参数是波特率（感谢大学数电老师）。要是没有screen命令的话，brew install screen即可拥有。

第三步 刷机
-----------

我找了个符合我cpu型号的固件，cpu型号很重要，我的是MSO9280，对上了就不会错了。就一个文件MstarUpgrade.bin，放到一个8G以内的fat32的U盘里。

插上U盘，并给板子加电，一直按着ctrl+z，要先进Mboot，进了后输入usb_bin_check回车。然后就刷完了。就是这么简单且粗暴。

第四步 设置
------------

这固件启动的android已经默认打开了adb。只需要接上电视机后设置一下wifi，其他都不用管，除非你要用来看电视。那就是另一个分支了。

我的盒子ip是192.168.1.10。在同局域网的电脑上输入

```shell

adb connect 192.168.1.10
adb root
adb shell

```

这样，就可以以root身份随便弄了，大多数目录都是只读的，要存东西都放到/data/local里可以保存住。

(adb自己上andriod网站去下，下完在platform-tools目录下)

第五步 准备软件包及iptables设置脚本
-----------------------------------

这步也很简单了，去官网找一下ARM版本的编译好的可执行二进制文件。adb push xxx-linux-arm /data/local/ 就进去了。

进去后，继续操作一下设置。包括远程的server ip什么的就不在这里说了。

iptables设置中很关键的两句是

```shell

echo 1 > /proc/sys/net/ipv4/ip_forward

iptables -t mangle -A XXX_MASK -p udp -j TPROXY --on-port 12345 --tproxy-mark 1

```

大概意思就是打开ip转发，所有相关的包都给转到12345端口去。

第六步 最终设置完成
-------------------

所有家里要使用的设备，只要修改原来的网关192.168.1.1为192.168.1.10即可（wifi还是连原来的）,然后就通过这个拥有了它的能力。

到此，功能完成。

以上所有用到的文件，包括名为MstarUpgrade.bin、xxx-linux-arm.tar.gz、config.json 有尝提供:) 联系邮件 cc0cc@126.com。


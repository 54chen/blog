---
title: "在家办公神器推荐:番茄钟工作法工具"
author: "54chen"
cover: "/img/post/pomodoro.jpeg"
tags: ["番茄钟工作法", "虚拟机"]
date: 2021-06-24T22:31:20+08:00
draft: true
---

至此全球疫情之际，不具备在家高效办公能力的同学，可能会被时代淘汰 :)

54chen最近半年在家办公的经验，最重要的就是效率，利益于科学的方法，效率不低。

平时没事就积累了一些shell脚本在macOS上跑，运行良好，不过如果你不是mac用户可能没有卵用。

<!--more-->

特此推出两个神器（其实是基于macOS的脚本啦）。

# 神器  番茄钟工作法工具

https://github.com/54chen/pomodorify

项目源于一国外小哥，做了一点微小的工作，以方便在墙内使用。

用法也很简单，只要去github自己fork出来项目，git clone回来就行了。

里面有个脚本叫 pomodify.sh，再传个参数是最近要做啥。运行就开始25分钟的计时，到点了还有声音和弹窗提示，十分友好：）

要回看一下找找成就感，也很简单，只需要 git log一下就行。

```shell

chenzhen@C-MacBook-Pro pomodorify % git log
commit ef9651818d9ec32e50eb07b09c7338cc893435a5 (HEAD -> master, origin/master, origin/HEAD)
Author: 54chen <czhttp@gmail.com>
Date:   Thu Jun 24 22:23:42 2021 +0800

    Congrats! 21:58 - 22:23 Done! okr in japan

commit 07c7ef1a096fb09a285e4d5ac4f0784abf5a60f2
Author: 54chen <czhttp@gmail.com>
Date:   Thu Jun 24 21:53:28 2021 +0800

    Congrats! 21:28 - 21:53 Done! okr in japan

commit 12af6868cba20873a7f3ee8e996bf1326476a2d6
Author: 54chen <czhttp@gmail.com>
Date:   Thu Jun 24 21:23:15 2021 +0800

    Congrats! 20:58 - 21:23 Done! okr in japan

commit 5a05a6b972b7373f714b8f66dba7574fc99b9e45
Author: 54chen <czhttp@gmail.com>
Date:   Thu Jun 24 18:58:24 2021 +0800

    Congrats! 18:33 - 18:58 Done! global okr system

commit ef0cdff415de77ebdb8a041ee87139281cc8e1fb
Author: 54chen <czhttp@gmail.com>
Date:   Thu Jun 24 14:53:56 2021 +0800

    Congrats! 14:28 - 14:53 Done! OKRs overseas

```



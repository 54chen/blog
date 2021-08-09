---
title: "How to Add Dictionary in Mac"
author: "54chen"
cover: "/img/cover.jpg"
tags: ["mac", "dictionary"]
date: 2020-12-30T11:00:24+08:00
---

There is a good dictionary application in mac system. But it is not so many good content. So I collected some methods from internet and learn to make a dictionary content by myself.

It is not so difficult. Just need 2 tools: 1. Dictionary Development kit(DDK) - which is provided by apple inc. 2.pyglossary - which is a open source tool converting dictionary formats.

<!--more-->

Essential Environment
----------------------

1. python3
2. xcode and xcode command line tool
3. download DDK and copy to ~/Developer/Extra/
4. git clone pyglossary
5. download MDX files, which is a kind of dictionary file used by Mdict. There are lots of people share their dictionaries, so it is easy to get some good dictionaries.

Principle
----------

Pyglossary can convert the MDX file to apple dictionary format. And mdd file is relatively easy to obtain. So the method is to find a MDX dicitonary and convert it to apple format by pyglosary and DDK.

Steps
------

### 1. open terminal 

```shell

cd dict/
~/Downloads/pyglossary/main.py --write-format=AppleDict "~/Downloads/dict/xxx.mdx" xxxx_Dictionary

```

xxxx_Dictionary could be any characters including Chinese, which will be showed as the dictionary title when you search word.


After a long time, the result will be generated in the folder.


### 2.run DDK

```shell
cd xxxx_Dictonary 
make
```

If you have any issues here, it must be because of the xcode environment.

I also met the problem, which noticed like: 

```shell 
argument list too long: cp
```

Because there are too many mp3 files in a single directory, so I run by my self:

```shell
for i in ./OtherResources/*; do echo "$i";  done
mv -f objects/dict.dictionary objects/牛津高阶英汉双解词典9.dictionary
make install
```

Then choose your own dictionary. enjoy it! If you like, you can contact me by czhttp@gmail.com

Screenshot
-----------

![dictionary](/img/post/dict.png)


References
----------

goforward. (2020). Douban. https://www.douban.com/note/507451268/ 

kaihao. (2018). kaihao's Blog. https://kaihao.io/2018/mdict-to-macos-dictionary/

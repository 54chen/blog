---
title: "Ansible配合aws使用入门"
author: "John"
cover: "/img/poster.jpg"
tags: ["ansible", "devops", "aws"]
date: 2021-08-13T19:20:28+08:00
---

ansible是一整套的部署脚本，以python实现的，还是很有些粉丝了，在学习过程中，需要了解它和aws配合的使用，特地从头进行了学习，进行了一系列的记录如下。

<!--more-->

安装
----

```shell

$pip3 install virtualenv
$virtualenv -p /usr/bin/python3 myEnv
$source myEnv/bin/activate

$(myEnv) xx $ pip3 install awscli
pip3 install ansible
pip3 install boto3
pip3 install botocore
pip3 install boto

```

boto是aws的python api实现。

inventory file
---------------

定义所有的服务器ip 用 ansible -i指定。

```php 
$vim hosts

[local]
localhost ansible_connection=local ansible_python_interpreter=/home/chenzhen/compx527/bin/python

[myserver]
2.2.2.2

[webservers]
#1.1.1.1  ansible_ssh_private_key_file=/home/ubuntu/.ssh/oof1-ec2-key.pem


```

支持对不同服务器进行分组管理。下面的例子在调webservers这个组的机器。


```shell

ansible -i inventories/hosts webservers -m ping

```

模块
----

-i指定机器列表，-m指定运行的模块，还可以传参数，直接在后面加。ansible支持核心模块、额外模块和自定义模块。

ping模板并不是ICMP的ping，是ansibe自己实现的ping，用来检测server是否可用可登录且有python。

要开发自己的模块，需要会python和json包，返回的都是json。执行ansible时传入的参数都以key=value的串传到python脚本里，需要自己解析。用shlex可以简单读入所有空格间隔的串，再在里面找=号。

在后面提到的playbooks中，大量使用模块以下知识：

很重要的是模块要有幂等性，就是不怕多次执行。

有两个特殊的module一个是command一个是shell，它们不是key=value的，面是直接像正常在Linux用。执行成功返回非0。

module里的action太长的话，可以像python一样折行缩进。一种特殊的action是template，用来发配置文件的。

playbooks
----------

ansible直接命令一个一个操作执行的过程是ad-hoc的执行，playbooks提供了编排的能力，可以把一堆操作顺序配置起来。比如说，上传代码+复制配置+重启tomcat+重启nginx等放在一个playbooks里，确保每个执行成功后才执行下一个。下例是一个play（多个play在一起形成playbooks)。一个play里可以多个task，这多个task都是顺序的，必须在一个或一批机器完成才执行下一个task。一个task就是一个模块。

```yaml

---   
- hosts: webservers   
 vars:  # vars定义的变量，可以后文中使用 {{http_port}}。
   http_port: 80    
   max_clients: 200
 romote_user: root
# 以上指定了host和user，支持通配符啥的代表一批机器，sudo: yes 给sudo权限。再加sudo_user: xxx 切到其他用户也ok。
 tasks:  
 - name: update nginx
   yum: pkg=nginx state=latest
# 实际上，到每个taks里，还可以指定运行的远程用户，还是remote_user: xxx。
 - name: write config
   template: src=/srv/nginx.js dest=/etc/nginx/nginx.conf
   notify:
   - restart nginx
 - name: ensure nginx is running
   service: name=nginx state=started
 handlers:
   - name: restart nginx
     service: name=nginx state=restarted
 

```

handlers就像函数一样，把一群task放在一起，配合notify使用。以上文件notify配合handlers翻译为：当template指定的文件内容被改动时，重启nginx。


综上，关键的因素有：hosts\play\task\template\notify\handlers。

对应基本上就是：机器\任务列表\单个操作\配置文件\配置变化\配置变化后的定义行动。

Run a Playbook
---------------

```shell

ansible-playbook main.yml -f 10

```

-f 10代表以10个并行跑，速度更快。默认为5。

如果想看影响哪些机器，可以执行：

```shell

ansible-playbook main.yml --list-hosts

```

重用大法：roles & include
--------------------------

roles角色，主要是考虑以角色来区分操作，操作DB和操作nginx肯定是不一样的任务。

include主要是为了重用各处的task或者play。

简单说，关系就是 roles--> include --> m * play + n * task + x * play and so on。

roles其实是一些约定大于配置的设计，一旦使用了role，则在固定的目录下寻找文件，如果有则include，如果没有也不报错。roles/x/task|handlers|vars|meta|files|templates/main.yml。
当然也可以直接指定目录，这就复杂一点了。

还支持在role前role后定义 pre_taks和post_tasks。

通过dependencies来定义 不同的role的依赖关系或各种公共配置。进而控制先后顺序，比如先安装db，后初始化db，再安装php，上传代码，等等。

--tags xxx 在playbook使用时，会去只运行关键字一致的部分代码。

defaults/main.yml存的是变量，其他大多是存的module(tasks)。


帮助文档
--------

action众多，难免有不认识的，所以这个命令犹为关键，ansible-doc ping。

也可以直接写python代码调用ansible，无缝。

https://docs.ansible.com  直接按module搜，非常有用。


aws协作
-------

有两个办法上传文件到s3：command + aws c3 cp  && s3_sync

如果使用了command + aws 命令，必须注意先运行 aws configure。

inventories/hosts总是有localhost的原因是为了在本地dry run。

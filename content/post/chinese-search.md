---
title: "利用python,jieba,bm25,django,nginx半小时打造一个基本可用的中文全文检索的搜索引擎"
author: "John"
cover: "/img/cover.jpg"
tags: ["jieba", "bm25"]
date: 2021-08-10T19:18:21+08:00
---

以前做搜索的时候，大部分时间用sphinx、postgreSQL，后来用ES这类java的，但都比较重，要配置和使用需要好一段时间才能从零run起来。

最近正好有个场景，需要快速弄个搜索出来，正好python3里英雄众多，现成的东西不少，结合一下就完成了。下面是一些记录，代码整理后也会放到github中。

<!--more-->

任务背景
------------

1. data/目录下有一堆html文件，存在子目录，都是标准的html。
2. 内容中有中英文混合。
3. 建立搜索能力，输入“上海自来水来自海上”，找出最相关的html。

基础知识 
------------

jieba是python里的中文分词支持，通过pip3 install jieba可安装。

tdidf是一种统计方法，简单讲就是越少看见的词，在一个文档里出现了说明这个文档更加是在说这个词。

bm25是计算两个内容的相似度的一种办法，tdidf能出来一个词与文档的关系，bm25能出来一堆词与文档的关系。

stopwords是搜索里常见的停用词，把一些常见的没有意义的词故意过滤不作索引，以免影响效果。

BeautifulSoup是python里的爬虫库，可以用来去除html啥的。

pickle是python的对象持久化存储的库，可以用来保存索引。

django是python的web框架，uwsgi是python的web服务器，与nginx无缝连接。

提前安装依赖：

```shell

pip3 install jieba,BeautifulSoup,pickle,rank_bm25,uwsgi,django


```


代码实现
------------
所有的引用有：

```python

from bs4 import BeautifulSoup
import json
import re
import jieba
import time
import os
import pickle
from rank_bm25 import BM25Okapi

```


首先要遍历文件。

```python

list_URL_sport = []
def walk_file(file):
    for root, dirs, files in os.walk(file):
        for f in files:
            f_s = os.path.join(root, f);
            if f_s.endswith('html'):
                list_URL_sport.append(f_s)
        
```

进行文件处理，过滤html，进行分词，建立bm25对象，保存索引。


```python

def crawler(list_URL):
    corpus = []
    for i, url in enumerate(list_URL):
        print("网页爬取:", url, "...")
        with open(url, 'r') as f:
            page = f.read()
        result_chinese = url + bs4_page_clean(page)
        corpus.append(jieba_create_index(result_chinese))
        documents.append(url)
    index_obj['d'] = documents
    bm25 = BM25Okapi(corpus)
    index_obj['b'] = bm25
    with open(INDEX, 'wb') as index_file:
        pickle.dump(index_obj, index_file)
    return bm25


def bs4_page_clean(page):
    print("正则表达式：清除网页标签等无关信息...")
    soup = BeautifulSoup(page, "html.parser")
    [script.extract() for script in soup.findAll('script')]
    [style.extract() for style in soup.findAll('style')]
    reg1 = re.compile("<[^>]*>")
    content = reg1.sub('', soup.prettify())
    return str(content)

def jieba_create_index(string):
    list_word = jieba.lcut_for_search(string)
    dict_word_temp = []
    for word in list_word:
        if word in stopwords:
            continue
        dict_word_temp.append(word)
    return dict_word_temp


```

在django框架下创建mysite项目，添加view.py对索引文件发起搜索。


```shell

$django-admin startproject mysite


```
在mysite/mysite/下添加view.py


```python

from django.http import HttpResponsePermanentRedirect
from bs4 import BeautifulSoup
import json
import re
import jieba
import time
import os
import pickle
from rank_bm25 import BM25Okapi

documents = [] # = urls

list_search_result = []
   
list_URL_sport = []

INDEX = 'INDEX'

stopwords = []

index_obj = {}

bm25Model = None

def index(request):
    word = request.GET['key'][:20].strip()
    if os.path.exists(INDEX):
        with open(INDEX, 'rb') as index_file:
            index_obj = pickle.load(index_file)
            documents = index_obj['d']
            bm25Model = index_obj['b']

            query = jieba.lcut_for_search(word)
            url = bm25Model.get_top_n(query, documents, n=1)[0]

    return HttpResponsePermanentRedirect(url)


```


补充配置
------------

只需要run出来INDEX文件后，建立索引了就可以提供搜索服务了。

再需要的就是将nginx和uwsgi配置好，将请求打到django里。

总共有四个地方要配置: systemctl nginx uwsgi django。

1. django需要修改urls.py，让请求知道访问哪个类：

```python

    path('search', views.index, name='index'),

```

2. uwsgi有个ini文件需要指定启动目录用户之类的：

```shell

[uwsgi]
chdir=/var/www/mysite/
uid=www-data
module=mysite.wsgi:application
master=True
pidfile=/tmp/project-master.pid
vacuum=True
max-requests=5000
daemonize=./uwsgi.log
socket=/tmp/uwsgi.sock
workers = 5

```

3. nginx需要配置代理：

```shell

upstream django {
       server unix:/tmp/uwsgi.sock;
}

server {

	location /search {
		include /etc/nginx/uwsgi_params;
		uwsgi_pass django;

  		uwsgi_param Host $host;
            	uwsgi_param X-Real-IP $remote_addr;
            	uwsgi_param X-Forwarded-For $proxy_add_x_forwarded_for;
           	uwsgi_param X-Forwarded-Proto $http_x_forwarded_proto;
	}
}

```

4. uwsgi重启自动加载也需要自己配置一下：

```shell

[Unit]
Description=uWSGI instance to serve mysite
After=network.target
 
[Service]
User=www-data
Group=www-data
WorkingDirectory=/var/www/mysite/
ExecStart=/usr/local/bin/uwsgi --emperor /var/www/mysite
Restart=always
KillSignal=SIGQUIT
Type=notify
StandardError=syslog
NotifyAccess=all
 
[Install]
WantedBy=multi-user.target

```

5. 启动服务，http://xxxx/search?key=上海自来水来自海上找到正确的文档：


```shell

$systemctl start mysite
$nginx -s reload

```

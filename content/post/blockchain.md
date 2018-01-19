---
title: "靠写代码学习什么是区块链"
date: 2018-01-18T16:20:57+08:00
tags: ["blockchain", "python"]
---

最快学会区块链是如何工作的办法是写代码构建一个。

Translate from https://hackernoon.com/learn-blockchains-by-building-one-117428612f46

你在这里是因为和我一样对加密货币的兴起感到激动。而且你想知道区块链是如何工作的－－也就是区块链背后的基础技术。

<!--more-->

![blockchain](https://cdn-images-1.medium.com/max/2000/1*zutLn_-fZZhy7Ari-x-JWQ.jpeg)

但是要理解区块链并非易事，至少对我是这样的。我艰难浏览了大量的视频，学了好些不完整的教程，因为例子太少深受打击。

我喜欢靠行动来学习。这使我在代码级别来思考这个问题，通常学得更牢。如果你也这样，在看完本文后你将拥有一个根据其工作原理完整写好的区块链。

开始之前
--------

记住区块链是由名字叫blocks的东东按不可变的顺序链在一起的记录。它们可以包含交易、文件或任何你想要的数据。重要的是它们用hash链接到一起。

如果你不确定什么是hash，点这里有个解释 https://learncryptography.com/hash-functions/what-are-hash-functions

**本文的目标读者是？**你需要能轻松地读和写些基础的python，最好能理解http请求是如何工作的，因为我们将为基于http来建立区块链。

**我需要啥环境？**确保安装了python3.6以上（带pip）。同时需要安装Flask，最爽的http请求库。

<cite> pip install Flask==0.12.2 requests==2.18.4 </cite>

还有，你需要一个http客户端，postman或者curl都行。其他啥能用的也行。

**最终的代码在哪？** https://github.com/dvf/blockchain

step1 建立区块链
----------------

打开你喜欢的文本编辑器或者IDE，我个人比较喜欢PyCharm。新建一个文件，叫做 blockchain.py。我们只用一个文件，如果你搞丢了，可以随时到github里找。

### 表示区块链

我们将建一个Blockchain类，构造函数里初始化一个空列表（用来存我们的blockchain），初始化另一个用来存交易。下面是这个类的大概架子：

```python
class Blockchain(object):
    def __init__(self):
        self.chain = []
        self.current_transactions = []
        
    def new_block(self):
        # 创建新块，加入到链条中
        pass
    
    def new_transaction(self):
        # 添加一次新的交易到交易列表中
        pass
    
    @staticmethod
    def hash(block):
        # 将一个块hash掉
        pass

    @property
    def last_block(self):
        # 返回链条中的最后一个块
        pass
```
Blockchain类大概架子

BlockChain类主要是用来管理链条。它将保存交易，还需要一些添加新区块到链条的helper方法。让我们开始添砖加瓦。

### 一个区块看起来什么样？

每个块都有一个索引、一个unix timestamp、一个交易列表、一个证明（更多稍后介绍），以及上一个块的hash。

一个单独的区块长下面这样：

```python
block = {
    'index': 1,
    'timestamp': 1506057125.900785,
    'transactions': [
        {
            'sender': "8527147fe1f5426f9dd545de4b27ee00",
            'recipient': "a77f5cdfa2934df3954a5c7c7da5df1f",
            'amount': 5,
        }
    ],
    'proof': 324984774000,
    'previous_hash': "2cf24dba5fb0a30e26e83b2ac5b9e29e1b161e5c1fa7425e73043362938b9824"
}
```
我们的区块链中的一个块的例子

每个新块除了自己的信息外，还有上一块的hash，在这一点上，链条的意义明显。***这是至关重要的，因为这是区块链不可变性的原因：***如果攻击者损坏链中较早的块，后续***所有***块都将包含不正确的哈希值。

理解了没？要是还没理解，花点时间想一想－－这是区块链背后的核心思想。

### 将交易加入区块中

我们要准备一种方法将交易加到区块里。我们的new_transaction方法主要责任就是干这个，而且非常简单：

```python
class Blockchain(object):
    ...
    
    def new_transaction(self, sender, recipient, amount):
        """
        创建一个新的交易，交给下一个开采出来的块

        :param sender: <str> 发出人地址
        :param recipient: <str> 接收人地址
        :param amount: <int> 金额
        :return: <int> 保存这一次交易的块的索引
        """

        self.current_transactions.append({
            'sender': sender,
            'recipient': recipient,
            'amount': amount,
        })

        return self.last_block['index'] + 1
```

new_transaction之后，添加一个交易到列表，返回这个交易将会被添加的区块索引，也就是下一个将被开采的区块。对于用户提交交易来讲，后面将很有用。

### 建新的区块

当我们的Blockchain被实例化的时候，需要喂给它一个起源区块－－这种块没有前任。我们同样需要添加一个“证据”给起源块，作为开采的结果，或者说是干活的证据。我们后面再讲细一些挖矿的事。

除了在构造函数里生成起源块外，还要填充new_block\new_transaction\hash：

```python
import hashlib
import json
from time import time


class Blockchain(object):
    def __init__(self):
        self.current_transactions = []
        self.chain = []

        # 创建起源区块
        self.new_block(previous_hash=1, proof=100)

    def new_block(self, proof, previous_hash=None):
        """
        在链条中创建一个新的块

        :param proof: <int> 靠PoW算法给出来的proof值
        :param previous_hash: (Optional) <str> 前一块的hash值
        :return: <dict> 新块
        """

        block = {
            'index': len(self.chain) + 1,
            'timestamp': time(),
            'transactions': self.current_transactions,
            'proof': proof,
            'previous_hash': previous_hash or self.hash(self.chain[-1]),
        }

        # 重置当前的交易列表
        self.current_transactions = []

        self.chain.append(block)
        return block

    def new_transaction(self, sender, recipient, amount):
        """
        创建一个新的交易，交给下一个开采出来的块

        :param sender: <str> 发出人地址
        :param recipient: <str> 接收人地址
        :param amount: <int> 金额
        :return: <int> 保存这一次交易的块的索引
        """
        self.current_transactions.append({
            'sender': sender,
            'recipient': recipient,
            'amount': amount,
        })

        return self.last_block['index'] + 1

    @property
    def last_block(self):
        return self.chain[-1]

    @staticmethod
    def hash(block):
        """
        给一个块创建一个sha-256的hash值
        :param block: <dict> 整个块
        :return: <str>
        """

        # 我们必须确保dict是有序的，否则会得到不一致的hash值
        block_string = json.dumps(block, sort_keys=True).encode()
        return hashlib.sha256(block_string).hexdigest()
```

上述应该也很简单，我添加了一些说明和注释让意思更清楚。我们几乎完成了表达我们的区块链。但是现在你一定想知道新块怎么建立、打造或者开采的。

### 理解干活的证据

干活的证据（PoW）是指新块如何在区块链上建立或开采。PoW的目标是找到一个数字来解决这个问题。这个数字必须是对网络上任何人都难于发现但易于验证－－从计算机角度。这是PoW背后的核心思想。

为了帮助理解，我们来看一个非常简单的例子。

我们定义一个hash，有一系列的整型x乘以另一个y结果必须以0结尾。那就有，hash(x*y)=ac23dc...0。对于这个简单的例子，我们让x=5。用python实现的话：

```python
from hashlib import sha256
x = 5
y = 0  # 这里还不知道y应该是多少
while sha256(f'{x*y}'.encode()).hexdigest()[-1] != "0":
    y += 1
print(f'The solution is y = {y}')
```

这里的答案是y=21。因为，这里产生的hash结果是0：

<cite>hash(5 * 21) = 1253e9373e...5e3600155e860</cite>

比特币里，PoW算法叫做Hashcash。这并不比上述基础例子的算法有什么大不同。这是矿工为了创建一个新区块比赛答题的算法。一般情况，难度决定于在一个字符串中找多少个字。矿工解出来后会得到一个币－－放到交易记录中。

网络可以很简单验证他们的结果。

### 实现基本的PoW

让我们来给我们的区块链实现一个相似的算法。我们的规则和前面的例子类似：

<cite>找到一个数字p，可以和前一块的结果一起hash后，产生以4个0开头的新hash</cite>

```python
import hashlib
import json

from time import time
from uuid import uuid4


class Blockchain(object):
    ...
        
    def proof_of_work(self, last_proof):
        """
        Simple Proof of Work Algorithm:
        简单的PoW算法
         - 找到一个数字 p' ，使得 hash(pp') 的结果里以4个0开头，p是上一块里的p'
         - p是上一块的proof值，p'是新的proof

        :param last_proof: <int>
        :return: <int>
        """

        proof = 0
        while self.valid_proof(last_proof, proof) is False:
            proof += 1

        return proof

    @staticmethod
    def valid_proof(last_proof, proof):
        """
        验证proof：hash(last_proof,proof)是否以4个0开头

        :param last_proof: <int> 上一个roof
        :param proof: <int> 当前的 Proof
        :return: <bool> True为正确.
        """

        guess = f'{last_proof}{proof}'.encode()
        guess_hash = hashlib.sha256(guess).hexdigest()
        return guess_hash[:4] == "0000"
```

为了调整算法难度，可以修改需要的0的个数。4是合适的数量。你会发现，加一个0就可导致找到答案所需时间有巨大差异。

我们的类基本完成了，现在准备开始通过http进行交互。

step2 我们的区块链API
----------------------

我们计划使用python flask框架。它是一个可以让我们容易将端口映射到python函数的小框架。这样就可以让我们同我们的区块链通过web的http请求来通讯。

我们创建三个方法：

* /transactions/new  给一个区块创建一个新的交易
* /mine 告诉服务器挖出来一个新块
* /chain 返回整个区块链

### 安装flask

我们的 server 将会在我们的区块链网络里成为一个单独节点。让我们搞一些样板代码：

```python
import hashlib
import json
from textwrap import dedent
from time import time
from uuid import uuid4

from flask import Flask


class Blockchain(object):
    ...


# Instantiate our Node
app = Flask(__name__)

# Generate a globally unique address for this node
node_identifier = str(uuid4()).replace('-', '')

# Instantiate the Blockchain
blockchain = Blockchain()


@app.route('/mine', methods=['GET'])
def mine():
    return "We'll mine a new Block"
  
@app.route('/transactions/new', methods=['POST'])
def new_transaction():
    return "We'll add a new transaction"

@app.route('/chain', methods=['GET'])
def full_chain():
    response = {
        'chain': blockchain.chain,
        'length': len(blockchain.chain),
    }
    return jsonify(response), 200

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000)
```

关于上面的代码的一些解释：

* 15行 实例化节点。更多参考flask
* 18行 给我们的节点取一个随机名字
* 21行 实例化我们的Blockchain类
* 24-26行 创建/mine节点,接收get请求
* 28-30行 创建/trasaction/new节点，接收post请求，因为我们要给它发数据
* 32-38行 创建/chain节点，返回全部的区块链
* 40-41行 在5000端口上跑起来server

### 交易节点

这是一次交易看起来的样子，用户发给server下面的数据：

<cite>
{
 "sender": "my address",
 "recipient": "someone else's address",
 "amount": 5
}
</cite>

因为我们已经有类和方法来给一个块添加交易，剩下的简单了。我们写一个方法添加交易：

```python
import hashlib
import json
from textwrap import dedent
from time import time
from uuid import uuid4

from flask import Flask, jsonify, request

...

@app.route('/transactions/new', methods=['POST'])
def new_transaction():
    values = request.get_json()

    # Check that the required fields are in the POST'ed data
    required = ['sender', 'recipient', 'amount']
    if not all(k in values for k in required):
        return 'Missing values', 400

    # Create a new Transaction
    index = blockchain.new_transaction(values['sender'], values['recipient'], values['amount'])

    response = {'message': f'Transaction will be added to Block {index}'}
    return jsonify(response), 201
```

### 挖矿节点

我们的挖矿节点是魔法发生的地方，同样也简单。它要做三件事：

1. 计算PoW
2. 靠给交易信息里加同意给我们1个币来奖励矿工
3. 靠把老的加到链条里来组织新的块

```python
import hashlib
import json

from time import time
from uuid import uuid4

from flask import Flask, jsonify, request

...

@app.route('/mine', methods=['GET'])
def mine():
    # 这里跑pow算法取到下一个proof值
    last_block = blockchain.last_block
    last_proof = last_block['proof']
    proof = blockchain.proof_of_work(last_proof)

    # 因为找到proof我们必须接收一个奖励 
    # 发送方写0表示这个节点挖了新币
    blockchain.new_transaction(
        sender="0",
        recipient=node_identifier,
        amount=1,
    )

    # 把块加到链条中完成组装
    previous_hash = blockchain.hash(last_block)
    block = blockchain.new_block(proof, previous_hash)

    response = {
        'message': "New Block Forged",
        'index': block['index'],
        'transactions': block['transactions'],
        'proof': block['proof'],
        'previous_hash': block['previous_hash'],
    }
    return jsonify(response), 200
```

注意被挖的块的接收者是我们节点的地址。并且大多数我们做的事情只是与我们Blockchain类里的方法相互调用。所以，我们做到了，我们可以开始同我们的区块链进行交互了。

step3 与我们的区块链进行交互
----------------------------

你可以通过网络使用老式的cURL或者Postman进行交互。

先启动server:

<cite>
$ python blockchain.py
* Running on http://127.0.0.1:5000/ (Press CTRL+C to quit)
</cite>

让我们尝试通过get请求挖一块 http://localhost:5000/mine 

{{% figure src="https://cdn-images-1.medium.com/max/1600/1*ufYwRmWgQeA-Jxg0zgYLOA.png" alt="用postman搞出来的get请求" title="用postman搞出来的get请求" %}}

让我们在body里包含交易结构发起post请求到 http://localhost:5000/transactions/new 创建一次新的交易：

{{% figure src="https://cdn-images-1.medium.com/max/1600/1*O89KNbEWj1vigMZ6VelHAg.png" alt="用postman搞出来的post请求" title="用postman搞出来的post请求" %}}

如果你没有用postman，也可用curl发起相同的请求：

<cite>
$ curl -X POST -H "Content-Type: application/json" -d '{
 "sender": "d4ee26eee15148ee92c6cd394edd974e",
 "recipient": "someone-other-address",
 "amount": 5
}' "http://localhost:5000/transactions/new"
</cite>

我重启我的server，挖2个块出来，总共3块了。让我们看一下完整的链条 http://localhost:5000/chain ：

<cite>
{
  "chain": [
    {
      "index": 1,
      "previous_hash": 1,
      "proof": 100,
      "timestamp": 1506280650.770839,
      "transactions": []
    },
    {
      "index": 2,
      "previous_hash": "c099bc...bfb7",
      "proof": 35293,
      "timestamp": 1506280664.717925,
      "transactions": [
        {
          "amount": 1,
          "recipient": "8bbcb347e0634905b0cac7955bae152b",
          "sender": "0"
        }
      ]
    },
    {
      "index": 3,
      "previous_hash": "eff91a...10f2",
      "proof": 35089,
      "timestamp": 1506280666.1086972,
      "transactions": [
        {
          "amount": 1,
          "recipient": "8bbcb347e0634905b0cac7955bae152b",
          "sender": "0"
        }
      ]
    }
  ],
  "length": 3
}
</cite>

step4 达成共识
---------------

这点非常酷。靠接收交易和允许我们开采新块，我们已经拥有一个基础的区块链了。但是区块链的本意是去中心化。如果需要去中心化，那究竟要如何做才能使所有节点都有相同的链条呢？这被称为共识问题，如果我们想在网络里多个节点的话，那需要实现一个共识算法

### 注册新节点

在实现共识算法前，我们需要一个方法，让网络上相邻节点之前互相知道。我们网络上的每个节点都应该保存其他节点的登记信息。这样的话我们需要更多的http请求节点：

1. /nodes/register 通过url接收一系列的新节点
2. /nodes/resolve  实现我们的共识算法，解决冲突－－确保每个节点都有正确的链条

我们需要修改一下Blockchain类的构造函数，提现一个方法出来注册节点：

```python
...
from urllib.parse import urlparse
...


class Blockchain(object):
    def __init__(self):
        ...
        self.nodes = set()
        ...

    def register_node(self, address):
        """
        添加新节点到节点列表中
        :param address: <str> Address of node. Eg. 'http://192.168.0.5:5000'
        :return: None
        """

        parsed_url = urlparse(address)
        self.nodes.add(parsed_url.netloc)
```

注意代码中我们使用了一个set来保存节点的列表。这一个廉价的确保新添加节点时幂等的方法－－意味着无论你添加一个指定的节点多少次，只会在里面出现一次。

### 实现共识算法

上面提到的，冲突是指一个节点与另一个节点有着不同的链条。为了解决冲突，我们制定了一个规则: 哪个验证过的链最长，哪个有效。换句话说，网络中最长的一条链就是真实的链。用这个算法，在我们网络中的节点间达成共识。

```python
...
import requests


class Blockchain(object)
    ...
    
    def valid_chain(self, chain):
        """
        确定给出的链条是否合法
        :param chain: <list> A blockchain
        :return: <bool> True if valid, False if not
        """

        last_block = chain[0]
        current_index = 1

        while current_index < len(chain):
            block = chain[current_index]
            print(f'{last_block}')
            print(f'{block}')
            print("\n-----------\n")
            # 检查块的hash是否正确
            if block['previous_hash'] != self.hash(last_block):
                return False

            # 检查proof是否正确
            if not self.valid_proof(last_block['proof'], block['proof']):
                return False

            last_block = block
            current_index += 1

        return True

    def resolve_conflicts(self):
        """
        这里是我们的共识算法，它把网络里最长的一条链来替换我们的以解决冲突

        :return: <bool> True if our chain was replaced, False if not
        """

        neighbours = self.nodes
        new_chain = None

        # 只找比我们的链条长的
        max_length = len(self.chain)

        # 从网络里取所有节点的链条来验证
        for node in neighbours:
            response = requests.get(f'http://{node}/chain')

            if response.status_code == 200:
                length = response.json()['length']
                chain = response.json()['chain']

                # 检查长度是否更长，且是否合法
                if length > max_length and self.valid_chain(chain):
                    max_length = length
                    new_chain = chain

        # 如果发了一条比我们长的合法链，进行替换
        if new_chain:
            self.chain = new_chain
            return True

        return False
```

来看第一个方法valid_chain，它负责检查一条链是否合法，办法是循环遍历每一块，检查他们的hash和proof值是否正确。

resolve_conflicts方法循环遍历所有的相邻节点，下载他们的链条来验证。***如果一个合法的链条被发现，并且比我们自己的好，就替换掉我们的。***

让我们注册两个节点到API上，一个是添加相邻节点，另一个是处理冲突：

```python
@app.route('/nodes/register', methods=['POST'])
def register_nodes():
    values = request.get_json()

    nodes = values.get('nodes')
    if nodes is None:
        return "Error: Please supply a valid list of nodes", 400

    for node in nodes:
        blockchain.register_node(node)

    response = {
        'message': 'New nodes have been added',
        'total_nodes': list(blockchain.nodes),
    }
    return jsonify(response), 201


@app.route('/nodes/resolve', methods=['GET'])
def consensus():
    replaced = blockchain.resolve_conflicts()

    if replaced:
        response = {
            'message': 'Our chain was replaced',
            'new_chain': blockchain.chain
        }
    else:
        response = {
            'message': 'Our chain is authoritative',
            'chain': blockchain.chain
        }

    return jsonify(response), 200
```

这里你可以在不同的机器上去启动网络里的新节点。也可以在相同的机器上用不同的端口来启动。我采取了后面的办法，注册到了当前的节点。现在，我有了两个节点：http://localhost:5000 和 http://localhost:5001 。

{{% figure src="https://cdn-images-1.medium.com/max/1600/1*Dd78u-gmtwhQWHhPG3qMTQ.png" alt="注册一个新节点" title="注册一个新节点" %}}

然后我在节点2上挖一个新块，让他的链条更长。搞完后，我请求节点1上的/nodes/resolve，节点1里的共识算法就会替换到新的链条：

{{% figure src="https://cdn-images-1.medium.com/max/1600/1*SGO5MWVf7GguIxfz6S8NVw.png" alt="共识算法工作了" title="共识算法工作了" %}}

搞定收工。。。去拉些小伙伴来帮你测试你的区块链吧。


---


希望本文可以激发你去创造一些新东西。我对加密货币感到欣喜，是因为我相邻区块链将会迅速改变我们对经济、政府和记录保存的看法。

***Update:***我正在准备写第二部分，计划扩展我们的区块链能力，包括交易验证机制，以及讨论一些产品化区块链的方法。

<cite>
如果你喜欢这篇文章，或者有任何建议和问题，可以在评论中告诉我。如果你发现有任何错误，你可以尽情贡献代码 https://github.com/dvf/blockchain !
</cite>

Translate from https://hackernoon.com/learn-blockchains-by-building-one-117428612f46

---

54chen点评：

当前区块链大热，但做了十年的分布式存储，一眼看这里最大的问题是取链条进行对比的过程，如果这个库的读写qps很高，这TM就是个灾难。欢迎更明白的同学到微博（54chen）来探讨。

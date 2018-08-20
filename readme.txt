http://voidstarzero.ca/post/137911090363/getting-started-with-protocol-buffers-in-racket

http://planet.racket-lang.org/archives/murphy/protobuf.plt/1/1/contents/planet-docs/generator/index.html

使用Racket(Scheme/Lisp)写的游戏服务器

安装好Racket之后，racket main.rkt  就可以运行服务器。

协议使用的ProtoBuf  

另外用使用nodejs写了一个测试客户端，可以收发一些简单命令

(serve port-no)是主入口函数，传入一个服务器需要监听的端口。

(game-loop) 在单独线程中运行，使用custodians(守护)机制，来释放所有系统资源，streams，线程等

game-loop的处理流程

1. 接收新来的连接(accept-conn)  
2. 接收并处理客户端发送的消息(read-conn)  
3. 发送给客户端的消息(flush-conn)  

在read/write连接时，如果出错，使用with-handlers来处理网络异常。


的在op.rkt中定义了示例消息号  
在route.rkt中定义了消息路由，哪个消息号的消息，由哪个函数处理  
在proto.rkt中定义了反序列化的消息，以供游戏逻辑代码使用

上面的定义比较简单粗暴，但是原理都是类似的

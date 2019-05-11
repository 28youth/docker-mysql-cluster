## 使用

##### 打包镜像
```dockerfile
docker build -t haproxy-keepalived . 
```
##### 修改镜像名
```dockerfile
docker tag docker.io/percona/percona-xtradb-cluster pxc
```

##### 处于安全考虑，为集群创建一个内部网络
```dockerfile
docker network create pxc-net
```

##### 由于pxc不能直接使用映射目录来启动，所以要创建docker数据卷，因为有三个节点，分别创建三个数据卷
```dockerfile
docker volume create --name mysql-data-node1
docker volume create --name mysql-data-node2
docker volume create --name mysql-data-node3
```

##### 查看数据卷信息，可以查看数据存放在本地的路径
```dockerfile
docker inspect <数据卷名称>
```

##### 创建mysql集群容器节点
##### 创建各个mysql节点时需要注意，最好先等第一个节点启动完成才创建第二或第三节点，如果第一节点的mysql还没初始化完成就创建第二或第三的话，有可能会造成同步数据失败。怎么才确认第一个节点的mysql初始化完毕呢？使用mysql客户端连接，如果能正常连接操作，说明第一个节点初始化完毕。

##### 创建第一个节点
```dockerfile
docker run -d --net=pxc-net -e MYSQL_ROOT_PASSWORD=123456 -e CLUSTER_NAME=PXC -e XTRABACKUP_PASSWORD=123456 --privileged \
-p 3306:3306 \
-v mysql-data-node1:/var/lib/mysql \
--name=mysql-node1 \
pxc
```

##### 创建第二个节点
```dockerfile
docker run -d --net=pxc-net -e MYSQL_ROOT_PASSWORD=123456 -e CLUSTER_NAME=PXC -e XTRABACKUP_PASSWORD=123456 --privileged \
-p 3307:3306 \
-v mysql-data-node2:/var/lib/mysql \
--name=mysql-node2 \
-e CLUSTER_JOIN=mysql-node1 \
pxc
```

##### 创建第三个节点
```dockerfile
docker run -d --net=pxc-net -e MYSQL_ROOT_PASSWORD=123456 -e CLUSTER_NAME=PXC -e XTRABACKUP_PASSWORD=123456 --privileged \
-p 3308:3306 \
-v mysql-data-node3:/var/lib/mysql \
--name=mysql-node3 \
-e CLUSTER_JOIN=mysql-node1 \
pxc
```

##### 使用mysql客户端连接一个节点，修改数据，如果其他节点数据同步成功，说明mysql集群搭建完成。

##### 添加负载均衡使用Haproxy容器 命名为h1
```dockerfile
docker run -it -d \
-p 7101:6688 -p 7001:3306 \
-v ./haproxy.cfg:/usr/local/etc/haproxy/haproxy.cfg \
-v ./keepalived.conf:/etc/keepalived/keepalived.conf \
--name h1 --privileged --net=pxc-net haproxy-keepalived
```

##### 实现高可用负载均衡器 单点负载均衡器的缺点是当负载均衡器出现故障时，整个系统就不能工作了，需要多个作为备用才能实现高可用。
##### 启用刚开始打包的haproxy-keepalived镜像  命名为h2
```dockerfile
docker run -it -d \
-p 7102:6688 -p 7002:3306 \
-v ./haproxy.cfg:/usr/local/etc/haproxy/haproxy.cfg \
-v ./keepalived.conf:/etc/keepalived/keepalived.conf \
--name h2 --privileged --net=pxc-net haproxy-keepalived
```

##### 实现外部访问mysql集群PXC
##### 现在问题是虚拟ip属于容器内网，只能在本机访问，为了能够使外面访问，需要在宿主机也安装keepalived，把宿主机指定的虚拟ip指向负载均衡器的虚拟ip
##### 宿主机安装keepalived：
```dockerfile
yum install -y keepalived
```

##### 使用local-keepalived.conf 替换宿主机 /etc/keepalived/keepalived.conf 配置文件
##### 启动keepalived
```dockerfile
keepalived -f /etc/keepalived/keepalived.conf
```

##### end 然后使用mysql客户端测试是否可以连接mysql集群 外网IP加默认端口3306
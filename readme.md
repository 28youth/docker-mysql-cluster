### 使用

# 打包镜像
docker build -t haproxy-keepalived . 

# 启动mysql集群
docker-compose up -d

# 登录集群中的一个节点的mysql创建一个haproxy用户
mysql -h 192.168.8.200 -u root -p 123456 

# 启动宿主机的 keepalived
keepalived -f /etc/keepalived/keepalived.conf

FROM haproxy

# 安装keepalived
RUN apt-get -y update
RUN apt-get -y install keepalived
RUN mkdir -p /usr/local/etc/haproxy

# 启动keepalived和haproxy
CMD keepalived -f /etc/keepalived/keepalived.conf && haproxy -f /usr/local/etc/haproxy/haproxy.cfg

FROM haproxy

RUN echo "deb http://mirrors.aliyun.com/debian stretch main contrib non-free \
	deb-src http://mirrors.aliyun.com/debian stretch main contrib non-free \
	deb http://mirrors.aliyun.com/debian stretch-updates main contrib non-free \
	deb-src http://mirrors.aliyun.com/debian stretch-updates main contrib non-free \
	deb http://mirrors.aliyun.com/debian-security stretch/updates main contrib non-free \
	deb-src http://mirrors.aliyun.com/debian-security stretch/updates main contrib non-free \
	deb http://mirrors.aliyun.com/debian/ stretch-backports main non-free contrib \
	deb-src http://mirrors.aliyun.com/debian/ stretch-backports main non-free contrib" > /etc/apt/sources.list

# 安装keepalived
RUN apt-get -y update
RUN apt-get -y install keepalived
RUN mkdir -p /usr/local/etc/haproxy

# 启动keepalived和haproxy
CMD keepalived -f /etc/keepalived/keepalived.conf && haproxy -f /usr/local/etc/haproxy/haproxy.cfg
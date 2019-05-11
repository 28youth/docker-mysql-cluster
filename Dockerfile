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

FROM alpine

## Add your application to the docker image
ADD MySuperApp.sh /MySuperApp.sh

## Add the wait script to the image
ADD https://github.com/ufoscout/docker-compose-wait/releases/download/2.5.0/wait /wait
RUN chmod +x /wait

## Launch the wait tool and then your application
CMD /wait && /MySuperApp.sh
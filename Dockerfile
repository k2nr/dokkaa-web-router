FROM debian:wheezy
MAINTAINER Kazunori Kajihiro <likerichie@gmail.com> (@k2nr)

ENV DEBIAN_FRONTEND noninteractive

RUN apt-key adv --keyserver pgp.mit.edu --recv-keys 573BFD6B3D8FBC641079A6ABABF5BD827BD9BF62 && \
    echo "deb http://nginx.org/packages/mainline/debian/ wheezy nginx" >> /etc/apt/sources.list && \
    echo "deb-src http://nginx.org/packages/mainline/debian/ wheezy nginx" >> /etc/apt/sources.list && \
    apt-get update && \
    apt-get install -y --no-install-recommends wget && \
    apt-get build-dep -y --no-install-recommends nginx && \
    apt-get -q -y clean && \
    rm -rf /var/cache/apt/archives/* /var/lib/apt/lists/*

RUN wget http://openresty.org/download/ngx_openresty-1.7.4.1.tar.gz && \
    tar xvfz ngx_openresty-1.7.4.1.tar.gz && \
    cd ngx_openresty-1.7.4.1 && \
    ./configure --with-pcre-jit --with-ipv6 && \
    make && \
    make install && \
    rm -rf /ngx_openresty* && \
    ln -s /usr/local/openresty/nginx/sbin/nginx /usr/bin/nginx


ENV NS_IP 127.0.0.1
ENV NS_PORT 53
ENV TARGET web.skydns.local
ENV DOMAINS dokkaa.io

EXPOSE 80 443

# forward request and error logs to docker log collector
RUN mkdir -p /nginx/logs && \
    ln -sf /dev/stdout /nginx/logs/access.log && \
    ln -sf /dev/stderr /nginx/logs/error.log

ADD conf /nginx

CMD ["/usr/bin/nginx", "-p", "/nginx/", "-c", "nginx.conf"]

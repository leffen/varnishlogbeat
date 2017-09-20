FROM golang:1.8

LABEL maintainer phenomenes

ENV PATH=$PATH:$GOPATH/bin

RUN apt-get update && apt-get install -y \
	libjemalloc1 curl\
	pkg-config \
	&& apt-get clean && rm -rf /var/lib/apt/lists/*

# https://packagecloud.io/varnishcache/varnish5/packages/debian/jessie/varnish-dev_5.2.0-1~jessie_amd64.deb

# RUN curl -O https://repo.varnish-cache.org/pkg/5.0.0/varnish_5.0.0-1_amd64.deb \
#	 -O https://repo.varnish-cache.org/pkg/5.0.0/varnish-dev_5.0.0-1_amd64.deb \

RUN curl -s https://packagecloud.io/install/repositories/varnishcache/varnish5/script.deb.sh | bash
RUN apt-get install -y varnish-dev=5.0.0-1 varnish=5.0.0-1

#RUN curl -O https://packagecloud.io/varnishcache/varnish5/packages/debian/jessie/varnish_5.2.0-1~jessie_amd64.deb \
#	 -O https://packagecloud.io/varnishcache/varnish5/packages/debian/jessie/varnish-dev_5.2.0-1~jessie_amd64.deb\
#        && dpkg -i varnish_5.2.0-1~jessie_amd64.deb \
#	&& dpkg -i varnish-dev_5.2.0-1~jessie_amd64.deb \
#	&& rm varnish_5.2.0-1~jessie_amd64.deb varnish-dev_5.2.0-1~jessie_amd64.deb 
RUN mkdir -p $GOPATH/src/github.com/phenomenes/varnishlogbeat

COPY . $GOPATH/src/github.com/phenomenes/varnishlogbeat

WORKDIR $GOPATH/src/github.com/phenomenes/varnishlogbeat

RUN go build .

COPY default.vcl /etc/varnish/default.vcl
COPY docker-entrypoint.sh /docker-entrypoint.sh

RUN sed -i 's/localhost:9200/elasticsearch:9200/' \
	$GOPATH/src/github.com/phenomenes/varnishlogbeat/varnishlogbeat.yml

EXPOSE 8080

CMD /docker-entrypoint.sh
#CMD /bin/bash
FROM golang:1.8

ARG jfrog
ARG dest_url

LABEL maintainer phenomenes

ENV PATH=$PATH:$GOPATH/bin

RUN apt-get update && apt-get install -y \
	libjemalloc1 curl\
	pkg-config \
	&& apt-get clean && rm -rf /var/lib/apt/lists/*


RUN curl -s https://packagecloud.io/install/repositories/varnishcache/varnish5/script.deb.sh | bash
RUN apt-get install -y varnish-dev=5.0.0-1 varnish=5.0.0-1

RUN mkdir -p $GOPATH/src/github.com/phenomenes/varnishlogbeat

COPY . $GOPATH/src/github.com/phenomenes/varnishlogbeat

WORKDIR $GOPATH/src/github.com/phenomenes/varnishlogbeat

RUN go build .

# Copy to deploy area. Can be omitted
RUN curl -u$jfrog -T varnishlogbeat "${dest_url}varnishlogbeat" && \
 curl -u$jfrog -T varnishlogbeat.yml "${dest_url}varnishlogbeat.yml"

COPY default.vcl /etc/varnish/default.vcl
COPY docker-entrypoint.sh /docker-entrypoint.sh

RUN sed -i 's/localhost:9200/elasticsearch:9200/' \
	$GOPATH/src/github.com/phenomenes/varnishlogbeat/varnishlogbeat.yml

EXPOSE 8080

CMD /docker-entrypoint.sh
#CMD /bin/bash
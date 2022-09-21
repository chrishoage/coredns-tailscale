FROM golang:1.19-alpine AS build

WORKDIR /go/src/coredns

RUN apk add git make && \
    git clone --depth 1 --branch=v1.9.4 https://github.com/coredns/coredns /go/src/coredns && cd plugin

COPY . /go/src/coredns/plugin/coredns-tailscale

    # git clone https://github.com/damomurf/coredns-tailscale tailscale && \
RUN cd plugin && \
    sed -i s/forward:forward/tailscale:github.com\\/damomurf\\/coredns-tailscale\\nforward:forward/ /go/src/coredns/plugin.cfg && \
    cat /go/src/coredns/plugin.cfg && \
    cd .. && \
    make check && \
    go build

FROM alpine:3.16
RUN apk add --no-cache ca-certificates

COPY --from=build /go/src/coredns/coredns /
COPY Corefile run.sh /

ENTRYPOINT ["/run.sh"]

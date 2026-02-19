FROM golang:1.22-alpine AS builder
RUN go env -w GO111MODULE=auto \
    && go env -w CGO_ENABLED=0 \
    && go env -w GOPROXY=https://goproxy.cn,direct
WORKDIR /build
COPY . .
RUN set -ex \
    && cd /build \
    && pwd \
    && ls \
    && go build -ldflags "-s -w -extldflags '-static'" -o App ./main.go

FROM alpine:latest
WORKDIR /Serve
RUN mkdir config
COPY --from=builder /build/App ./App
RUN echo 'https://dl-cdn.alpinelinux.org/alpine/latest-stable/main' > /etc/apk/repositories \
    && echo 'https://dl-cdn.alpinelinux.org/alpine/latest-stable/community' >>/etc/apk/repositories \
    && apk update && apk add tzdata procps \
    && ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime \
    && echo "Asia/Shanghai" > /etc/timezone
EXPOSE 8080
ENTRYPOINT [ "/Serve/App" ]

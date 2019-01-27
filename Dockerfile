FROM alpine:3.8

RUN apk --no-cache add bash jq curl perl-utils sed

WORKDIR /opt/resource

COPY src/*  /opt/resource/
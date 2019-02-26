FROM alpine:3.9

RUN apk --no-cache add bash jq curl perl-utils sed

LABEL org.label-schema.schema-version="1.0" \
      org.label-schema.name="concourse-resource-github-list-repos" \
      org.label-schema.description="A Concourse resource for fetching the list of repositories belonging to a GitHub organization or team." \
      org.label-schema.vcs-url="https://github.com/coralogix/eng-concourse-resource-github-list-repos" \
      org.label-schema.vendor="Coralogix, Inc." \
      org.label-schema.version="v0.3.1"

WORKDIR /opt/resource

COPY src/*  /opt/resource/
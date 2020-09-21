FROM arm32v7/golang

ENV GOARCH=arm
ARG KUBE_LEGO_VERSION=0.1.7

RUN git clone --branch $KUBE_LEGO_VERSION --depth 1 https://github.com/jetstack/kube-lego.git ${GOPATH}/src/github.com/jetstack/kube-lego \
&&  sed -i 's/GOARCH :=/GOARCH? :=/' ${GOPATH}/src/github.com/jetstack/kube-lego/Makefile \
&&  cd ${GOPATH}/src/github.com/jetstack/kube-lego \
&&  make build

FROM armhf/alpine

# install ca certificates for comms with Let's Encrypt
RUN apk --update add ca-certificates && rm -rf /var/cache/apk/*

# add user / group
RUN addgroup -g 1000 app && \
    adduser -G app -h /home/app -u 1000 -D app

# move to user / group
USER app
WORKDIR /home/app

COPY --from=0 /go/src/github.com/jetstack/kube-lego/_build/kube-lego-linux-arm /kube-lego
ENTRYPOINT ["/kube-lego"]
ARG VCS_REF
LABEL org.label-schema.vcs-ref=$VCS_REF \
      org.label-schema.vcs-url="https://github.com/jetstack/kube-lego" \
      org.label-schema.license="Apache-2.0"
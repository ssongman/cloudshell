FROM --platform=${BUILDPLATFORM:-linux/amd64} node:18.5.0 as builder
# Build frontend code which added upload/download button
RUN git clone --depth=1 https://github.com/cloudtty/cloudtty && \
    cp -r cloudtty/html/ /app/
WORKDIR /app
RUN yarn install
RUN yarn run build

FROM --platform=${BUILDPLATFORM:-linux/amd64} ghcr.io/dtzar/helm-kubectl:3.9

ENV BUILDPLATFORM=${BUILDPLATFORM:-linux/amd64}
COPY install-ttyd.sh /bin/install-ttyd.sh
COPY install-vela.sh /bin/install-vela.sh
RUN echo "https://dl-cdn.alpinelinux.org/alpine/edge/testing/" >> /etc/apk/repositories \
    && apk -U upgrade \
    && apk add --no-cache ca-certificates lrzsz vim \
    && ln -s /usr/bin/lrz	/usr/bin/rz \
    && ln -s /usr/bin/lsz	/usr/bin/sz \
    && /bin/install-ttyd.sh \
    && /bin/install-vela.sh

COPY --from=builder /app/dist/inline.html index.html
ENTRYPOINT ttyd
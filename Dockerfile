FROM --platform=${BUILDPLATFORM:-linux/amd64} node:18.5.0 as builder
# Build frontend code which added upload/download button
RUN git clone --depth=1 https://github.com/cloudtty/cloudtty && \
    cp -r cloudtty/html/ /app/
WORKDIR /app
RUN yarn install
RUN yarn run build

FROM --platform=${BUILDPLATFORM:-linux/amd64} ghcr.io/dtzar/helm-kubectl:3.9
ARG VERSION
ENV BUILDPLATFORM=${BUILDPLATFORM:-linux/amd64}
ENV VERSION=${VERSION}
COPY install-ttyd.sh /bin/install-ttyd.sh
RUN echo -e "http://nl.alpinelinux.org/alpine/v3.5/main\nhttp://nl.alpinelinux.org/alpine/v3.5/community" >> /etc/apk/repositories \
    && apk add --no-cache bash ca-certificates \
    && /bin/install-ttyd.sh 

COPY --from=builder /app/dist/inline.html index.html
ENTRYPOINT ttyd

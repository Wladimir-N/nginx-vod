FROM alpine:3.14
FROM base_image AS build
WORKDIR /nginx
ARG NGINX_VERSION=1.21.1
ARG VOD_MODULE_VERSION=1.28
RUN apk add --no-cache curl build-base openssl openssl-dev zlib-dev linux-headers pcre-dev ffmpeg ffmpeg-dev && \
    mkdir /nginx /nginx-vod-module && \
    curl -sL https://nginx.org/download/nginx-${NGINX_VERSION}.tar.gz | tar -C /nginx --strip 1 -xz && \
    curl -sL https://github.com/kaltura/nginx-vod-module/archive/refs/tags/${VOD_MODULE_VERSION}.tar.gz | tar -C /nginx-vod-module --strip 1 -xz && \
    ./configure --prefix=/usr/local/nginx \
     --add-module=../nginx-vod-module \
	 --with-file-aio \
	 --with-threads \
	 --with-cc-opt="-O3" && \
    make && \
    make install && \
    rm -rf /usr/local/nginx/html /usr/local/nginx/conf/*.default
FROM base_image
RUN apk add --no-cache pcre zlib ffmpeg
COPY --from=build /usr/local/nginx /usr/local/nginx
ENTRYPOINT ["/usr/local/nginx/sbin/nginx"]
CMD ["-g", "daemon off;"]

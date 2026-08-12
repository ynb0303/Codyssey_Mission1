FROM nginx:alpine
LABEL org.opencontainers.image.title="ynb0303-custom-nginx"
ENV APP_ENV=dev
COPY index.html /usr/share/nginx/html/index.html

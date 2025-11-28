FROM alpine:latest

RUN apk update && \
    apk add --no-cache bash shadow coreutils nss-pam-ldapd && \
    rm -rf /var/cache/apk/*

WORKDIR /usr/local/bin
COPY user_last_login.sh .

RUN chmod +x user_last_login.sh

ENTRYPOINT ["/usr/local/bin/user_last_login.sh"]
CMD ["--help"]

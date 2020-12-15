FROM postgres:alpine
RUN apk update                                          \
    apk upgrade                                         \
    apk add --update alpine-sdk                         \
    apk add --no-cache bash git openssh make cmake      \
    apk add curl-dev                                    \
    apk add clang                                       \
    apk add llvm9                                       \
    make                                                \
    make install
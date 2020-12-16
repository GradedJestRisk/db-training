FROM postgres:13-alpine
RUN apk add --no-cache git g++ make clang llvm10
RUN git clone https://github.com/petere/plsh && \
    cd plsh && \
    make && \
    make install

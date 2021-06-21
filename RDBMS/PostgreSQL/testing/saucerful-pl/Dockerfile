#FROM postgres:13-alpine
FROM clkao/postgres-plv8:12-2
MAINTAINER GradedjestRisk <graded.jest.risk@gmail.com>
#
RUN deb http://apt.llvm.org/buster/ llvm-toolchain-buster-10 main      && \
    deb-src http://apt.llvm.org/buster/ llvm-toolchain-buster-10 main  && \

    git    \
    g++    \
    make   \
    clang  \
    llvm10 \
#
RUN git clone https://github.com/petere/plsh && \
    cd plsh                                  && \
    make                                     && \
    make install
#RUN apk add --no-cache openssh cmake curl-dev
#RUN git clone https://github.com/pramsey/pgsql-http.git && \
#    cd pgsql-http                                       && \
#    make                                                && \
#    make install

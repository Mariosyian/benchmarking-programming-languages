FROM ubuntu:20.04

WORKDIR /home/benchmarking-programming-languages

# Install pre-requisites
#   Versions at time of writing:
#       gcc -- version (Ubuntu 9.3.0-17ubuntu1~20.04) 9.3.0
#       make -- GNU Make 4.2.1
#       curl -- 7.68.0
RUN apt update && apt install make build-essential curl wget tar -y

# Install `column`
RUN wget https://mirrors.edge.kernel.org/pub/linux/utils/util-linux/v2.35/util-linux-2.35-rc1.tar.gz
RUN tar xfz util-linux-2.35-rc1.tar.gz
WORKDIR util-linux-2.35-rc1
RUN ./configure
RUN make column
RUN cp .libs/column /bin/
WORKDIR /home/benchmarking-programming-languages
RUN rm -rf util-linux-2.35-rc1*

RUN apt install python3 pip -y

# RUN apt install default-jdk-headless -y

RUN apt install rustc -y

RUN if ! test -d /home/benchmarking-programming-languages; then mkdir /home/benchmarking-programming-languages && echo "Created directory /home/benchmarking-programming-languages."; fi
COPY . /home/benchmarking-programming-languages

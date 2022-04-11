FROM ubuntu:20.04

# Required for Debian interaction
# (https://stackoverflow.com/questions/62299928/r-installation-in-docker-gets-stuck-in-geographic-area)
ENV DEBIAN_FRONTEND noninteractive

WORKDIR /home/benchmarking-programming-languages

# Install pre-requisites
#   Versions at time of writing:
#       gcc -- version (Ubuntu 9.3.0-17ubuntu1~20.04) 9.3.0
#       make -- GNU Make 4.2.1
#       curl -- 7.68.0
RUN apt update && apt install make build-essential curl wget tar bc -y

# Install `column`
RUN wget https://mirrors.edge.kernel.org/pub/linux/utils/util-linux/v2.35/util-linux-2.35-rc1.tar.gz
RUN tar xfz util-linux-2.35-rc1.tar.gz
WORKDIR /home/benchmarking-programming-languages/util-linux-2.35-rc1
RUN ./configure
RUN make column
RUN cp .libs/column /bin/
WORKDIR /home/benchmarking-programming-languages
RUN rm -rf util-linux-2.35-rc1*

RUN apt install python3 pip -y
RUN ln -s /usr/bin/python3 /usr/bin/python
RUN apt install default-jdk-headless -y
RUN apt install rustc -y

# Install GoLang
RUN wget https://go.dev/dl/go1.17.8.linux-amd64.tar.gz
RUN rm -rf /usr/local/go && tar -C /usr/local -xzf go1.17.8.linux-amd64.tar.gz
ENV PATH="/usr/local/go/bin:${PATH}"

# Install Haxe and Haxelib
RUN wget https://github.com/HaxeFoundation/haxe/releases/download/4.2.5/haxe-4.2.5-linux64.tar.gz
RUN tar xfz haxe-4.2.5-linux64.tar.gz
RUN ln -s /home/benchmarking-programming-languages/haxe_20220306074705_e5eec31/haxe /usr/bin/haxe
RUN ln -s /home/benchmarking-programming-languages/haxe_20220306074705_e5eec31/haxelib /usr/bin/haxelib
# # Install Neko (Haxe VM)
# RUN add-apt-repository ppa:haxe/snapshots -y
# RUN apt update
# RUN apt install neko -y

RUN if ! test -d /home/benchmarking-programming-languages; then mkdir /home/benchmarking-programming-languages && echo "Created directory /home/benchmarking-programming-languages."; fi
COPY . /home/benchmarking-programming-languages
RUN if ! test -d /home/benchmarking-programming-languages/benchmarks; then mkdir /home/benchmarking-programming-languages/benchmarks && echo "Created directory /home/benchmarking-programming-languages/benchmarks."; fi

RUN pip install -r /home/benchmarking-programming-languages/requirements_dev.txt

CMD [ "/home/benchmarking-programming-languages/benchmark.sh", "-v" ]

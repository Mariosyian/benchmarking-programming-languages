FROM ubuntu:20.04

WORKDIR /home/benchmarking-programming-languages

# Install pre-requisites
#   Versions at time of writing:
#       gcc -- version (Ubuntu 9.3.0-17ubuntu1~20.04) 9.3.0
#       make -- GNU Make 4.2.1
#       curl -- 7.68.0
RUN apt update && apt install make build-essential curl -y

RUN apt install python3 pip -y

RUN if ! test -d /home/benchmarking-programming-languages; then mkdir /home/benchmarking-programming-languages && echo "Created directory /home/benchmarking-programming-languages."; fi
COPY . /home/benchmarking-programming-languages

RUN pip install -r /home/benchmarking-programming-languages/requirements_dev.txt

CMD [ "/home/benchmarking-programming-languages/benchmark.sh" ]

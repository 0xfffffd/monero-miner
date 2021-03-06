FROM ubuntu:latest AS build

ARG XMRIG_VERSION='v5.4.0'

RUN apt-get update && apt-get install -y git build-essential cmake libuv1-dev libssl-dev libhwloc-dev

WORKDIR /root
RUN git clone https://github.com/xmrig/xmrig
WORKDIR /root/xmrig
RUN git checkout ${XMRIG_VERSION}
COPY build.patch /root/xmrig/
RUN git apply build.patch
RUN mkdir build && cd build && cmake .. -DOPENSSL_USE_STATIC_LIBS=TRUE && make


FROM ubuntu:latest
RUN apt-get update && apt-get install -y libhwloc5 mc net-tools iputils-ping htop
RUN apt-get -y install sudo
RUN useradd -ms /bin/bash monero
RUN echo "monero:monero" | chpasswd && adduser monero sudo

USER monero
WORKDIR /home/monero
COPY --from=build --chown=monero /root/xmrig/build/xmrig /home/monero


ENTRYPOINT ["./xmrig"]
CMD ["--url=monerohash.com:2222", "--user=482YJA55kFVJ9w4FxhgN5dL57nx7yAb11VTdXoxpYVhv2CaDyWpvL8BiKG6FPYqhQZX7btTF4GoRED6gzDffbRLAJYtFEzJ", "--donate-level=1", "--randomx-1gb-pages", "--randomx-mode=fast", "--asm=intel", "--pass=Docker", "-k"]˚

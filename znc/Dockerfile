FROM debian:latest
ENV DEBIAN_FRONTEND noninteractive
RUN apt-get update && apt-get -y install znc git znc-dev build-essential
RUN mkdir -p /tmp
WORKDIR /tmp
RUN git clone https://github.com/cynix/znc-identd.git
WORKDIR /tmp/znc-identd
RUN znc-buildmod identd.cc
RUN groupadd -g 2005 znc
RUN useradd  -m -u 2006 -g znc znc -d /home/znc
RUN mkdir -p /home/znc/.znc/modules
RUN cp identd.so /home/znc/.znc/modules
RUN setcap CAP_NET_BIND_SERVICE=+eip $(which znc)
RUN chown -R 2006:2005 /home/znc
RUN apt-get update && apt-get -y remove git znc-dev build-essential
WORKDIR /tmp
RUN rm -rf znc-identd
USER znc
WORKDIR /home/znc
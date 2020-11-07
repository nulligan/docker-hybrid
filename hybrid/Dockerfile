FROM debian:latest
RUN apt-get update && apt-get -y install git subversion libssl-dev build-essential autoconf automake1.11 clang zlib1g-dev libsqlite3-dev
RUN mkdir -p /tmp/hybrd
WORKDIR /tmp/hybrid
RUN git clone https://github.com/ircd-hybrid/ircd-hybrid.git 
WORKDIR /tmp/hybrid/ircd-hybrid
RUN ./configure --prefix=/usr/local/ircd
RUN make
RUN make install
WORKDIR /usr/local/ircd
RUN rm -rf /tmp/hybrid
RUN apt -y remove git subversion libssl-dev build-essential autoconf automake1.11 clang zlib1g-dev libsqlite3-dev
RUN groupadd -g 2000 ircd
RUN useradd -m -u 2001 -g ircd ircd
RUN mkdir -p /usr/local/ircd/logs
RUN chown -R 2001:2000 /usr/local/ircd
USER ircd

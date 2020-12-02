FROM debian:latest
RUN apt-get update && apt-get -y install git subversion libssl-dev build-essential autoconf automake1.11 clang zlib1g-dev libsqlite3-dev
RUN mkdir -p /tmp/hopm
WORKDIR /tmp/hopm
RUN git clone https://github.com/ircd-hybrid/hopm.git
WORKDIR /tmp/hopm/hopm
RUN ./configure --prefix=/usr/local/hopm
RUN make
RUN make install
WORKDIR /usr/local/hopm
RUN rm -rf /tmp/hopm
RUN apt -y remove git subversion libssl-dev build-essential autoconf automake1.11 clang zlib1g-dev libsqlite3-dev
RUN groupadd -g 2000 ircd
RUN useradd -m -u 2001 -g ircd ircd
RUN mkdir -p /usr/local/ircd/logs
RUN chown -R 2001:2000 /usr/local/ircd
USER ircd

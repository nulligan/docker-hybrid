FROM debian:latest
ENV DEBIAN_FRONTEND noninteractive
RUN apt-get update && apt-get -y install irssi
RUN groupadd -g 2002 console
RUN useradd  -m -u 2003 -g console console -d /home/console
RUN mkdir -p /home/console
RUN chown -R 2003:2002 /home/console
USER console

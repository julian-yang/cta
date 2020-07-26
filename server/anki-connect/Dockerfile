## Custom Dockerfile
FROM consol/ubuntu-xfce-vnc
ENV REFRESHED_AT 2018-03-18

# Switch to root user to install additional software
USER 0

## Install a gedit
# RUN yum install -y gcc gcc-c++ kernel-devel
# RUN echo "$(pwd)"; curl https://apps.ankiweb.net/downloads/archive/anki-2.1.16-linux-amd64.tar.bz2 --output ~/anki-2.1.16-linux-amd64.tar.bz2 \
#     && tar xjf ~/anki-2.1.16-linux-amd64.tar.bz2 \ 
#     && echo "done untar!"; ls; cd ~/anki-2.1.16-linux-amd64 \
#     && echo "done cd!"; sudo make install
FROM ubuntu:latest

ENV LANG en_US.UTF-8
ENV ANKI_VERSION=2.1.19

RUN apt-get update
RUN  apt-get install -y software-properties-common
#  
#  RUN apt-get clean
#  RUN apt-get update
#  RUN apt-get upgrade 
#  RUN add-apt-repository main
#  RUN add-apt-repository universe
#  RUN add-apt-repository restricted
 # RUN add-apt-repository multiverse
RUN set -ex && apt-get update

#RUN set -ex && apt-get install -y --no-install-recommends \
RUN set -ex && apt install -y \
        wget \
        ca-certificates \
        build-essential \
        mpv \
        lame \
        xdg-utils \
        libnss3 \
        # pyqt4-dev-tools \
        python3-pyqt5 \
        # python3-pyqt4 python-qt3 \
        mplayer locales materia-gtk-theme papirus-icon-theme dmz-cursor-theme

        # pyqt5-dev-tools \

RUN sed -i -e "s/# en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/" /etc/locale.gen && \
  dpkg-reconfigure --frontend=noninteractive locales && \
  update-locale


RUN mkdir -p /build/src/
WORKDIR /build/src

RUN wget https://apps.ankiweb.net/downloads/current/anki-$ANKI_VERSION-linux-amd64.tar.bz2


RUN tar xjf anki-$ANKI_VERSION-linux-amd64.tar.bz2

WORKDIR /build/src/anki-$ANKI_VERSION-linux-amd64

RUN make install



#RUN set -ex && apt-get install -y \
        # libxkbcommon-x11-0

#- remove apt cache
RUN set -ex \
    && rm -rf /var/lib/apt/lists/*

ENTRYPOINT [ "anki", "--no-sandbox" ]

## switch back to default user
USER 1000

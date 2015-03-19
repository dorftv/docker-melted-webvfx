FROM trickkiste/ubuntu-decklink:latest
MAINTAINER Stefan Hageneder <stefan.hageneder@dorftv.at>
ENV DEBIAN_FRONTEND noninteractive
ENV HOME /tmp

ADD build-melted.conf /tmp/build-melted.conf

# Installing all build tools, download and build melted and webvfx
RUN apt-get update && apt-get install -y git automake autoconf libtool intltool g++ yasm swig libmp3lame-dev libgavl-dev libsamplerate-dev libxml2-dev ladspa-sdk libjack-dev libsox-dev libsdl-dev libgtk2.0-dev liboil-dev libsoup2.4-dev libqt4-dev libexif-dev libtheora-dev libvdpau-dev libvorbis-dev python-dev && cd /tmp/ && git clone https://github.com/mltframework/mlt-scripts.git && /tmp/mlt-scripts/build/build-melted.sh -c /tmp/build-melted.conf && cd /tmp/melted && git clone https://github.com/mltframework/webvfx.git && cd /tmp/melted/webvfx && qmake -r PREFIX=/usr && make install && rm -r /tmp/melted && rm /tmp/build-melted.conf && rm -r /tmp/mlt-scripts && apt-get remove -y automake autoconf libtool intltool g++ libmp3lame-dev libgavl-dev libsamplerate-dev libxml2-dev libjack-dev libsox-dev libsdl-dev libgtk2.0-dev liboil-dev libsoup2.4-dev libqt4-dev libexif-dev libtheora-dev libvdpau-dev libvorbis-dev python-dev manpages manpages-dev g++ g++-4.6 git && rm -rf /var/lib/apt/lists/* && apt-get -y autoclean && apt-get -y clean && apt-get -y autoremove

# Installing needed libraries
RUN apt-get update && apt-get install -y xvfb libmp3lame0 libgavl1 libsamplerate0 libsoxr-lsr0 libxml2 libjack0 libsox2 libsdl1.2debian libgtk2.0-0 liboil0.3 libsoup2.4-1 libqt4-opengl libqt4-svg libqtgui4 libexif12 libtheora0 libvdpau1 libvorbis0a libvorbisenc2 libvorbisfile3 libxcb-shm0 libqtwebkit4 && rm -rf /var/lib/apt/lists/* && apt-get -y autoclean && apt-get -y clean && apt-get -y autoremove



# Melted will be run as user default in userspace
RUN     useradd -m default
USER    default
WORKDIR /home/default
ENV     HOME /home/default

ADD melted.sh /home/default/melted.sh
COPY melted.conf /etc/melted/melted.conf

# This is only mentioned here for documentation. 
# The desired MLT_PROFILE env should be set via "docker run -e MLT_PROFILE=atsc_1080i_50" and/or in melted.conf
# ENV	MLT_PROFILE atsc_1080i_50

# We start with a wrapper script so we can use xvfb-run
EXPOSE 5250
ENTRYPOINT ["/home/default/melted.sh"]

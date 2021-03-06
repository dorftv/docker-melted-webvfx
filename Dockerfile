FROM debian:wheezy
MAINTAINER Stefan Hageneder <stefan.hageneder@dorftv.at>
ENV DEBIAN_FRONTEND noninteractive
ENV HOME /tmp

ADD build-melted.conf /tmp/build-melted.conf

# Installing all build tools, download and build melted and webvfx
RUN apt-get update && apt-get install -y git automake autoconf libtool intltool g++ swig libmp3lame-dev libgavl-dev libsamplerate-dev libxml2-dev ladspa-sdk libjack-dev libsox-dev libsdl-dev libgtk2.0-dev liboil-dev  libsoup2.4-dev libqt4-dev libexif-dev libtheora-dev libvdpau-dev libvorbis-dev python-dev libtool && cd /tmp/ && curl --remote-name http://www.tortall.net/projects/yasm/releases/yasm-1.2.0.tar.gz && tar -xvzf yasm-1.2.0.tar.gz && cd yasm-1.2.0 && ./configure; make && make install

RUN cd /tmp/ && cd /tmp && git clone https://github.com/mltframework/mlt-scripts.git && /tmp/mlt-scripts/build/build-melted.sh -c /tmp/build-melted.conf && cd /tmp/melted && git clone https://github.com/mltframework/webvfx.git && cd /tmp/melted/webvfx && qmake -r PREFIX=/usr && make install && rm -r /tmp/melted && rm /tmp/build-melted.conf && rm -r /tmp/mlt-scripts && apt-get remove -y automake autoconf libtool intltool g++ libmp3lame-dev libgavl-dev libsamplerate-dev libxml2-dev libjack-dev libsox-dev libsdl-dev libgtk2.0-dev liboil-dev libsoup2.4-dev libqt4-dev libexif-dev libtheora-dev libvdpau-dev libvorbis-dev python-dev manpages manpages-dev g++ g++-4.6 git && rm -rf /var/lib/apt/lists/* && apt-get -y autoclean && apt-get -y clean && apt-get -y autoremove

# Installing needed libraries
RUN apt-get update && apt-get install -y xvfb libmp3lame0 libgavl1 libsamplerate0 libxml2 libjack0 libsox2 libsdl1.2debian libgtk2.0-0 liboil0.3 libsoup2.4-1 libqt4-opengl libqt4-svg libqtgui4 libexif12 libtheora0 libvdpau1 libvorbis0a libvorbisenc2 libvorbisfile3 libxcb-shm0 libqtwebkit4 && rm -rf /var/lib/apt/lists/* && apt-get -y autoclean && apt-get -y clean && apt-get -y autoremove

#libsoxr-lsr0 

# Install Blackmagic drives and libs
RUN apt-get update && apt-get install -y curl wget dkms libjpeg62 libgl1-mesa-glx libxml2 
RUN wget --quiet -O /tmp/Blackmagic_Desktop_Video_Linux_10.1.1.tar.gz http://software.blackmagicdesign.com/DesktopVideo/Blackmagic_Desktop_Video_Linux_10.1.1.tar.gz && cd /tmp && tar xvfz /tmp/Blackmagic_Desktop_Video_Linux_10.1.1.tar.gz 
RUN dpkg -i /tmp/DesktopVideo_10.1.1/deb/amd64/desktopvideo_10.1.1a26_amd64.deb && dkms install -v 10.1.1a26 -m blackmagic -k $(apt-cache --no-all-versions show linux-headers-generic | grep Depends | sed -n -e 's/^.*linux-headers-//p') && dkms install -v 10.1.1a26 -m blackmagic-io -k $(apt-cache --no-all-versions show linux-headers-generic | grep Depends | sed -n -e 's/^.*linux-headers-//p') && rm -rf /var/lib/apt/lists/* && apt-get autoclean && apt-get clean && apt-get autoremove



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

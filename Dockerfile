FROM ubuntu:19.04 as builder

RUN apt update && apt install -y git build-essential \
	libxcb1-dev libxcb-keysyms1-dev libpango1.0-dev \
	libxcb-util0-dev libxcb-icccm4-dev libyajl-dev \
	libstartup-notification0-dev libxcb-randr0-dev \
	libev-dev libxcb-cursor-dev libxcb-xinerama0-dev \
	libxcb-xkb-dev libxkbcommon-dev libxkbcommon-x11-dev \
	autoconf libxcb-xrm0 libxcb-xrm-dev automake libxcb-shape0-dev

FROM builder

WORKDIR /opt
ENV APP=i3-gaps_1.0-1

RUN mkdir /opt/output && git clone https://www.github.com/Airblader/i3 i3-gaps && \
	cd i3-gaps && \
	autoreconf --force --install && \
	rm -rf build/ && \
	mkdir -p build && cd build/ && \
	../configure --prefix=/usr --sysconfdir=/etc --disable-sanitizers && \
	make && \
	make build

RUN	cd i3-gaps/build && ls && mkdir -p $APP/DEBIAN \
		 $APP/usr/bin \
		 $APP/usr/share/applications \
		 $APP/usr/share/xsessions \
		 $APP/usr/include/i3 \
		 $APP/etc/i3 &&  \
	cp  i3 \
		i3bar/i3bar \
		i3-config-wizard/i3-config-wizard \
		i3-dump-log/i3-dump-log \
		i3-input/i3-input \
		i3-msg/i3-msg \
		i3-nagbar/i3-nagbar \
		$APP/usr/bin && \
	cp  ../../i3-gaps/i3-dmenu-desktop \
		../../i3-gaps/i3-migrate-config-to-v4 \
		../../i3-gaps/i3-save-tree \
		../../i3-gaps/i3-sensible-editor \
		../../i3-gaps/i3-sensible-pager \
		../../i3-gaps/i3-sensible-terminal \
		$APP/usr/bin && \
	chmod +x $APP/usr/bin/* && \
	cp ../share/applications/i3.desktop $APP/usr/share/applications && \
	cp ../../i3-gaps/share/xsessions/i3.desktop $APP/usr/share/xsessions && \
	cp etc/config.keycodes $APP/etc/i3 && \
	cp ../../i3-gaps/include/i3/ipc.h $APP/usr/include/i3 && \
	chmod 644 $APP/usr/share/applications/i3.desktop \
			  $APP/usr/share/xsessions/i3.desktop \
			  $APP/etc/i3/config.keycodes \
			  $APP/usr/include/i3/ipc.h

WORKDIR /opt/i3-gaps/build
ADD src/meta/control $APP/DEBIAN

RUN dpkg-deb --build $APP

CMD ["cp", "/opt/i3-gaps/build/i3-gaps_1.0-1.deb", "/opt/output"]

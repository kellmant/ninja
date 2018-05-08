FROM alpine:latest
MAINTAINER kellman
USER root
COPY certs /usr/local/share/ca-certificates/
RUN apk -Uuvv add --no-cache curl openssl tini tzdata ca-certificates && \
	addgroup -g 253 fleet && \
	addgroup -g 500 core && \
	addgroup -g 600 units && \
	addgroup -g 700 boss && \
	addgroup -g 800 media && \
	addgroup -g 900 web && \
	addgroup -g 1000 git && \
	adduser -D ctrl -u 500 -g controller -G core -s /bin/bash -h /ctrl && \
	addgroup ctrl fleet && \
	addgroup ctrl units && \
	addgroup ctrl boss && \
	addgroup ctrl media && \
	addgroup ctrl web && \
	adduser -S -u 602 -G units -H irc && \
	adduser -S -u 800 -G media -H plex && \
	adduser -S -u 802 -G media -H shows && \
	adduser -S -u 803 -G media -H movies && \
	adduser -S -u 804 -G media -H music && \
	adduser -S -u 805 -G media -H sab && \
	adduser -S -u 806 -G media -H torrent && \
	adduser -S -u 901 -G web -H hexo && \
	adduser -S -u 902 -G web -H blog && \
	adduser -S -u 903 -G web -H wordpress && \
	adduser -S -u 904 -G web -H node && \
	adduser -S -u 1000 -G git -H git && \
   	mkdir -p /ctrl && chown -R ctrl.core /ctrl && \
   	mkdir -p /socket && chown -R ctrl.core /socket && \
   	mkdir -p /web && chown -R ctrl.core /web && \
   	mkdir -p /node && chown -R ctrl.core /node && \
   	mkdir -p /ca && chown -R ctrl.core /ca && \
	update-ca-certificates && \
	mkdir -p /tmp/build && cd /tmp/build && \
	curl -L https://github.com/coreos/etcd/releases/download/v3.1.8/etcd-v3.1.8-linux-amd64.tar.gz -o etcd-v3.1.8-linux-amd64.tar.gz && \
	tar xzvf etcd-v3.1.8-linux-amd64.tar.gz && cd etcd-v3.1.8-linux-amd64 && \
	cp ./etcdctl /usr/bin/ && cd /tmp/build && \
	curl -L https://github.com/coreos/fleet/releases/download/v0.11.8/fleet-v0.11.8-linux-amd64.tar.gz -o fleet.tar.gz && \
	tar xzvf fleet.tar.gz && cd fleet-v0.11.8-linux-amd64 && \
	cp ./fleetctl /usr/bin/ && \
    cd / && rm -rf /tmp/build
ENV PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
COPY ttyd /root/ttyd
RUN apk add --update --no-cache \
    autoconf automake bash bsd-compat-headers yarn \
    build-base ca-certificates cmake curl file g++ git libtool vim \
 && curl -sLo- https://s3.amazonaws.com/json-c_releases/releases/json-c-0.12.1.tar.gz | tar xz \
 && cd json-c-0.12.1 && env CFLAGS=-fPIC ./configure && make install && cd .. \
 && curl -sLo- https://zlib.net/zlib-1.2.11.tar.gz | tar xz \
 && cd zlib-1.2.11 && ./configure && make install && cd .. \
 && curl -sLo- https://www.openssl.org/source/openssl-1.0.2l.tar.gz | tar xz \
 && cd openssl-1.0.2l && ./config -fPIC --prefix=/usr/local --openssldir=/usr/local/openssl && make install && cd .. \
 && curl -sLo- https://github.com/warmcat/libwebsockets/archive/v2.2.1.tar.gz | tar xz \
 && cd libwebsockets-2.2.1 && cmake -DLWS_WITHOUT_TESTAPPS=ON -DLWS_STATIC_PIC=ON -DLWS_UNIX_SOCK=ON && make install && cd .. \
 && sed -i 's/libz.so/libz.a/g' /usr/local/lib/cmake/libwebsockets/LibwebsocketsTargets-release.cmake \
 && sed -i 's/ websockets_shared//' /usr/local/lib/cmake/libwebsockets/LibwebsocketsConfig.cmake \
 && rm -rf json-c-0.12.1 zlib-1.2.11 openssl-1.0.2l libwebsockets-2.2.1 \
 && cd /root/ttyd/html && yarn && yarn run build && cd .. \
 && sed -i '5s;^;\nSET(CMAKE_FIND_LIBRARY_SUFFIXES ".a")\nSET(CMAKE_EXE_LINKER_FLAGS "-static")\n;' CMakeLists.txt \
 && cmake . && make install && cd .. && rm -rf ttyd \
 && git clone https://github.com/powerline/fonts.git \
 && cd fonts && ./install.sh && cd .. && rm -rf fonts \
 && apk del --purge build-base cmake g++ autoconf automake bsd-compat-headers yarn libtool \
 && rm -rf /tmp/* \
 && rm -rf /var/cache/apk/*
ENV TERM=screen-256color
RUN	mkdir -p /node && chown -R ctrl /node && \
    echo -n "Gateway In The Sky Project " > /etc/motd && \
	echo -n "Securing Labs Ninja Dev Shell [Alpine:latest] " >> /etc/motd && \
	echo "overlaynetwork[TRUSTED] " >> /etc/motd && \
	echo " " >> /etc/motd && \
	echo "NodeJS Tools " >> /etc/motd && \
	echo "Learn Node: https://www.npmjs.com/package/learnyounode " >> /etc/motd && \
	echo "renv: https://www.npmjs.com/package/renv " >> /etc/motd && \
	echo "Hexo Blog: https://www.npmjs.com/package/hexo " >> /etc/motd && \
	echo "PUML Diagrams: https://www.npmjs.com/package/node-plantuml " >> /etc/motd && \
	echo "Explorer CLI: https://www.npmjs.com/package/explorer-cli " >> /etc/motd && \
	echo "newman: https://www.npmjs.com/package/autotest-engine " >> /etc/motd && \
	echo " " >> /etc/motd && \
	apk -Uuvv add --no-cache emacs git \
	python py-pip zip util-linux coreutils findutils grep \
	jq tree groff less build-base linux-headers fontconfig openssl-dev \ 
	bc vim dialog ncurses ncurses-libs ncurses-terminfo libevent tmux openssh binutils xdg-utils \
 	rsync musl musl-dev go nodejs-npm nodejs-dev nodejs graphviz ttf-droid ttf-droid-nonlatin openjdk8-jre && \
	pip install --upgrade pip && \
    pip install powerline-status && \
	pip install awscli && \
    pip install aws-shell && \
    pip install s3cmd && \
    pip install TermRecord && \
    pip install Jinja2 && \
	rm -rf /root/.cache && \
	rm -rf /tmp/* && \
	rm -rf /var/cache/apk/*
USER ctrl
ENV NPM_CONFIG_PREFIX=/node
RUN npm config set package-lock false && \
   	npm install -g yoda-said 
USER root
#COPY vim_runtime /usr/share/vim_runtime
COPY DEV /DEV
COPY bin/ /usr/local/bin/
RUN mkdir -p /web && chown -R ctrl /web && mkdir -p /tls && chown -R ctrl /tls
EXPOSE 3000 4000 5000
VOLUME ["/socket"]
USER ctrl
ENV PATH=~/bin:/node/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin ETCDCTL_STRICT_HOST_KEY_CHECKING=false FLEETCTL_STRICT_HOST_KEY_CHECKING=false TERM=screen-256color
WORKDIR /ctrl
ENTRYPOINT ["/sbin/tini", "-g", "--"]
CMD ["/DEV"] 

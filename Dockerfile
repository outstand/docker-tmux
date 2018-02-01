# Alpine 3.5 doesn't seem to correctly allocate a tty:
# https://github.com/gliderlabs/docker-alpine/issues/266
FROM alpine:3.7
MAINTAINER Ryan Schlesinger <ryan@outstand.com>

ENV DUMB_INIT_VERSION 1.2.0
ENV TMUX_VERSION 2.6

RUN addgroup -S mux && \
    adduser -S -G mux mux && \
    addgroup -g 1101 docker && \
    addgroup mux docker

RUN apk add --no-cache ca-certificates wget gnupg openssl git bash && \
    mkdir -p /tmp/build && \
    cd /tmp/build && \
    wget https://github.com/Yelp/dumb-init/releases/download/v${DUMB_INIT_VERSION}/dumb-init_${DUMB_INIT_VERSION}_amd64 && \
    wget https://github.com/Yelp/dumb-init/releases/download/v${DUMB_INIT_VERSION}/sha256sums && \
    grep dumb-init_${DUMB_INIT_VERSION}_amd64$ sha256sums | sha256sum -c && \
    chmod +x dumb-init_${DUMB_INIT_VERSION}_amd64 && \
    cp dumb-init_${DUMB_INIT_VERSION}_amd64 /bin/dumb-init && \
    ln -s /bin/dumb-init /usr/bin/dumb-init && \
    cd /tmp && \
    rm -rf /tmp/build && \
    apk del gnupg && \
    rm -rf /root/.gnupg

RUN apk add --no-cache \
    util-linux \
    libevent \
    ncurses-terminfo && \
  apk --no-cache add --virtual build-dependencies build-base libevent-dev ncurses-dev bsd-compat-headers && \
  mkdir -p /tmp/build && \
  cd /tmp/build && \
  wget https://github.com/tmux/tmux/releases/download/${TMUX_VERSION}/tmux-${TMUX_VERSION}.tar.gz && \
  tar -zxvf tmux-${TMUX_VERSION}.tar.gz && \
  cd tmux-${TMUX_VERSION} && \
  ./configure && make && make install && \
  cd /tmp && \
  rm -rf /tmp/build && \
  apk del build-dependencies && \
  git clone https://github.com/tmux-plugins/tpm /root/.tmux/plugins/tpm

ENV TMUX_TMPDIR /var/run/tmux
RUN mkdir -p /var/run/tmux && chown -R mux:mux /var/run/tmux
VOLUME /var/run/tmux

ENV LANG en_US.UTF-8
ENV LANGUAGE en_US:en
ENV LC_ALL en_US.UTF-8

COPY tmux.conf /etc/tmux.conf
RUN /root/.tmux/plugins/tpm/bin/install_plugins
COPY docker-entrypoint.sh /docker-entrypoint.sh
ENTRYPOINT ["/docker-entrypoint.sh"]
CMD ["server"]

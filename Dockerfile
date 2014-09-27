# Mostly cloned from https://registry.hub.docker.com/u/dockerfile/redis/dockerfile/
# FROM phusion/baseimage:latest  pondering... 

FROM dockerfile/ubuntu
MAINTAINER Steve Wyckoff "s.wyckoff1@gmail.com"

# add our user and group first to make sure their IDs get assigned consistently, regardless of whatever dependencies get added
# RUN groupadd -r redis && useradd -r -g redis redis # Issue writing to volume from non root user.

ENV REDIS_VERSION 2.8.17
ENV REDIS_DOWNLOAD_URL http://download.redis.io/releases/redis-$REDIS_VERSION.tar.gz
ENV REDIS_DOWNLOAD_SHA1 913479f9d2a283bfaadd1444e17e7bab560e5d1e
ENV REDIS_TAR redis-$REDIS_VERSION.tar.gz
ENV REDIS_DIR_EXTRACTED redis-$REDIS_VERSION

# Install Redis.
RUN \
      cd /tmp && \
      curl -sSL "$REDIS_DOWNLOAD_URL" -o "$REDIS_TAR" && \
      echo "$REDIS_DOWNLOAD_SHA1 $REDIS_TAR" | sha1sum -c - && \
      tar xvzf "$REDIS_TAR" && \
      cd "$REDIS_DIR_EXTRACTED" && \
      make && \
      make install && \
      cp -f src/redis-sentinel /usr/local/bin && \
      mkdir -p /etc/redis && \
      cp -f *.conf /etc/redis && \
      rm -rf /tmp/redis-stable* && \
      sed -i 's/^\(bind .*\)$/# \1/' /etc/redis/redis.conf && \
      sed -i 's/^\(daemonize .*\)$/# \1/' /etc/redis/redis.conf && \
      sed -i 's/^\(dir .*\)$/# \1\ndir \/data/' /etc/redis/redis.conf && \
      sed -i 's/^\(logfile .*\)$/# \1/' /etc/redis/redis.conf

# RUN sysctl vm.overcommit_memory=1 # Needs privileged mode.

# Volumes, working dir, cmd...
      RUN mkdir /data # && chown redis:redis /data
      VOLUME /data
      WORKDIR /data

# USER redis
      EXPOSE 6379
      CMD ["redis-server", "/etc/redis/redis.conf"]

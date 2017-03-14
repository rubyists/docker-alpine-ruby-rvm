FROM alpine:latest

# update package lists
RUN apk update
# packages to build rubies with RVM in alpine
RUN apk add alpine-sdk libtool autoconf automake bison readline-dev \
  zlib-dev yaml-dev gdbm-dev ncurses-dev linux-headers openssl-dev \
  libffi-dev procps libxml2-dev libxslt-dev gnupg

# install rvm
RUN gpg --keyserver hkp://keys.gnupg.net --recv-keys 409B6B1796C275462A1703113804BB82D39DC0E3 && \
    \curl -sSL https://get.rvm.io | bash -s stable
RUN /bin/bash -l -c 'source /etc/profile.d/rvm.sh'

# make bundler a default gem
RUN echo bundler >> /usr/local/rvm/gemsets/global.gems

# setup some default flags from rvm (auto install, auto gemset create, quiet curl)
RUN echo "rvm_install_on_use_flag=1\nrvm_gemset_create_on_use_flag=1\nrvm_quiet_curl_flag=1" > ~/.rvmrc

# preinstall some ruby versions
ENV PREINSTALLED_RUBIES "2.4.0 2.3.2 2.3.1 2.3.0 2.2.2 2.2.1 2.1.5 2.1.4 2.1.2 2.1.1"
RUN /bin/bash -l -c 'for version in $PREINSTALLED_RUBIES; do echo "Now installing Ruby $version"; rvm install $version; rvm cleanup all; done'

# source rvm in every shell
RUN echo '. /etc/profile.d/rvm.sh\n' >~/.profile

# disable strict host key checking (used for deploy)
RUN mkdir ~/.ssh
RUN echo "Host *\n\tStrictHostKeyChecking no\n\n" > ~/.ssh/config

# login shell by default so rvm is sourced automatically and 'rvm use' can be used
ENTRYPOINT /bin/sh -l

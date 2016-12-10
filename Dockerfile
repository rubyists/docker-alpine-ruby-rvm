FROM ubuntu:latest

# packages required for building rubies with rvm
RUN apt-get update -qqy && apt-get install -qqy \
	bzip2 \
	gawk \
	g++ \
	gcc \
	make \
	libreadline6-dev \
	libyaml-dev \
	libsqlite3-dev \
	sqlite3 \
	autoconf \
	libgmp-dev \
	libgdbm-dev \
	libncurses5-dev \
	automake \
	libtool \
	bison \
	pkg-config \
	libffi-dev \
	&& rm -rf /var/lib/apt/lists

# additional packages for development
RUN apt-get update -qqy && apt-get install -qqy \
	git \
	curl \
	nodejs \
	libpq-dev \
	libmysqlclient-dev \
	qt5-default \
	libqt5webkit5-dev \
	imagemagick \
	libmagickwand-dev \
	xvfb \
	&& rm -rf /var/lib/apt/lists

# manually install phantomjs
RUN curl -sL -o - https://bitbucket.org/ariya/phantomjs/downloads/phantomjs-2.1.1-linux-x86_64.tar.bz2 | tar -xjf - -O phantomjs-2.1.1-linux-x86_64/bin/phantomjs > /usr/bin/phantomjs && chmod +x /usr/bin/phantomjs

# install rvm
RUN gpg --keyserver hkp://keys.gnupg.net --recv-keys 409B6B1796C275462A1703113804BB82D39DC0E3 && \
    \curl -sSL https://get.rvm.io | bash -s stable
RUN /bin/bash -l -c 'source /etc/profile.d/rvm.sh'

# make bundler a default gem
RUN echo bundler >> /usr/local/rvm/gemsets/global.gems

# setup some default flags from rvm (auto install, auto gemset create, quiet curl)
RUN echo "rvm_install_on_use_flag=1\nrvm_gemset_create_on_use_flag=1\nrvm_quiet_curl_flag=1" > ~/.rvmrc

# preinstall some ruby versions
ENV PREINSTALLED_RUBIES "2.3.2 2.3.1 2.3.0 2.2.2 2.2.1 2.1.5 2.1.4 2.1.2 2.1.1 2.0.0 1.9.3"
RUN /bin/bash -l -c 'for version in $PREINSTALLED_RUBIES; do echo "Now installing Ruby $version"; rvm install $version; rvm cleanup all; done'

# source rvm in every shell
RUN sed -i '3i . /etc/profile.d/rvm.sh\n' ~/.profile

# disable strict host key checking (used for deploy)
RUN mkdir ~/.ssh
RUN echo -e "Host *\n\tStrictHostKeyChecking no\n\n" > ~/.ssh/config

# interactive shell by default so rvm is sourced automatically
ENTRYPOINT /bin/bash -l

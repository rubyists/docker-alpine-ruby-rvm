FROM ubuntu:latest

RUN apt-get update -qqy && \
    apt-get upgrade -qqy 
RUN apt-get install -y git sudo curl nodejs libpq-dev libmysqlclient-dev qt5-default libqt5webkit5-dev

RUN gpg --keyserver hkp://keys.gnupg.net --recv-keys 409B6B1796C275462A1703113804BB82D39DC0E3 && \
    \curl -sSL https://get.rvm.io | bash -s stable
RUN /bin/bash -l -c 'source /etc/profile.d/rvm.sh'

# make bundler a default gem
RUN echo bundler > /usr/local/rvm/gemsets/global.gems

# setup default ruby version
ENV RUBY_VER 2.3.1
RUN /bin/bash -l -c 'rvm install $RUBY_VER'
RUN /bin/bash -l -c 'rvm use $RUBY_VER --default'

# preinstall some ruby versions
# ENV PREINSTALLED_RUBIES "2.3.1 2.3.0 2.2.2 2.2.1 2.1.2"
# RUN /bin/bash -l -c 'for version in $PREINSTALLED_RUBIES; do echo "Now installing Ruby $version"; rvm install $version; done'
 
# create ruby_setup script
RUN echo "#!/bin/bash \nsource /etc/profile.d/rvm.sh \nrvm install \$(cat .ruby-version) --quiet-curl \nrvm use --create \$(cat .ruby-version)@\$(cat .ruby-gemset)" > ~/ruby_setup.sh
RUN chmod +x ~/ruby_setup.sh

RUN sed -i '5i source /etc/profile.d/rvm.sh\n' ~/.bashrc
RUN sed -i '3i . /etc/profile.d/rvm.sh\n' ~/.profile
#ENV PATH "$PATH:/usr/local/rvm/bin"

#ENTRYPOINT /bin/bash -l
#SHELL ["/bin/bash", "-l", "-c"]a
#RUN ln -sf /bin/bash /bin/sh
#ENTRYPOINT ["/bin/bash", "-l", "-c"]
#RUN /bin/bash -l -c 'alias rubysetup="source /etc/profile.d/rvm.sh && rvm install \$(cat .ruby-version)"'
#RUN echo 'alias rubysetup="source /etc/profile.d/rvm.sh && rvm install \$(cat .ruby-version)"' >> ~/.bashrc
CMD ["/bin/bash", "-l", "-c"]

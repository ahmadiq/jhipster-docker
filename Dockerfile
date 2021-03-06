# DOCKER-VERSION 0.7.1
FROM      ubuntu:14.04
MAINTAINER Julien Dubois <julien.dubois@gmail.com>

# make sure the package repository is up to date
RUN echo "deb http://archive.ubuntu.com/ubuntu trusty main universe" > /etc/apt/sources.list
RUN apt-get -y update

# install python-software-properties (so you can do add-apt-repository)
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y -q python-software-properties software-properties-common

# install SSH server so we can connect multiple times to the container
RUN apt-get -y install openssh-server && mkdir /var/run/sshd

# install oracle java from PPA
RUN add-apt-repository ppa:webupd8team/java -y
RUN apt-get update
RUN echo oracle-java8-installer shared/accepted-oracle-license-v1-1 select true | /usr/bin/debconf-set-selections
RUN apt-get -y install oracle-java8-installer && apt-get clean

# Set oracle java as the default java
RUN update-java-alternatives -s java-8-oracle
RUN echo "export JAVA_HOME=/usr/lib/jvm/java-8-oracle" >> ~/.bashrc

# install utilities
RUN apt-get -y install vim nano git sudo zip bzip2 fontconfig curl

# install maven
RUN apt-get -y install maven

# install node.js from PPA
RUN curl --silent --location https://deb.nodesource.com/setup_0.12 | sudo bash -
RUN apt-get install --yes nodejs

# upgrade to the latest version of npm
RUN npm install -g npm@2.13.2

# install compass, sass
#RUN apt-get -y install ruby
#RUN gem install compass
#RUN gem install sass

# install yeoman
RUN npm install -g yo bower grunt-cli gulp

# install JHipster
RUN npm install -g generator-jhipster@2.18.0

# configure the "jhipster" and "root" users
RUN echo 'root:jhipster' |chpasswd
RUN groupadd jhipster && useradd jhipster -s /bin/bash -m -g jhipster -G jhipster && adduser jhipster sudo
RUN echo 'jhipster:jhipster' |chpasswd

# install the sample app to download all Maven dependencies
RUN cd /home/jhipster && \
    wget https://github.com/jhipster/jhipster-sample-app/archive/v2.18.0.zip && \
    unzip v2.18.0.zip && \
    rm v2.18.0.zip
RUN cd /home/jhipster/jhipster-sample-app-2.18.0 && npm install
RUN cd /home && chown -R jhipster:jhipster /home/jhipster
RUN cd /home/jhipster/jhipster-sample-app-2.18.0 && sudo -u jhipster mvn dependency:go-offline

# expose the working directory, the Tomcat port, the Grunt server port, the SSHD port, and run SSHD
VOLUME ["/jhipster"]
EXPOSE 8080
EXPOSE 9000
EXPOSE 22
CMD    /usr/sbin/sshd -D

#
# open-callisto-pool Dockerfile
#
# https://github.com/
#

# Pull base image.
FROM debian:latest

MAINTAINER hihouhou < hihouhou@hihouhou.com >

ENV GOROOT /usr/local/go
ENV GOPATH /opt/open-callisto-pool
ENV PATH $GOPATH/bin:$GOROOT/bin:$PATH
ENV GO_CALLISTO_VERSION 1.1.0

# Update & install packages for open-callisto-pool dep
RUN apt-get update && \
    apt-get install -y wget git make build-essential curl redis-server nginx unzip 

#Add yarn repository
RUN curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add - && \
    curl -sL https://deb.nodesource.com/setup_8.x | bash - && \
    echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list

# Update & install packages
RUN apt-get update && \
    apt-get install -y yarn nodejs

# Get go
RUN wget https://storage.googleapis.com/golang/go1.10.linux-amd64.tar.gz && \
    tar -xvf go1.10.linux-amd64.tar.gz && \
    mv go /usr/local

# Get open-callisto-pool from github
RUN mkdir /opt/open-callisto-pool && \
    cd /opt/ && \
    git clone https://github.com/EthereumCommonwealth/open-callisto-pool.git

COPY environment.js /opt/open-callisto-pool/www/config/environment.js 
RUN cd /opt/open-callisto-pool/www && \
    npm install -g ember-cli@2.9.1 && \
    npm install -g bower && \
    chown -R $USER:$GROUP ~/.npm && \
    chown -R $USER:$GROUP ~/.config && \
    npm install && \
    bower install  --allow-root && \
    ./build.sh

COPY config.json /opt/open-callisto-pool/config.json

WORKDIR /opt/open-callisto-pool
RUN  make all
COPY default /etc/nginx/sites-enabled/default 


EXPOSE 8082 8081 8888

CMD ["nginx", "-g", "daemon off;"]

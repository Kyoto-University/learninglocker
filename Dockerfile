FROM --platform=linux/amd64 ubuntu:22.04

ENV NODE_VERSION 8.17.0
ENV OS linux
ENV ARCH x64

RUN apt-get update \
    && apt-get install -y \
    procps \
    curl \
    git \
    build-essential \
    xvfb \
    apt-transport-https \
    unzip \
    gettext-base \
    socat \
    gnupg \
    xz-utils \
    wget \
    netcat-traditional

RUN wget -qO- https://www.mongodb.org/static/pgp/server-7.0.asc | tee /etc/apt/trusted.gpg.d/server-7.0.asc
RUN echo "deb [ arch=amd64,arm64 ] https://repo.mongodb.org/apt/ubuntu jammy/mongodb-org/7.0 multiverse" | tee /etc/apt/sources.list.d/mongodb-org-7.0.list

RUN apt-get update \
    && apt-get install -y mongodb-mongosh

# node.jsのインストール
RUN curl -fsSLO --compressed "https://nodejs.org/dist/v$NODE_VERSION/node-v$NODE_VERSION-${OS}-${ARCH}.tar.xz" \
    && tar -xJf "node-v$NODE_VERSION-${OS}-${ARCH}.tar.xz" -C /usr/local --strip-components=1 --no-same-owner \
    && rm "node-v$NODE_VERSION-${OS}-${ARCH}.tar.xz" \
    && ln -s /usr/local/bin/node /usr/local/bin/nodejs

RUN npm install -g pm2@4.3.1 yarn@1.21.1

WORKDIR /opt/learninglocker

COPY ./yarn.lock ./yarn.lock
COPY ./tests.babel ./tests.babel
COPY ./package.json ./package.json
COPY ./server.babel ./server.babel
COPY ./jsconfig.json ./jsconfig.json
COPY ./postcss.config.js ./postcss.config.js
COPY ./nginx.conf.example ./nginx.conf.example
COPY ./clean-build-cache.sh ./clean-build-cache.sh
COPY ./ui ./ui
COPY ./api ./api
COPY ./cli ./cli
COPY ./lib ./lib
COPY ./pm2 ./pm2
COPY ./logs ./logs
COPY ./logos ./logos
COPY ./worker ./worker
COPY ./storage ./storage
COPY ./.nvmrc ./.nvmrc
COPY ./.yarnrc ./.yarnrc
COPY ./.babelrc ./.babelrc
COPY ./template.env /tmp/template.env
COPY --chmod=755 ./docker-entrypoint.sh /docker-entrypoint.sh

RUN yarn install --ignore-engines && \
    yarn build-all

ENV NODE_ENV=production
ENV SITE_URL=http://127.0.0.1
ENV UI_PORT=3000
ENV API_PORT=8080
ENV MONGODB_PATH=mongodb://localhost:27017/learninglocker_v2
ENV REDIS_URL=redis://127.0.0.1:6379/0
ENV REDIS_PREFIX=LEARNINGLOCKER
ENV LOG_MIN_LEVEL=info
ENV LOG_DIR=logs
ENV COLOR_LOGS=true
ENV GOOGLE_ENABLED=false
ENV QUEUE_PROVIDER=REDIS
ENV QUEUE_NAMESPACE=DEV
ENV FS_REPO=local


EXPOSE 3000 8080

ENTRYPOINT ["/docker-entrypoint.sh"]
CMD ["start"]

FROM node:alpine

ENV MONGO_DB_USERNAME=root \
    MONGO_DB_PWD=password

WORKDIR /src

COPY app-server/src/package.json .
RUN npm install

COPY app-server/src/ .

CMD ["node", "server.js"]
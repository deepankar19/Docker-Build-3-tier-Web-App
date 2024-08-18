FROM node:alpine

ENV MONGO_DB_USERNAME=root \
    MONGO_DB_PWD=password

WORKDIR /src

COPY ./src/package.json .
RUN npm install

COPY ./src/ .

CMD ["node", "server.js"]
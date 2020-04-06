FROM node:13.12-slim

ENV BUCKET = batch-job-input
ENV KEY = data.csv

WORKDIR /app

COPY package*.json ./

RUN npm install

COPY . /app

CMD ["npm", "start"]
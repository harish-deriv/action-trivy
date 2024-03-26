FROM node:21-alpine as builder
WORKDIR /usr/src

COPY package*.json tsconfig.json ./

RUN npm install
COPY src ./src
RUN npx tsc

FROM alpine:3.7
ENV PORT=8080

WORKDIR /usr/src

COPY --from=builder /usr/src/package.json /usr/src/package-lock.json ./
COPY --from=builder /usr/src/build ./build
COPY --from=builder /usr/src/node_modules ./node_modules

EXPOSE $PORT

CMD ["node", "build/src/main.js"]

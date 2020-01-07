# Stage 1 - the build react app
FROM node:alpine3.10 as build-deps
WORKDIR /usr/src/app
COPY client/package.json client/package-lock.json ./
RUN apk add python make g++
RUN npm i

COPY client/ ./
RUN npm run build

# Stage 2 - the production environment
FROM node:alpine3.10

RUN apk add --no-cache tini
ENV NODE_ENV production
WORKDIR /usr/src/app
RUN chown -R node:node /usr/src/app/
EXPOSE 4654

COPY server/package.json server/package-lock.json ./
RUN npm i --production

COPY --from=build-deps /usr/src/app/build /usr/src/app/public
COPY /server ./

USER node

ENTRYPOINT ["/sbin/tini", "--", "node", "."]

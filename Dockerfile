# Stage 1 - the build react app
FROM sha256:bdc39b9892e1fd8d1b097cdadbb125862787856ebe79888de8cf6a127784422a as build-deps
WORKDIR /usr/src/app
COPY client/package.json client/package-lock.json ./
RUN npm i

COPY client/ ./
RUN npm run build

# Stage 2 - the production environment
FROM sha256:bdc39b9892e1fd8d1b097cdadbb125862787856ebe79888de8cf6a127784422a

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

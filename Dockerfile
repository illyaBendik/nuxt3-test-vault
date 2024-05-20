FROM node:20.11.1 as DEPENDENCIES
WORKDIR /var/www/client
COPY ./package.json ./
RUN yarn install \
  --non-interactive \
  --pure-lockfile

FROM node:20.11.1 as BUILDER
WORKDIR /var/www/client
COPY ./ ./
COPY --from=DEPENDENCIES /var/www/client/node_modules ./node_modules
ENV NODE_ENV=production
ARG app_secret
ENV APP_SECURE=${app_secret}

RUN yarn build

FROM node:20.11.1-alpine as RUNNER
WORKDIR /var/www/client

COPY ./package.json ./
COPY --from=BUILDER /var/www/client/node_modules ./node_modules/
COPY --from=BUILDER /var/www/client/.output ./.output/

ENV NODE_ENV=production
ENV NITRO_PORT=3000
ENV NITRO_HOST=0.0.0.0

CMD ["yarn", "preview"]
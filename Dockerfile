FROM node:20.11.1 as DEPENDENCIES
WORKDIR /var/www/client
COPY package.json yarn.lock ./
RUN yarn install --non-interactive --pure-lockfile

FROM DEPENDENCIES as BUILDER
COPY . .
ARG app_secret
ENV APP_SECURE=${app_secret}
RUN yarn build

FROM node:20.11.1-alpine as RUNNER
WORKDIR /var/www/client
COPY --from=DEPENDENCIES /var/www/client/node_modules ./node_modules/
COPY --from=BUILDER /var/www/client/.output ./.output/
COPY package.json yarn.lock ./
ENV NODE_ENV=production
ENV NITRO_PORT=3000
ENV NITRO_HOST=0.0.0.0

CMD ["yarn", "preview"]
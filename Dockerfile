FROM node:18-alpine AS builder
WORKDIR /app
COPY app/package.json /app/yarn.lock ./
RUN yarn install --frozen-lockfile
COPY app/ ./
RUN yarn build 


FROM nginx:alpine
RUN rm -rf /usr/share/nginx/html/*
COPY nginx.conf /etc/nginx/conf.d/default.conf
COPY --from=builder /app/build /usr/share/nginx/html
EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
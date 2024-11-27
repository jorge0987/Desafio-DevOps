# Etapa de build
FROM node:20-alpine AS builder
ENV NODE_ENV=production
USER node
WORKDIR /home/node
COPY package.json ./
RUN npm install
COPY . /home/node/


# Etapa de produção
FROM node:20-alpine
RUN apk add --no-cache curl
USER node
WORKDIR /home/node
ENV TZ='America/Sao_Paulo'
COPY --from=builder /home/node /home/node/
CMD ["npm", "start"]

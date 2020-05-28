FROM node:12.16.3
RUN npm install -g serve

WORKDIR /build
COPY build .
CMD ["serve", "-p", "5000", "-s", "."]

EXPOSE 5000



FROM golang:1.12.1-alpine3.9 as lemma
RUN apk upgrade && \
    apk update

RUN apk add --no-cache --update build-base \
    openssl openssl-dev bash perl-utils \
    util-linux-dev libwebsockets-dev \
     coreutils git 

RUN mkdir /go/src/lemma-chain
WORKDIR /go/src/lemma-chain

COPY . .

RUN go get -d -v ./...
RUN go install -v ./...
RUN go get -v github.com/dgraph-io/dgraph/dgraph

EXPOSE 5080 6080 8080 9080

CMD ["lemma-chain"]

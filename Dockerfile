

FROM golang:1.12.1-alpine3.9 as lemma
RUN apk upgrade && \
    apk update

RUN apk add --no-cache git 

RUN mkdir /go/src/lemma-chain
WORKDIR /go/src/lemma-chain

COPY . .

RUN go get -d -v ./...
RUN go install -v ./...

FROM dgraph/dgraph:latest as dgraph
RUN apt-get -y update && apt-get -y install golang

COPY --from=lemma /go /go
WORKDIR /go/src/lemma-chain

CMD ["lemma-chain"]

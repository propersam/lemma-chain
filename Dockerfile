
# STEP 1: build dgraph and lemma-chain
FROM golang:1.12.1-alpine3.9 AS build

RUN apk update && apk add --no-cache git

## set environment variable that's available
## only during Image build
ARG DGRAPH_BRANCH=master

### Build Dgraph binary ###

RUN go get -d -v github.com/dgraph-io/dgraph/dgraph
RUN cd $GOPATH/src/github.com/dgraph-io/dgraph && git checkout ${DGRAPH_BRANCH}
RUN CGO_ENABLED=0 go build -v -o /dgraph github.com/dgraph-io/dgraph/dgraph

### Build Lemma-chain binary ###
## load lemma-chain src
RUN mkdir /go/src/lemma-chain
WORKDIR /go/src/lemma-chain
COPY . .

## get all dependencies and build lemma-chain
RUN go get -d -v ./...
RUN CGO_ENABLED=0 go build -v -o /lemma-chain .

# STEP 2: build alpine image
FROM alpine:3.9
RUN apk update && apk add --no-cache \
ca-certificates

COPY --from=build /dgraph /usr/local/bin/dgraph
COPY --from=build /lemma-chain /usr/local/bin/lemma-chain

RUN mkdir /dgraph
WORKDIR /dgraph

EXPOSE 8080 
EXPOSE 9080

CMD ["lemma-chain"]

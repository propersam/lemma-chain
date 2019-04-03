
FROM golang:1.12.1 as build

RUN mkdir /go/src/lemma-chain
WORKDIR /go/src/lemma-chain

COPY . .

# get all dependencies and build lemma-chain
RUN go get -d -v ./...
RUN go build -o lemma-chain .

# Get and install dgraph
RUN go get -v github.com/dgraph-io/dgraph/dgraph


FROM golang:1.12.1-alpine3.9

RUN apk update && apk upgrade


COPY --from=build /go/src/lemma-chain/lemma-chain /usr/local/bin
COPY --from=build /go/bin/ /usr/local/bin

RUN mkdir /dgraph
WORKDIR /dgraph

CMD ["lemma-chain"]

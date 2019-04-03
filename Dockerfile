
FROM golang:1.12.1 as build

RUN mkdir /go/src/lemma-chain
WORKDIR /go/src/lemma-chain

COPY . .

# build lemma-chain

RUN CGO_ENABLED=0 GOOS=linux go build -a -o lemma-chain .

# Get and install dgraph
RUN go get -v github.com/dgraph-io/dgraph/dgraph

# get and install goofys
RUN go get -v github.com/kahing/goofys

FROM golang:1.12.1-alpine3.9

RUN apk update && apk upgrade
RUN apk add --no-cache aws-cli

COPY --from=build /go/src/lemma-chain/lemma-chain /usr/local/bin
COPY --from=build /go/bin/ /usr/local/bin

RUN mkdir /dgraph
WORKDIR /dgraph

CMD ["lemma-chain"]


FROM golang:1.12.1-alpine3.9

RUN apk update && apk add --no-cache \
	ca-certificates git

RUN mkdir /go/src/lemma-chain
WORKDIR /go/src/lemma-chain

COPY . .

# get all dependencies and build lemma-chain
RUN go get -d -v ./...
RUN go install -v ./...

CMD ["lemma-chain"]

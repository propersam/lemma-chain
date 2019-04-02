FROM golang:1.12.1-alpine3.9 As lemma

RUN apk upgrade && \
    apk update && \
    apk add git
    
RUN mkdir -p /go/src/lemma-chain
WORKDIR /go/src/lemma-chain
COPY . .

RUN go get -d -v ./...
RUN go install -v ./...

CMD [ "lemma-chain" ] # /go/bin is already available in path
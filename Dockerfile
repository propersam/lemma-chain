FROM golang:1.12.1-alpine3.9 As lemma

RUN apk upgrade && \
    apk update && \
    apk add git

RUN mkdir -p /go/src/lemma-chain
WORKDIR /go/src/lemma-chain
COPY . .

RUN go get -d -v ./...
RUN go install -v ./...

FROM golang:1.12.1-alpine3.9 As dgraph

RUN apk upgrade && \
    apk update && \
    apk add git && \
    apk add bash

# take all lemma-chain files
# to new image stage
COPY --from=lemma /go /go

# Now scripts for dgraph begins here

# create directory and change GOPATH
# Don't use standard GOPATH directory 
# DO NOT change the /tmp/build directory, because Dockerfile also picks up binaries from there.
# Build for TAG Latest

RUN mkdir /tmp/go && mkdir /tmp/build
ENV GOPATH="/tmp/go" TAG="latest" TMP="/tmp/build"
# Necessary to pick up Gobin binaries like protoc-gen-gofast
ENV PATH="$GOPATH/bin:$PATH" 
RUN echo "Buiilding Dgraph for tag: $TAG" && \
    # Stop on first failure.
    set -e && \
    set -o xtrace

RUN echo "checkpoint reached successfully"

 



CMD [ "lemma-chain" ] # /go/bin is already available in path
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
    apk update

RUN apk add --update --no-cache build-base \
    openssl openssl-dev \
    util-linux-dev libwebsockets-dev \
    # c-ares-dev libxslt \
    coreutils perl-utils git bash


# take all lemma-chain files
# to Go Directory on new image stage
COPY --from=lemma /go /go
WORKDIR /go/src/lemma-chain

# Now scripts for dgraph begins here

# create directory and change GOPATH
# Don't use standard GOPATH directory 
# DO NOT change the /tmp/build directory, because Dockerfile also picks up binaries from there.
# Build for TAG Latest

RUN mkdir /tmp/go && mkdir /tmp/build
ENV GOPATH="/tmp/go" TAG="latest" TMP="/tmp/build"
# Necessary to pick up Gobin binaries like protoc-gen-gofast
ENV PATH="$GOPATH/bin:$PATH" GOVERSION="1.12.1" 
RUN echo "Building Dgraph for tag: $TAG" && \
    # Stop on first failure.
    set -e && \
    set -o xtrace
 
# check for existence of strip tool & shasum perl script
RUN type strip && \
    type shasum

ENV ratel_release="github.com/dgraph-io/ratel/server.ratelVersion" \
    release="github.com/dgraph-io/dgraph/x.dgraphVersion" \
    branch="github.com/dgraph-io/dgraph/x.gitBranch" \
    commitSHA1="github.com/dgraph-io/dgraph/x.lastCommitSHA" \
    commitTime="github.com/dgraph-io/dgraph/x.lastCommitTime"

RUN echo "Using $(go version)" && \
    go get -u -v github.com/jteeuwen/go-bindata/... && \
    go get -d -u -v golang.org/x/net/context && \
    go get -d -v google.golang.org/grpc && \
    go get -u -v github.com/prometheus/client_golang/prometheus && \
    go get -u -v github.com/dgraph-io/dgo && \
    # go get github.com/stretchr/testify/require && \
    go get -u -v github.com/dgraph-io/badger && \
    go get -u -v github.com/golang/protobuf/protoc-gen-go && \
    go get -u -v github.com/gogo/protobuf/protoc-gen-gofast && \
    go get -u -v github.com/karalabe/xgo

RUN echo "Checkpoint 2 Reached successfully."

# The following lines builds the linux binary file
# And prepare it to be transferred to the final stage of 
# lemma-chain and DGraph build


 RUN chmod +x "./docker/build-dgraph.sh" && \
    source ./docker/build-dgraph.sh


CMD [ "lemma-chain" ] # /go/bin is already available in path
#!/bin/bash

# install and setup nvm (node version manager)
apk add -U curl bash ca-certificates openssl ncurses coreutils make gcc g++ libgcc linux-headers grep util-linux binutils findutils
curl -o- https://raw.githubusercontent.com/creationix/nvm/v0.34.0/install.sh | /bin/bash
source ~/.bashrc

pushd $GOPATH/src/google.golang.org/grpc
  git checkout v1.13.0
popd

basedir=$GOPATH/src/github.com/dgraph-io
# Clone Dgraph repo.
pushd $basedir
  git clone https://github.com/dgraph-io/dgraph.git
popd

pushd $basedir/dgraph
  git pull
  git checkout $TAG
  # HEAD here points to whatever is checked out.
  lastCommitSHA1=$(git rev-parse --short HEAD)
  gitBranch=$(git rev-parse --abbrev-ref HEAD)
  lastCommitTime=$(git log -1 --format=%ci)
  release_version=$TAG
popd

# Regenerate protos. Should not be different from what's checked in.
pushd $basedir/dgraph/protos
  make regenerate
  if [[ "$(git status --porcelain)" ]]; then
      echo >&2 "Generated protos different in release."
      exit 1
  fi
popd

# Clone ratel repo.
pushd $basedir
  git clone https://github.com/dgraph-io/ratel.git
popd

pushd $basedir/ratel
  git pull
  source ~/.nvm/nvm.sh
  nvm install --lts
  ./scripts/build.prod.sh
popd

# Build Linux.
pushd $basedir/dgraph/dgraph
	xgo -go=$GOVERSION --targets=linux/amd64 -ldflags \
    "-X $release=$release_version -X $branch=$gitBranch -X $commitSHA1=$lastCommitSHA1 -X '$commitTime=$lastCommitTime'" .
  strip -x dgraph-linux-amd64
  mkdir $TMP/linux
  mv dgraph-linux-amd64 $TMP/linux/dgraph
popd

pushd $basedir/ratel
	xgo -go=$GOVERSION --targets=linux/amd64 -ldflags "-X $ratel_release=$release_version" .
  strip -x ratel-linux-amd64
	mv ratel-linux-amd64 $TMP/linux/dgraph-ratel
popd

createSum () {
  os=$1
  echo "Creating checksum for $os"
  pushd $TMP/$os
    csum=$(shasum -a 256 dgraph | awk '{print $1}')
    echo $csum /usr/local/bin/dgraph >> ../dgraph-checksum-$os-amd64.sha256
    csum=$(shasum -a 256 dgraph-ratel | awk '{print $1}')
    echo $csum /usr/local/bin/dgraph-ratel >> ../dgraph-checksum-$os-amd64.sha256
  popd
}

createSum linux

# Create the tars and delete the binaries.
createTar () {
  os=$1
  echo "Creating tar for $os"
  pushd $TMP/$os
    tar -zcvf ../dgraph-$os-amd64.tar.gz *
  popd
  rm -Rf $TMP/$os
}

createTar linux

exec echo "Release $TAG is ready."
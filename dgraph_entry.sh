#!/bin/bash

# turn on bash's job control
set -m

# start syslog
syslog-ng

sleep 1

echo "mounting with goofys"
# run goofys in foreground and
# mount /graph to s3 bucket
goofys $BUCKET_NAME /dgraph


# Check if the bucket is mounted.
if mountpoint -q /dgraph; then

  echo "SUCCESSFULLY MOUNTED"

  echo "changing into mounted directory"
  # change into new mounted directory
  cd /dgraph

  echo "starting dgraph zero server"
  # Start the main dgraph server (zero) and put it in the background
  dgraph zero &

  # wait 10s
  sleep 10s
  echo "starting dgraph alpha"
  # Start the helper process
  dgraph alpha --lru_mb 2048 --zero localhost:5080 &

  #wait 20s
  sleep 25
  # now we bring the primary process back into the foreground
  # and leave it there
  fg %1

  echo "starting lemma-chain..."
  # now run lemma-chain
  lemma-chain

else
  echo "[ERROR:] UNABLE TO MOUNT BUCKET. Try Again..."
fi

exec $@




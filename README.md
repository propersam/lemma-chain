
![Lemma-Chain](https://github.com/thehonestscoop/lemma-chain/raw/master/logo.png)

# Lemma-Chain




[Documentation](https://thehonestscoop.com/docs/lemma-chain)



## Features

* Create Account using email address
* Create unlimited references
* Link references to up to 100 other references
* Powerful Search Functionality

## TODO

* Password Recovery
* Account activation via email validation

## Working Docker Image

```docker build -t thehonestscoop/lemmachain .```

``` docker run -it --entrypoint=/bin/sh -p 1323:1323 --privileged thehonestscoop/lemma-chain ```

``` docker run -e AWS_ACCESS_KEY_ID= AWS_SECRET_ACCESS_KEY= BUCKET_NAME=lemma-chain --privileged -p 1323:1323 thehonestscoop/lemma-chain ```

## License

LGPL License.


## Copyright

© 2019 The Honest Scoop and P.J. Siripala. All rights reserved.

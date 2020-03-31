#!/usr/bin/env bash

# path variables.
VENDORDIR="${PWD%/*}"/vendor
TEMPDIR="temp"

# create temporary directory for files.
mkdir -p $TEMPDIR

# download gemoji and openmoji json files.
curl -L https://raw.githubusercontent.com/hfg-gmuend/openmoji/master/data/openmoji.json --output $TEMPDIR/openmoji.json
curl -L https://raw.githubusercontent.com/github/gemoji/master/db/emoji.json --output $TEMPDIR/gemoji.json

# download latest unicode emoji test from gemoji.
curl -L https://raw.githubusercontent.com/github/gemoji/master/vendor/unicode-emoji-test.txt --output "$VENDORDIR"/unicode-emoji-test.txt

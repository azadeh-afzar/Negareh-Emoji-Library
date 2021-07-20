#!/usr/bin/env bash

# path variables.
VENDORDIR="${PWD%/*}"/vendor
TEMPDIR="temp"

# download links.
OPENMOJI_JSON_LINK="https://raw.githubusercontent.com/hfg-gmuend/openmoji/master/data/openmoji.json"
GEMOJI_JSON_LINK="https://raw.githubusercontent.com/github/gemoji/master/db/emoji.json"
GEMOJI_TEST_JSON_LINK="https://raw.githubusercontent.com/github/gemoji/master/vendor/unicode-emoji-test.txt"

# setup paths.
OPENMOJI_JSON="${TEMPDIR}/openmoji.json"
GEMOJI_JSON="${TEMPDIR}/gemoji.json"
GEMOJI_TEST_JSON="${VENDORDIR}/unicode-emoji-test.txt"

# create temporary directory for files.
mkdir --parents "${TEMPDIR}"

# download gemoji and openmoji json files.
wget --retry-connrefused --waitretry=1 --read-timeout=20 --timeout=15 \
--tries 0 --no-dns-cache --output-document "${OPENMOJI_JSON}" "${OPENMOJI_JSON_LINK}"

wget --retry-connrefused --waitretry=1 --read-timeout=20 --timeout=15 \
--tries 0 --no-dns-cache --output-document "${GEMOJI_JSON}" "${GEMOJI_JSON_LINK}"

# download latest unicode emoji test from gemoji.
wget --retry-connrefused --waitretry=1 --read-timeout=20 --timeout=15 \
--tries 0 --no-dns-cache --output-document "${GEMOJI_TEST_JSON}" "${GEMOJI_TEST_JSON_LINK}"

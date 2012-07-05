#! /bin/bash

NEWDATE="$2"
PREVDATE="$1"

mkdir "${NEWDATE}" || exit 1

cp "${PREVDATE}/meeting_${PREVDATE}.min" "${NEWDATE}/meeting_${NEWDATE}.min"

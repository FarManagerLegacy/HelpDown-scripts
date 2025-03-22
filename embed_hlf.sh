#!/bin/bash
# Script Name: embed_hlf.sh
# Author: John Doe
# Date: 2025-03-22
# Description: Update embedded hlf in lua script

set -o errexit

SOURCEFILE=$1
HLFFILE=$2
BOM="\xEF\xBB\xBF"
if awk "NR==1 && /^$BOM--\[\[/{exit} {exit 1}" "$SOURCEFILE"; then
  printf $BOM
  echo '--[['
  awk "NR==1{sub(/^$BOM/, \"\")}1" "$HLFFILE"
  echo '@'
  echo '--]]'
  awk '/--\]\]/{f=1;next} f' "$SOURCEFILE"
else
  echo "Source file must begin with specified pattern: {bom}--[[" >&2
  exit 1
fi

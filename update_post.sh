#!/bin/bash
# Script Name: update_post.sh
# Author: John Doe
# Date: 2025-02-04
# Description: Update phpBB 3 forum post, replacing it's content with specified file

# Must be set in environment!
#POST_ID=123456
#FILE="post.md"
#USERNAME="User name"
#PASSWORD="12345678"

set -o errexit
set -o nounset
set -o pipefail

CLEANUP=${CLEANUP:-true}
HOST=${HOST:-https://forum.farmanager.com}
LOGIN_URL="$HOST/ucp.php?mode=login"
POST_URL="$HOST/posting.php?mode=edit&p=$POST_ID"

cleanup() {
  trap - EXIT
  echo "Cleaning up..."
  if [[ -n ${sid:=$(extract_cookie sid)} ]]; then
    curl -b "$cookie_file" "${LOGIN_URL/=login/=logout}&sid=$sid"
  fi
  rm "$cookie_file" 2>/dev/null
}

if [[ "$CLEANUP" == "true" ]]; then
  cookie_file="$(mktemp)"
  trap cleanup EXIT
  trap cleanup SIGINT
else
  cookie_file="cookies.txt"
fi

extract_cookie () {
  sed -n "s/.*phpbb3_sxb2q_$1\t\([^\t]*\).*/\1/p" "$cookie_file" 2>/dev/null
}

extract() {
  value=$(echo $output | sed -nE "s/.*name=\"$1\"[^>]* (value|checked)=\"([^\"]*)\".*/\2/p")
  [[ -n "$value" ]] && echo -n "$1=$value"
}

login() {
  output=$(curl -s "$LOGIN_URL")
  sleep 1
  echo Retreiving cookies...
  curl -s $LOGIN_URL -c "$cookie_file" \
    -d "username=$USERNAME" \
    -d "password=$PASSWORD" \
    -d autologin=on \
    -d $(extract creation_time) \
    -d $(extract form_token) \
    -d $(extract sid) \
    -d login=Login \
    | grep 'class="error"' || true
  if [[ -z $(extract_cookie k) ]]; then
    echo
    echo "*** Cookie file: ***"
    cat "$cookie_file"
    exit 1
  fi
}

if [[ ! -f "$cookie_file" ]]; then
  login
fi

while true; do
  output=$(curl -s $POST_URL -b "$cookie_file" -c "$cookie_file")
  if [[ -z $(extract_cookie k) ]]; then
    login
  else
    break
  fi
done

echo Preparing data...
inputs='
  edit_post_message_checksum edit_post_subject_checksum post creation_time form_token
  disable_markdown topic_first_post_show disable_bbcode disable_smilies disable_magic_url attach_sig
'
args="-d no_edit_log=on"
for input in $inputs; do
  arg="$(extract $input)" || true
  if [[ -n "$arg" ]]; then
    args="$args -d $arg"
  fi
done

echo Posting...
output=$(
  curl $POST_URL -sib "$cookie_file" --data-urlencode "message@$FILE" -d "$(extract subject | sed 's/\"/\\\"/g')" $args
)
status_line=$(echo "$output" | head -n 1)

if [[ "$status_line" == *302* ]]; then
  echo Done.
else
  echo "$output" | grep 'class="error"' || echo "$output"
  echo Oops! Try again.
  trap cleanup EXIT
  exit 1
fi

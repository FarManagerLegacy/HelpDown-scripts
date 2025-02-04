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
  cookie_file=$(mktemp)
  trap cleanup EXIT
  trap cleanup SIGINT
else
  cookie_file="cookies.txt"
fi

extract_cookie () {
  sed -n "s/.*phpbb3_sxb2q_$1\t\([^\t]*\).*/\1/p" "$cookie_file" 2>/dev/null
}

extract() {
  echo $OUTPUT | sed -nE "s/.*name=\"$1\"[^>]* value=\"([^\"]*)\".*/\1/p"
}

login() {
  OUTPUT=$(curl -s "$LOGIN_URL")
  sleep 1
  echo Retreiving cookies...
  curl -s $LOGIN_URL -c "$cookie_file" \
    -d "username=$USERNAME" \
    -d "password=$PASSWORD" \
    -d "autologin=on" \
    -d "creation_time=$(extract creation_time)" \
    -d "form_token=$(extract form_token)" \
    -d "sid=$(extract sid)" \
    -d "login=Login" \
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
  OUTPUT=$(curl -s $POST_URL -b "$cookie_file" -c "$cookie_file")
  if [[ -z $(extract_cookie k) ]]; then
    login
  else
    break
  fi
done
sleep 1
echo Posting...
STATUS_LINE=$(
curl $POST_URL -sib "$cookie_file" \
  -d "subject=$(extract subject)" \
  --data-urlencode "message@$FILE" \
  -d "edit_post_message_checksum=$(extract edit_post_message_checksum)" \
  -d "edit_post_subject_checksum=$(extract edit_post_subject_checksum)" \
  -d "post=Submit" \
  -d "no_edit_log=on" \
  -d "creation_time=$(extract creation_time)" \
  -d "form_token=$(extract form_token)" \
  | head -n 1
)

if [[ "$STATUS_LINE" == *302* ]]; then
  echo Done.
else
  echo Oops! Try again.
  trap cleanup EXIT
  exit 1
fi

#!/bin/sh
# Get latest SMS messages (sent and received)
#
# Parameter:
#   maxSMS - maximum number of SMS to list; defaults to 2
#
# Requires:
#   * curl - transfer a URL
#   * jq - Command-line JSON processor
#
# References:
#   [1] Message Resource
#   https://www.twilio.com/docs/messaging/api/message-resource
#
#   [2] Read a list of messages
#   https://www.twilio.com/docs/messaging/api/message-resource#read-multiple-message-resources
#
cd "$(dirname "$0")"

maxSMS="${1:-2}"

accountSID='' # REQUIRED
authToken='' # REQUIRED
test -f ./auth.sh && . ./auth.sh

if test -z "$accountSID" -o -z "$authToken"
then
  cat <<EOF >&2
accountSID and authToken must be set at the top of this script
or in a file called auth.sh in the same directory as this script.
They can be found in your Twilio dashboard:
https://www.twilio.com/console
EOF
  exit 1
fi

if test -z "$(which curl)" -o -z "$(which jq)"
then
  cat <<EOF >&2
curl and jq are required.
curl: https://curl.haxx.se/
jq: https://stedolan.github.io/jq/
EOF
  exit 2
fi

api="https://api.twilio.com/2010-04-01/Accounts/$accountSID"
auth="$accountSID:$authToken"

echo "Latest SMS Messages..."

curl "$api/Messages.json?PageSize=$maxSMS" \
  -u "$auth" -s |
jq 'try .messages[] | "
Date: \(.date_sent)
From: \(.from)
To: \(.to)
\(.body)"' \
  --raw-output

echo
echo 'Done.'

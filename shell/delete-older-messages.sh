#!/bin/sh
# Delete all messages sent/received before given date (excluded)
# A single run of this script will delete up to 1,000 messages.
#
# Parameter:
#   expirationDate - date in yyyy-mm-dd format, expiration date for
#                    messages to delete; defaults to today's date
#
# Note:
# Media resources attached to messages will be deleted as well, unless they
# are used in other messages which have not been deleted yet (see [2]).
#
# This script is intended to delete older messages completely while preserving
# the messages sent or received today, which will remain in Twilio Console.
# Since messages sent on given date are not deleted, you will need to specify
# a date in the future to delete all messages including those sent today.
#
# Requires:
#   * curl - transfer a URL
#   * jq - Command-line JSON processor
#
# References:
#   [1] Read multiple Message resources
#   https://www.twilio.com/docs/messaging/api/message-resource#read-multiple-message-resources
#
#   [2] Delete a Message resource
#   https://www.twilio.com/docs/messaging/api/message-resource#delete-a-message-resource
#
cd "$(dirname "$0")"

expirationDate="${1:-$(date +%Y-%m-%d)}"

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
maxMessages=1000 # maximum value allowed for PageSize in [1]

echo "Delete all messages sent/received before $expirationDate..."
curl "$api/Messages.json?PageSize=$maxMessages&DateSent<=$expirationDate" \
  -u "$auth" -s |
jq '.messages[] | .sid + " " + .date_created' --raw-output |
while read -r messageSID weekDay dd month yyyy time timezone
do
  echo "Delete message [$dd $month $yyyy $time] $messageSID..."
  curl -X DELETE "$api/Messages/$messageSID.json" -u "$auth" -s
done

echo 'Done.'

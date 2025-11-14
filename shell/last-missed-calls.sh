#!/bin/sh
# List last missed calls (with status 'no-answer')
# including the date, origin and destination of each missed call
#
# After receiving an error email from Twilio due to a missed call,
# running this script allows to determine the phone number of the caller,
# if available, which may otherwise be listed as 'anonymous'.
#
# Parameter:
#   maxMissedCalls - maximum number of missed calls to list; defaults to 3
#
# Note:
#   Missed calls are listed in both inbound and outbound directions.
#   Both are labelled as 'outbound-dial' from Twilio system's perspective
#   as they both get forwarded by Twilio Dial as a new outbound call,
#   whether they originate from or are directed to our own SIP client.
#
# Requires:
#   * curl - transfer a URL
#   * jq - Command-line JSON processor
#
# References:
#   [1] Call Resource
#   https://www.twilio.com/docs/voice/api/call-resource
#
#   [2] Retrieve a list of Calls
#   https://www.twilio.com/docs/voice/api/call-resource#retrieve-a-list-of-calls
#
#   [3] Call Status values
#   https://www.twilio.com/docs/voice/api/call-resource#call-status-values
#
cd "$(dirname "$0")"

maxMissedCalls="${1:-3}"

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

curl "$api/Calls.json?PageSize=$maxMissedCalls&Status=no-answer" \
  -u "$auth" -s |
jq 'try .calls[] | .status+" "+.from+" "+.to+" "+.start_time' --raw-output |
while read -r status from to startTime
do
  echo "Missed Call ($status)"
  echo "From: $from"
  echo "Date: $startTime"
  echo "To: $to"
  echo
done

echo 'Done.'

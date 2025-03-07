#!/bin/sh
# Delete all logs of calls made before given date (excluded)
# A single run of this script will delete up to 1,000 call logs.
#
# Parameter:
#   expirationDate - date in yyyy-mm-dd format, expiration date for
#                    call logs to delete; defaults to today's date
#
# Note:
# Media resources attached to messages will be deleted as well, unless they
# are used in other messages which have not been deleted yet (see [2]).
#
# This script is intended to delete older call logs completely while preserving
# logs of calls made today, which will remain in Twilio Console. Since logs of
# calls made on the given date are not deleted, you will need to specify a date
# in the future to delete all call logs including those made today.
#
# Requires:
#   * curl - transfer a URL
#   * jq - Command-line JSON processor
#
# References:
#   [1] Read multiple Call resources
#   https://www.twilio.com/docs/voice/api/call-resource#read-multiple-call-resources
#
#   [2] Delete a Call resource
#   https://www.twilio.com/docs/voice/api/call-resource#delete-a-call-resource
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
maxCalls=1000 # maximum value allowed for PageSize in [1]

echo "Delete all logs of calls made before $expirationDate..."
curl "$api/Calls.json?PageSize=$maxCalls&StartTime<=$expirationDate" \
  -u "$auth" -s |
jq '.calls[] | .sid + " " + .date_created' --raw-output |
while read -r callSID weekDay dd month yyyy time timezone
do
  echo "Delete call log [$dd $month $yyyy $time] $callSID..."
  curl -X DELETE "$api/Calls/$callSID.json" -u "$auth" -s
done

echo 'Done.'

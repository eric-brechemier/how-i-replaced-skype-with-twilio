#!/bin/sh
# Delete all voicemail recordings from your Twilio account
#
# Note:
# a single run of this script will delete up to 10,000 voicemails.
#
# Requires:
#   * curl - transfer a URL
#   * jq - Command-line JSON processor
#
cd "$(dirname "$0")"

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

curl "$api/Recordings.json" -u "$auth" -s |
jq '.recordings[] | .sid' --raw-output |
while read -r recordingSID
do
  echo "Delete recording $recordingSID..."
  curl -X DELETE "$api/Recordings/$recordingSID.json" -u "$auth" -s
done

echo 'Done.'

# How I replaced Skype with Twilio

How I replaced Skype with Twilio to make phone calls from my computer.

## Motivation

Working remotely, I have become used to the comfort of making calls
from my computer on Slack or Discord. Using a quality headset gives
a warm sound and a feeling of proximity, and leaves the hands clear
for typing on the keyboard and looking up information during the call.

I have been a longtime subscriber of Skype premium service to get a
similar experience when calling regular phones instead of other computers.
Sadly, as the Skype service stagnated for many years before changing for
the worse in 2017–2018, I had to find a better alternative
and I started to look into [VOIP][] services with support
for calls to the [PSTN][] in 2018–2019.

[VOIP]: https://en.wikipedia.org/wiki/Voice_over_IP
[PSTN]: https://en.wikipedia.org/wiki/Public_switched_telephone_network

## The Long Story

This is the story of how I successfully configured Twilio to get a
mobile phone number which can make and receive calls from my computer.

I described all the steps that I followed in details,
including the understanding that I gained through trial and error,
in separate issues:

* [How Skype dumped me][#1]
* [How I compared different VOIP providers][#2]
* [How I chose a mobile phone number on Twilio][#3]
* [How I tried a few VOIP software phones][#4]
* [How I configured Twilio to send/receive phone calls][#5]
* [How I improved the experience of callers when I am not available][#6]  
  (or How I failed to configure a convincing voice mail using TwiML)

[#1]: https://github.com/eric-brechemier/how-i-replaced-skype-with-twilio/issues/1
[#2]: https://github.com/eric-brechemier/how-i-replaced-skype-with-twilio/issues/2
[#3]: https://github.com/eric-brechemier/how-i-replaced-skype-with-twilio/issues/3
[#4]: https://github.com/eric-brechemier/how-i-replaced-skype-with-twilio/issues/4
[#5]: https://github.com/eric-brechemier/how-i-replaced-skype-with-twilio/issues/5
[#6]: https://github.com/eric-brechemier/how-i-replaced-skype-with-twilio/issues/6

If you are interested only in how to reproduce my current setup,
you can read the short story below.

## The Short Story

### 1. Create your Twilio account

* if you do not have a Twilio account, sign up
* sign in to your Twilio account

### 2. Choose a new phone number

* register a credit card
* add funds to your account
* purchase a new phone number

### 3. Configure SIP

* create a SIP domain
* create a user for your SIP domain
* download and install Linphone on your computer
* add the SIP user in Linphone

### 4. Make calls from your computer

* create a TwiML script which describes how phone calls
  made from the computer are forwarded to regular phones:

```
<?xml version="1.0" encoding="UTF-8"?>
<Response>
  <!--
    Call a Public Switched Telephone Network (PSTN) phone
    using the SIP user name (before the @ in the SIP address)
    as the number to call (in international format E164),
    with my Twilio mobile phone number displayed in caller id.
  -->
  <Dial callerId="+15125550140">{{#e164}}{{To}}{{/e164}}</Dial>
</Response>
```

In the above script, replace the phone number in the `callerId` attribute
with the one that you purchased on Twilio, in international format.

* launch Linphone on your computer
* in Linphone, create a new contact for a regular phone number:
  you have to format the number in international format
  (starting with `+` and country code) and
  add `@` followed with the SIP domain that you created,
  ending with `.sip.us1.twilio.com`:

```
sip:[International Phone Number]@[SIP Domain].sip.us1.twilio.com
```

for example:

```
sip:+13035550123@your-sip-domain.sip.us1.twilio.com
```

* test the setup: call the new contact from Linphone

### 5. Receive calls on your computer

* create a new TwiML script which describes how phone calls received
  from regular phones are answered:

```
<?xml version="1.0" encoding="UTF-8"?>
<Response>
  <!--
  Forward the call to my computer using my SIP address
  -->
  <Dial answerOnBridge="true">
    <Sip>sip:jane-doe@your-sip-domain.sip.us1.twilio.com</Sip>
  </Dial>
  <!--
  If I don't answer, ring busy
  -->
  <Reject reason="busy" />
</Response>
```

In the above script, replace the user name and domain in the `<Sip>` element
with the identifier of the SIP user that you created, followed with `@` and
the SIP domain that you created, ending with `.sip.us1.twilio.com`:

```
<Sip>sip:[SIP User]@[SIP Domain].sip.us1.twilio.com</Sip>
```

* go to the configuration of your phone number on Twilio,
  and next to "A call comes in", select TwiML and the script
  that you just created to manage received phone calls.

## Limitations

The current setup does not fulfill all my expectations yet:

* the audio channels are transported without encryption, and the
  communication can thus be intercepted by any intermediate server

* even for calls from Europe to Europe, the call metadata always
  transits through a Twilio server in the US

* there is no voicemail, the phone always rings busy when unavailable

* there is no way to exchange text messages between the VOIP phone
  and a regular mobile phone

## Licenses

* code: [CC0][] (no attribution required)
* text and images: [CC-BY][] [Eric Bréchemier][EB]

[CC0]: https://creativecommons.org/publicdomain/zero/1.0/
[CC-BY]: https://creativecommons.org/licenses/by/4.0/
[EB]: https://github.com/eric-brechemier/how-i-replaced-skype-with-twilio

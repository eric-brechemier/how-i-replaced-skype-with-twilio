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

I have described all the steps that I followed in details,
including the understanding that I gained through trial and error,
in separate issues:

* [How Skype dumped me][#1]
* [How I compared different VOIP providers][#2]
* [How I chose a mobile phone number on Twilio][#3]
* [How I tried two different VOIP software phones][#4]
* [How I configured Twilio to send/receive phone calls][#5]
* [How I configured Twilio to record voicemail and send it to me by email][#6]
* [How I compared different services to send/receive SMS messages by email][#12]
* [How I configured Twilio and Pipedream to send/receive SMS messages by email][#7]

[#1]: https://github.com/eric-brechemier/how-i-replaced-skype-with-twilio/issues/1
[#2]: https://github.com/eric-brechemier/how-i-replaced-skype-with-twilio/issues/2
[#3]: https://github.com/eric-brechemier/how-i-replaced-skype-with-twilio/issues/3
[#4]: https://github.com/eric-brechemier/how-i-replaced-skype-with-twilio/issues/4
[#5]: https://github.com/eric-brechemier/how-i-replaced-skype-with-twilio/issues/5
[#6]: https://github.com/eric-brechemier/how-i-replaced-skype-with-twilio/issues/6
[#7]: https://github.com/eric-brechemier/how-i-replaced-skype-with-twilio/issues/7
[#12]: https://github.com/eric-brechemier/how-i-replaced-skype-with-twilio/issues/12

If you are interested only in how to reproduce my current setup,
you can read the short story below. It features links to more
details in the long story, if you need them.

## The Short Story

### 1. Create your Twilio account

* if you do not have a Twilio account, [sign up][]
* or if you already have a Twilio account, sign in

[sign up]: https://github.com/eric-brechemier/how-i-replaced-skype-with-twilio/issues/5#issuecomment-486732130

### 2. Choose a new phone number

* [register a credit card][]
* add funds to your account
* [purchase a new phone number][]

[register a credit card]: https://github.com/eric-brechemier/how-i-replaced-skype-with-twilio/issues/5#issuecomment-486774068
[purchase a new phone number]: https://github.com/eric-brechemier/how-i-replaced-skype-with-twilio/issues/5#issuecomment-486873065

### 3. Configure SIP

* [create a SIP user][] for yourself
* [create a SIP domain][] for your Twilio phone number
* download and install [Linphone][] on your computer
* [configure call encryption and add the SIP user][] in Linphone

[create a SIP user]: https://github.com/eric-brechemier/how-i-replaced-skype-with-twilio/issues/5#issuecomment-488743581
[create a SIP domain]: https://github.com/eric-brechemier/how-i-replaced-skype-with-twilio/issues/5#issuecomment-488743605
[Linphone]: https://linphone.org/
[configure call encryption and add the SIP user]: https://github.com/eric-brechemier/how-i-replaced-skype-with-twilio/issues/5#issuecomment-488824107

### 4. Make calls from your computer

* [create a TwiML script][] which describes how phone calls
  made from the computer are forwarded to regular phones:

[create a TwiML script]: https://github.com/eric-brechemier/how-i-replaced-skype-with-twilio/issues/5#issuecomment-489185155

```
<?xml version="1.0" encoding="UTF-8"?>
<!-- Making Calls from SIP to Regular Phones -->
<Response>
  <Dial callerId="{{#e164}}{{SipDomain}}{{/e164}}">
    {{#e164}}{{To}}{{/e164}}
  </Dial>
</Response>
```

* copy the URL of the TwiML bin,
  found in its details after saving the script.
* go to the settings of the SIP domain,
  and under Voice Configuration,
  paste the URL from the clipboard into the Request URL field
* save the settings of the SIP domain

* launch Linphone on your computer
* test the setup: [call a regular phone number][] from Linphone
* you can then [save this phone number as a contact][]

[call a regular phone number]: https://github.com/eric-brechemier/how-i-replaced-skype-with-twilio/issues/4#issuecomment-486283899
[save this phone number as a contact]: https://github.com/eric-brechemier/how-i-replaced-skype-with-twilio/issues/4#issuecomment-486344355

### 5. Receive calls on your computer

* [create a new TwiML script][] which describes how phone calls
  received from regular phones are answered:

[create a new TwiML script]: https://github.com/eric-brechemier/how-i-replaced-skype-with-twilio/issues/5#issuecomment-491344662

```
<?xml version="1.0" encoding="UTF-8"?>
<Response>
  <!-- Receiving Calls from Regular Phones to SIP -->
  <Dial>
    <Sip>sip:me@1-202-555-0162.sip.us1.twilio.com;transport=tls;secure=true</Sip>
  </Dial>
</Response>
```

In the above script, replace the user name and domain in the `<Sip>`
element with the identifier of the SIP user that you created,
followed with `@` and the SIP domain that you created, ending
with `.sip.us1.twilio.com;transport=tls;secure=true`:

```
<Sip>sip:[SIP User]@[SIP Domain].sip.us1.twilio.com;transport=tls;secure=true</Sip>
```

* go to the configuration of your phone number on Twilio
* next to "A call comes in", select TwiML and the script
  that you just created to manage incoming phone calls
* delete the URL next to "A message comes in",
  which answers all texts with a canned response
* save the settings

* try to call your Twilio number from a regular phone

### 6. Configure a voicemail

You can extend the TwiML script which handles incoming calls
to forward the caller to voicemail when you fail to answer:

* [record a voicemail greeting using Audacity][]
* export the greeting as a WAV file (in mono with 8bit/s at 8kHz)
* [upload the WAV as an asset on Twilio][]
* copy the URL of the asset
* go to the [Voicemail Twimlet][]
* [create a custom Voicemail URL][] using the generator form
  at the bottom of the page:
  - Email: the email address where you want to receive voicemail notifications
  - Message: the URL of your greeting, pasted from the clipboard
  - Transcribe: false
* copy the generated URL
* go to the [Forward Twimlet][]
* [create a custom Forward Twimlet URL][]:
  paste your custom Voicemail URL next to FailUrl
  in the form at the bottom of the page,
  then change its protocol from `http` to `https`
* leave all the other fields empty
* copy the generated URL
* go back to your Twilio dashboard
* in the TwiML bin which handles incoming calls,
  add an `action` attribute to the `<Dial>` element
* paste your custom Forward URL as its value
* change the protocol of the URL from `http` to `https`
* then add `&amp;Dial=true` at the end of the URL

[record a voicemail greeting using Audacity]: https://github.com/eric-brechemier/how-i-replaced-skype-with-twilio/issues/6#issuecomment-491966311
[upload the WAV as an asset on Twilio]: https://github.com/eric-brechemier/how-i-replaced-skype-with-twilio/issues/6#issuecomment-492404925
[Voicemail Twimlet]: https://www.twilio.com/labs/twimlets/voicemail
[create a custom Voicemail Twimlet URL]: https://github.com/eric-brechemier/how-i-replaced-skype-with-twilio/issues/6#issuecomment-492413746
[Forward Twimlet]: https://www.twilio.com/labs/twimlets/forward
[create a custom Forward Twimlet URL]: https://github.com/eric-brechemier/how-i-replaced-skype-with-twilio/issues/6#issuecomment-492444770

You now have a script of the form:

```
<?xml version="1.0" encoding="UTF-8"?>
<Response>
  <!-- Receiving Calls from Regular Phones to SIP (with Voicemail) -->
  <Dial action="https://twimlets.com/forward?FailUrl=https%3A%2F%2Ftwimlets.com%2Fvoicemail%3FEmail%3Dyou%2540example.org%26Message%3Dhttps%253A%252F%252Fyour-runtime-domain.twil.io%252Fassets%252Fgreeting.wav%26Transcribe%3Dfalse&amp;Dial=true">
    <Sip>sip:your-sip-user@your-sip-domain.sip.us1.twilio.com;transport=tls;secure=true</Sip>
  </Dial>
</Response>
```

where:
- you@example.org stands for your email address
- https://your-runtime-domain.twil.io/assets/greeting.wav
  stands for the URL of your greeting asset
- your-sip-user stands for the SIP user that you created for yourself
- your-sip-domain stands for the custom SIP subdomain that you created

* you can now close your computer and call your Twilio number
  from a regular phone to test the voicemail

### 7. Configure Pipedream Workflow to [Send SMS Messages by Email][]

[Pipedream]: https://pipedream.com/
[Send SMS Messages by Email]: https://github.com/eric-brechemier/how-i-replaced-skype-with-twilio/issues/7#issuecomment-1080040128
[Receive SMS Messages by Email]: https://github.com/eric-brechemier/how-i-replaced-skype-with-twilio/issues/7#issuecomment-1084939718

* create your [Pipedream][] account]
* a new workflow is created automatically, rename it to *Send SMS by Email*
* select the *Email* action for the trigger step of the workflow
* send a test email to the inbound email address of the workflow

When sending an SMS by email, you will need to include the phone number
of the recipient, in international format, in the subject, e.g.  
*New SMS to +## ###-###-#####*.

* the test event is received by your Pipedream workflow
* continue and add the *Twilio: Send SMS* action as a second step
* create a Twilio API key and connect Pipedream to Twilio API
* select your Twilio phone number as *From*
* configure the following template as *To*:

```
{{steps.trigger.event.headers.subject.replace(/^.+\+/,'+').replace(/[^+0-9]/g,'')}}
```

* configure the following template as *Message Body*:

```
{{steps.trigger.event.body.text}}
```

* test and deploy the configured workflow

### 8. Configure Pipedream Workflow to [Receive SMS Messages by Email][]

* create a new workflow
* name it *Receive SMS by Email*
* select *HTTP / Webhook Requests* as trigger step of the workflow
* configure a static response for the webhook, with status code `200`,
  header `Content-Type: application/xml` and the static response below:

```
<?xml version="1.0" encoding="UTF-8" ?>
<Response/>
```

* configure the trigger URL as webhook for incoming SMS in Twilio dashboard
* send a test SMS to your Twilio phone number
* the test event is received by your Pipedream workflow
* continue and add the *Send Email* action as second step of the workflow
* configure the template below as *Subject*:

```
New SMS from {{steps.trigger.event.body.From}}
```

* configure the template below as *Text*:

```
{{steps.trigger.event.body.Body}}
```

* test and deploy your second workflow

## Limitations

The current setup does not fulfill all of my expectations yet:

* even for calls from Europe to Europe,
  [the call always transits through a Twilio server in the US][#9],
  increasing latency

[#9]: https://github.com/eric-brechemier/how-i-replaced-skype-with-twilio/issues/9

## License

* Code: [CC0][] (no attribution required)
* Text and Images: [CC-BY][] [Eric Bréchemier][EB]

[CC0]: https://creativecommons.org/publicdomain/zero/1.0/
[CC-BY]: https://creativecommons.org/licenses/by/4.0/
[EB]: https://github.com/eric-brechemier/how-i-replaced-skype-with-twilio

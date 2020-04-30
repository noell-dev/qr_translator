# QR_translator

## Description
This Project serves to translate QR-Codes containing certain strings, which follow a Scheme into a Human-Readable Format.

The Use-Case which led to this Project is that in most larger corporate Environments a Scheme is implemented to make sure Object-Names of BACnet Objects are Unique and are describing the assigned HVAC Device.
Since these Schemes have to be able to handle lots of different Devices in many different Object-Names, they rely heavily on abbreviations and therefore are hard to remember or differentiate for Human-Beings.

This App serves the Purpose to make these strings Human-Readable with the help of a scheme definition, which has to be loaded from a configurable remote. Since most corporates don't want their schemes to be out there for everyone else, it is possible that this remote is only available when using a VPN or in a corporate WiFi.
For this case, the Scheme is stored offline for usage without the availablity of the remote.

Since one can imagine a use-case very similar to this, this Projects purpose has changed to support other forms of getting the "Translations" than simple JSON-Files, i.E. APIs.

## ToDo:
 - [ ] Let the user enter strings by hand?
 - [x] Let the user scan the adress of the remote from a QR-Code
 - [ ] Support APIs
 - [ ] Support logging of scanned strings for later use in other programms (csv, json, etc.)
 - [ ] Check for scheme updates even when not in settings and alert

## Needs Fixing:
 - [x] Nearly everything related to Settings

## License:
My code is Licensed under the Open Source [MIT License](https://github.com/noelli/qr_translator/blob/master/LICENSE)

This app is built using [Flutter](https://github.com/flutter/flutter), therefore the corresponding [License](https://github.com/flutter/flutter/blob/master/LICENSE) applies for their code.

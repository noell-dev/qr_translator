# bacnet_translator

This Project serves to translate BACnet Object-Names following a certain Naming-Scheme into a Human-Readable Format.
In most larger corporate Environments a Scheme is implemented to make sure Object-Names are Unique and are describing the assigned HVAC Device.
Since these Schemes have to be able to handle lots of different cases, many different Object-Names and can't be really long, they rely heavily on abbreviations and therefore are hard to remember or differentiate for Human-Beings.


This App serves the Purpose to make these strings Human-Readable with the help of a scheme definition, which has to be loaded from a configurable remote. Since most corporates don't want their schemes to be out there for everyone it is possible that this remote is only available when using a VPN or in a corporate WiFi.
The Scheme then is stored offline for usage without the availablity of the remote.

## ToDo:
 - [ ] Let the user enter Object-Names by hand

## Needs Fixing:
 - [ ] Nearly everything related to Settings
  

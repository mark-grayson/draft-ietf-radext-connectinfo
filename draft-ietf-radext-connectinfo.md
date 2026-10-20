---
title: A syntax for the RADIUS Connect-Info attribute used in Wi-Fi networks
abbrev: Connect-Info
docname: draft-ietf-radext-connectinfo-00
date: 2026-09-24
category: info
submissiontype: IETF


ipr: trust200902
area: general
workgroup: RADEXT Working Group

keyword:
  - Internet-Draft
  - Connect-Info
  - RADIUS

stand_alone: yes
pi: [toc, sortrefs, symrefs]

author:

-
   ins: M. Grayson
   name: Mark Grayson
   organization: Cisco Systems
   street: 10 New Square Park
   city: Feltham
   code: TW14 8HA
   country: UK
   email: mgrayson@cisco.com

-
  ins: J. Redmore
  name: Joshua Redmore
  organization: CableLabs
  street: 858 Coal Creek Cr.
  city: Louisville
  code: 80027
  country: US
  email: j.redmore@cablelabs.com

contributor:
-
  ins: S. Gundavelli
  name: Sri Gundavelli
  organization: Cisco Systems
  street: 170 West Tasman Drive
  city: San Jose
  code: 95134
  country: US
  email: sgundave@cisco.com

-
  ins: B. Tomas
  name: Bruno Tomas
  organization: Wireless Broadband Alliance
  street: 5000 Executive Parkway, Suite 302
  city: San Ramon
  code: 94583
  country: US
  email: bruno@wballiance.com

-
  ins: M. Sym
  name: Michael Sym
  organization: Single Digits
  street: 4 Bedford Farms Drive, Suite 210
  city: Bedford
  code: 03110
  country: US
  email: msym@singledigits.com

-
  ins: B. Bullock
  name: Blair Bullock
  organization: Boldyn Networks
  city: Pleasanton
  country: US
  email: blair.bullock@boldyn.com

-
  ins: J. Padden
  name: Joey Padden
  organization: Helium
  city: Boulder
  country: US
  email: jpadden@helium.com

normative:
  RFC2119:
  RFC8174:
  RFC6973:

informative:
  RFC2869:
  RFC5234:
  RFC6158:
  IEEE80211:
    title: Wireless LAN Medium Access Control (MAC) and Physical Layer (PHY) Specifications
    target: https://standards.ieee.org/ieee/802.11/10548/
    author:
      ins: IEEE


--- abstract

This document describes a syntax for the Connect-Info attribute
used with the RADIUS protocol,
enabling RADIUS clients to provide RADIUS servers information pertaining to a user's
connection with an IEEE 802.11 wireless network.

--- middle

Introduction        {#intro}
============

The Connect-Info attribute is defined in {{RFC2869}} to enable a Network
Access Server (NAS) to indicate to a RADIUS server
"the nature of the user's connection". {{RFC2869}} includes the recommendation that:

>The connection speed SHOULD be included at the beginning of the
first Connect-Info attribute in the packet.  If the transmit and
receive connection speeds differ, they MAY both be included in the
first attribute with the transmit speed first (the speed the NAS
modem transmits at), a slash (/), the receive speed, then
optionally other information.

The Connect-Info attribute can be sent in both Access-Request and
Accounting-Request messages, as shown in {{ci-table}}.

~~~~~~~~~~
+--------------------------------------------------------------+
| Attribute | Request | Accept | Reject | Challenge | Acct-Req |  
+--------------------------------------------------------------+
| Connect-  |   0-1   |   0    |   0    |     0     |    0+    |  
| Info (77) |         |        |        |           |          |  
+--------------------------------------------------------------+

~~~~~~~~~~
{: #ci-table title="RFC2869 defined occurrence rules for Connect-Info attribute"}

Many NAS implementations have implemented the Connect-Info attribute.
Wi-Fi vendors supporting the Connect-Info attribute start the text field
with "CONNECT" that is followed by a floating point value representing the maximum connection speed
in Mbps. Implementations follow this with text information about the IEEE 802.11 amendment supported,
as illustrated in {{ci-example1}}.

~~~~~~~~~~

Connect-Info = "CONNECT 11.00 Mbps 802.11b"

~~~~~~~~~~
{: #ci-example1 title="Example #1 Wi-Fi Connect-Info attribute"}

Other implementations have extended this baseline to signal additional information
to the RADIUS server using a slash (/) delimiter, as illustrated in {{ci-example2}}.

~~~~~~~~~~

Connect-Info = "CONNECT 54.00 Mbps / 802.11n / RSSI: 53 / Channel: 1"

~~~~~~~~~~
{: #ci-example2 title="Example #2 Wi-Fi Connect-Info attribute"}



There are use-cases that benefit from being able to share Wi-Fi network
connection metrics between a NAS and a RADIUS server,
including where the NAS is operated by a Wi-Fi Access Network Provider (ANP)
and the server is operated by an third-party Identity Provider (IDP),
responsible for authenticating Wi-Fi credentials and authorizing access onto the
ANP's Wi-Fi network. Reception of the Connect-Info attribute defined in this
document is intended to be used to assist the IDP in making authorization
decisions.

The rest of this document describes a syntax for the Connect-Info attribute
that is simultaneously able to support existing Wi-Fi vendor implementations as
illustrated in {{ci-example1}} and {{ci-example2}},
while being enhanced with additional optional information to support
new use-cases and requirements.

The technique by which a RADIUS server uses the information encoded in
the Connect-Info attribute to assist in making authorization decisions is not
defined in this document. Some servers may define the use a threshold for one or
more parameters received in a RADIUS Access-Request, other systems may use
historical Connect-Info records from previously authenticated sessions,
including those in the RADIUS Accounting-Request messages received from the same
NAS, still other systems may decide to algorithmically combine the parameters
into a new metric used when making authorization decisions.

The examples in {{ci-example1}} and {{ci-example2}} together with the recommendation
in {{RFC2869}} are representations of complex data types, as described in
{{Section 3.2.3 of RFC6158}}. Whereas {{Section 3.2.4 of RFC6158}} discourages
the use of complex data types where viable alternatives are available, it is
argued that the present document does not introduce a new complex data type,
rather defines and extends the syntax widely used in existing implementations of
the Connect-Info attribute that currently encode information using a complex
data type.


Requirements Language          {#Requirements}
-----------
The key words "MUST", "MUST NOT", "REQUIRED", "SHALL",
"SHALL NOT", "SHOULD", "SHOULD NOT", "RECOMMENDED", "NOT
RECOMMENDED", "MAY", and "OPTIONAL" in this document are to be
interpreted as described in BCP 14 {{RFC2119}} {{RFC8174}}
when, and only when, they appear in all capitals, as shown here.


Terminology          {#Terminology}
-----------


Access Network Provider (ANP):

>A Wi-Fi operator that has configured its Wi-Fi equipment to support inbound roaming of users.

Identity Provider (IDP):

>An entity that authenticates end-user Wi-Fi devices onto ANP networks.

Received Signal Strength Indicator (RSSI):

>A measurement of the power level that is received by an antenna from a wireless device.


Types of Connect-Info Metrics {#Types}
===============

The characteristics associated with the IEEE 802.11 connection
that can be shared between NAS and RADIUS server include those that can be used to derive
a quality metric of the performance of a Wi-Fi network. These are:

* transmit and receive bit rates,
* received signal strength indicator (RSSI),
* frame loss rate,
* frame retry rate, and
* the Wi-Fi global operating class associated with the connection, as defined in {{IEEE80211}}.

While not uniquely associated with a single IEEE 802.11 connection, {{intro}} describes
legacy implementations which include generic parameters concerning the configuration
of the Wi-Fi network signaled in the Connect-Info attribute. These legacy parameters are:

* the maximum Wi-Fi transmit rate,
* the Wi-Fi amendment {{IEEE80211}}, and
* the Wi-Fi channel number.

ABNF syntax for Connect-Info {#abnf}
===============

The Augmented Backus-Naur form (ABNF) is a syntax for specifications
defined in {{RFC5234}}. The ABNF syntax for the text of the Connect-Info
attribute used with Wi-Fi networks is shown below. This syntax encompasses
current vendor implementations, including parameter ordering, while supporting
optional enhancements to support sharing of new parameters.


~~~~~~~~~~

;---------------------------------------------------------------------
; Connect-Info RADIUS Attribute #77 Syntax for Wi-Fi networks
;---------------------------------------------------------------------

connect-info-77   =  "CONNECT" [legacyAttributes]
                     *( DELIMITER keyValueAttribute )
                     [ DELIMITER legacyChannelNum ]
                     *( DELIMITER keyValueAttribute )

;---------------------------------------------------------------------
; Legacy attributes not linked to a specific connection
;---------------------------------------------------------------------

legacyAttributes  =  1*SP MAXSPEED " Mbps" DELIMITER WIFIAMENDMENT
            ; An optional indication of max achievable data rate
            ; together with Wi-Fi 802.11 amendment information

legacyChannelNum  = "Channel:" *SP CHANNUM
            ; An optional 802.11 channel number

;---------------------------------------------------------------------
; keyValueAttributes - attributes linked to a specific connection;
;---------------------------------------------------------------------

keyValueAttribute =  "RSSI:" *SP SS ["(" AGGR ")"]
            ; The value of Station RSSI in dBm and optionally the
            ; aggregation technique use for reporting a value derived
            ; from multiple measurements

keyValueAttribute =/ "TxBitRate:" *SP RATE ["(" AGGR ")"]
            ; The AP to device transmission rate in Mbps and
            ; optionally the aggregation technique use for
            ; reporting a value derived from multiple measurements

keyValueAttribute =/ "RxBitRate:" *SP RATE ["(" AGGR ")"]
            ; The device to AP transmission rate in Mbps and
            ; optionally the aggregation technique use for
            ; reporting a value derived from multiple measurements

keyValueAttribute =/ "FrameLoss:" *SP PCT ["(" AGGR ")"]
            ; The AP to device 802.11 frame loss rate experienced,
            ; encoded as an integer percentage and optionally the
            ; aggregation technique use for reporting a value derived
            ; from multiple measurements

keyValueAttribute =/ "FrameRetry:" *SP PCT ["(" AGGR ")"]
            ; The AP to device 802.11 frame retry rate experienced,
            ; encoded as an integer percentage and optionally the
            ; aggregation technique use for reporting a value derived
            ; from multiple measurements

keyValueAttribute =/ "Global-OC:" *SP GOC ["(Link-ID=" LINKID ")"]  
            ; Wi-Fi Global Operating Class as defined in IEEE 802.11
            ; Annex E and an optional Link-ID used for multiple links
            ; where LINKID identifies the corresponding link using
            ; the IEEE 802.11 Link ID.

;---------------------------------------------------------------------
; keyValueAttributes - extensibility syntax.
;
; This syntax enables the syntax to be extended in the future.
;---------------------------------------------------------------------

keyValueAttribute =/ 1*NO-DELIM-COLON ":"  *SP 1*NO-DELIM-COLON
            ; Syntax permitting extensibility

;---------------------------------------------------------------------
; Definitions for legacy attributes
;---------------------------------------------------------------------

MAXSPEED         =  (DIGIT / (NZDIGIT DIGIT) / (NZDIGIT DIGIT DIGIT) /
                    (NZDIGIT DIGIT DIGIT DIGIT) /
                    (NZDIGIT DIGIT DIGIT DIGIT DIGIT)) "." DIGIT DIGIT
            ; Maximum theoretical AP-to-STA PHY data rate in Mbps,
            ; (0.00 - 99999.99). This is a network-level capability
            ; indicator, not the negotiated or currently achieved rate
            ; of a station, calculated as:
            ; SC * MD * CR * SS / (SYM + GD)
            ; where:
            ; SC  = Number of Data Sub-Carriers
            ; CR  = Coding Rate, e.g., 0.5 (BPSK),
            ;       0.75 (256QAM)
            ; MD  = Modulation rate (1-8),
            ;       where 2^MD = num mod'n states
            ; SS  = number of spatial streams
            ; SYM = symbol interval (micro-seconds)
            ; GD  = guard interval (micro-seconds). For PHYs supporting
            ; multiple guard intervals, the calculation MUST use the
            ; guard interval specified for the applicable amendment.

WIFIAMENDMENT    =  "802.11" AMENDMENT

AMENDMENT        =  "b" / "g" / "a" / "n" / "ac" / "ax" / "be"
            ; the original 802.11 amendment
            ; Note, whereas the industry has moved to define the use
            ; of Wi-Fi 4/5/6/7 terminology, the amendment is still
            ; used here to enable backwards compatibility with
            ; legacy implementations

CHANNUM          =  NZDIGIT / (NZDIGIT DIGIT) / ("1" DIGIT DIGIT) /
                    ("2" U4DIGIT DIGIT)
            ; Encoding for Channel Numbers (1 - 249)
            ; Note - with the introduction of Wi-Fi operation in
            ; 6 GHz, the Channel Number no longer uniquely identifies
            ; the band of operation

;---------------------------------------------------------------------
; Definitions for connection orientated attributes
;---------------------------------------------------------------------

SS               =  ["-"] (DIGIT / (NZDIGIT DIGIT) / ("1" DIGIT DIGIT))
            ; Value of received signal strength expressed in dBm
            ; To accommodate different legacy implementations, both 41
            ; and -41 represent -41 dBm

RATE             =  (DIGIT / (NZDIGIT DIGIT) / (NZDIGIT DIGIT DIGIT) /
                    (NZDIGIT DIGIT DIGIT DIGIT) /
                    (NZDIGIT DIGIT DIGIT DIGIT  DIGIT)) ["." DIGIT]
            ; A transmit or receive rate in Mbps

GOC              =  NZDIGIT / (NZDIGIT DIGIT) / ("1" DIGIT DIGIT) /
                    ("2" U4DIGIT DIGIT) / ("25" U5DIGIT )
            ; Encoding of Global Operating Class (1-255)

PCT              =  DIGIT / (NZDIGIT DIGIT) / "100"
            ; Percentage (0 - 100)

AGGR             =  ALGO SP ( WINDOW / (WEIGHT ["-" SAMPLE]) )
            ; How multiple measurements are combined into a single
            ; reported value

ALGO             =  "MIN" / "MAX" / ("AVG" "-" VARIANT ) / "ACC"
            ; The algorithm used for combining multiple samples:
            ; MIN = minimum value over window
            ; MAX = maximum value over window
            ; AVG = average value over window or exponent
            ; ACC = accumulated ratio over window, corresponding to
            ; ( num[N] - num[1]) / ( denom[N] - denom[1] )
            ; and where ACC only applies to loss and retry rates

VARIANT          =  "LIN" / "EXP"
            ; LIN = linear (arithmetic mean) average calculation
            ; EXP = exponential weighted average calculation

WINDOW           =  (DIGIT / (NZDIGIT DIGIT) / (NZDIGIT DIGIT DIGIT))
                    TIMEUNIT
            ; The time window over which the algorithm operates,
            ; measured in units of TIMEUNIT

WEIGHT           =  NZDIGIT
            ; The weighting of the AVG-EXP algorithm, where the
            ; exponential weight is 2^WEIGHT

SAMPLE           = (DIGIT / (NZDIGIT DIGIT) / (NZDIGIT DIGIT DIGIT) )
            ; The sample period in milliseconds used in the
            ; exponential moving average

TIMEUNIT         =  "S" / "M"
            ; S = units of seconds, M = units of minutes

LINKID           = DIGIT / ("1" U5DIGIT)
            ; IEEE 802.11be Link ID: 0-15

DELIMITER        =  SLASH / 1*SP
            ; existing vendor delimiters

NO-DELIM-COLON   = %x21-2e / %x30-39 / %x3b-7e
            ; any characters excluding delimiters - space (0x20) and
            ; slash (0x2f) - as well as colon (0x3a)

SP               =  %x20
SLASH            =  *SP %x2F *SP

DIGIT            =  %x30-39 ; 0-9
NZDIGIT          =  %x31-39 ; 1-9
U4DIGIT          =  %x30-34 ; 0-4 (up to 4)
U5DIGIT          =  %x30-35 ; 0-5 (up to 5)

~~~~~~~~~~
{: #figabnf title="ABNF definition for encoding of Connect-Info text field"}

Encoding Recommendations
==================

Example encodings using the ABNF definition are illustrated in {{ci-example3}}
and {{ci-example4}}. These illustrate that the metrics can be signaled while
keeping the attribute size below 253 bytes.

If a RADIUS session is associated with a station operating using Multi-Link
Operation (MLO), the Connect-Info attribute MAY include multiple instances of
the Global-OC key-value attribute, corresponding to each operational link.

Access-Request {#access-request}
--------------

The inclusion of the above defined parameters in a Connect-Info attribute
signaled in a RADIUS Access-Request message is restricted by the number of
IEEE 802.11 frames over which the calculation are based. In such cases, the
transmit bit rates, receive bit rates and RSSI level MAY correspond to the
instantaneous value of the specific parameter. When signaling an instantaneous
value, the "AGGR" definition SHOULD NOT be included in the reported Connect-Info
attribute.

~~~~~~~~~~
Connect-Info = "CONNECT 54.00 Mbps / 802.11n / Channel: 1 / RSSI: 53"

Connect-Info = "CONNECT 400.00 Mbps 802.11ac Channel:44 RSSI:50"

Connect-Info = "CONNECT RSSI:56 TxBitRate:150.0 RxBitRate:150.0
                Global-OC:116"

Connect-Info = "CONNECT 400.00 Mbps 802.11ax RSSI:56 TxBitRate:150.0
                RxBitRate:150.0 Global-OC:133(Link-ID:0)"

~~~~~~~~~~
{: #ci-example3 title="Example encodings of Connect-Info attribute in RADIUS Access-Request message"}


Accounting-Request
--------------

The inclusion of the  Connect-Info attribute signaled in a  RADIUS
Accounting-Request with Acct-Status-Type set to Start, may be restricted by the
number of IEEE 802.11 frames over which the calculation are based. In such
cases, the transmit bit rates, receive bit rates and RSSI level MAY
correspond to the instantaneous value of the specific parameter in which case
the reporting with the "AGGR" definition SHOULD follow the rules introduced in
{{access-request}}.

In other cases, i.e., where the Connect-Info attribute is signaled in RADIUS
Accounting-Request messages with Acct-Status-Type set to Interim-Update or Stop,
the NAS SHOULD use multiple measurements when calculating the reported value:

* the reported transmit and receive bit rates SHOULD represent the maximum
values experienced since the last time the connect-info was signaled, i.e. the
"ALGO" term SHOULD be set to "MAX".

* the received signal strength indicator (RSSI) SHOULD represent the average
RSSI value, where the average value calculated MAY be either a linear average or
an exponential weighted average, i.e. the "ALGO" term SHOULD be set to "AVG".

* frame loss rate and frame retry rate SHOULD represent the accumulated ratio,
i.e. the "ALGO" term SHOULD be set to "ACC".

~~~~~~~~~~

Connect-Info = "CONNECT RSSI:56(AVG-LIN 10M) TxBitRate:150.0(MAX 10M)
                RxBitRate:150.0(MAX 10M)"

Connect-Info = "CONNECT 400.00 Mbps 802.11ac RSSI:56(AVG-LIN 600S)
                TxBitRate:150.0(MAX 600S) RxBitRate:150.0(MAX 600S)
                FrameLoss:3(ACC 60S) FrameRetry:6(ACC 60S)"

Connect-Info = "CONNECT TxBitRate:150.0(MAX 30S)
                RxBitRate:120.5(MAX 30S) RSSI:-65(AVG-EXP 6-100)
                FrameLoss:2(ACC 30S) FrameRetry:4(ACC 30S)
                Global-OC:133(Link-ID:0)"

~~~~~~~~~~
{: #ci-example4 title="Example encodings of Connect-Info attribute in RADIUS Accounting-Request message"}



Security Considerations {#Security}
==================

This document describes a syntax that enables a RADIUS client to provide a
RADIUS server with information pertaining to the operation of an IEEE 802.11
wireless network, including connection metrics such as RSSI.

* Implementations SHOULD ensure that Connect-Info attributes are transmitted
only over secure channels (e.g., using RADIUS secured with TLS), to protect
against unauthorized interception.

* Operators SHOULD have interconnection agreements or policies in place
governing the use, storage, and disclosure of connection metrics such as RSSI,
consistent with the privacy considerations discussed in {{Privacy}}.

Privacy Considerations {#Privacy}
==================

This section discusses the privacy implications of the Connect-Info attribute
using the terminology of {{RFC6973}}.

While the Connect-Info attribute is intended to convey non-personal,
network-operational information, some metrics - particularly RSSI - are
indirectly identifying: they can reveal information about the physical location
or movement of an end user relative to the access point. When correlated with
other data, such as known access point locations, RSSI values may enable
inference of a user's presence or proximity within a specific area. This
constitutes a privacy risk in the sense of identifiability and correlation
discussed in {{RFC6973}}', even though no directly identifying information
(e.g., MAC address, username) is itself carried in the attribute.

The primary mitigations available to limit this risk are:

* Data minimization: implementations SHOULD transmit only the connection metrics
needed for the intended operational purpose, and SHOULD avoid retaining RSSI
values for longer than necessary.

* Unlinkability: operators SHOULD avoid associating RSSI and similar metrics
with persistent user identifiers, to reduce the risk of correlating a user's
location or movement across sessions.


This document does not define a mechanism for end users to be informed of or
consent to the collection of these metrics; such notice and consent, where
required, are matters of operator policy and applicable law, and are out of
scope for this document.


IANA Considerations {#IANA}
==================

This document has no IANA Actions.



--- back


# Changelog {#Changelog}
{: numbered="false"}
*  00 - Adopted as RADEXT Working Group document (was draft-grayson-connectinfo-10).
Split security section into security and privacy sections.


# Acknowledgements {#Acknowledgements}
{: numbered="false"}

The authors would like to thank all the members of the WBA's Access Network
Metrics project team, as well as Iegor Sergieienkov, who have helped review and
refine the Connect-Info syntax.

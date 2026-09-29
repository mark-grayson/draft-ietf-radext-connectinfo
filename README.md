# draft-ietf-radext-connectinfo

This is the working area for the IETF RADEXT Working Group Internet-Draft,
`draft-ietf-radext-connectinfo`.

The draft describes a syntax for the RADIUS Connect-Info attribute that lets a
RADIUS client (for example a Wi-Fi access point or controller) tell a RADIUS
server about a user's connection to an IEEE 802.11 network.

* [Internet-Draft](https://datatracker.ietf.org/doc/draft-ietf-radext-connectinfo/)
* [Radext Working Group page](https://datatracker.ietf.org/wg/radext/about/)

## Contributing

Discussion of this draft happens on the RADEXT mailing list
(<radext@ietf.org>) and in the issues and pull requests in this repository.

IETF's participation rules, see the [Note Well](https://www.ietf.org/about/note-well/),
applies to all contributions here.

## Dependencies

The draft source is `draft-ietf-radext-connectinfo.md`, in
[kramdown-rfc](https://github.com/cabo/kramdown-rfc) Markdown.

```sh
gem install kramdown-rfc
pip install xml2rfc
```

## Building

```sh
make draft-ietf-radext-connectinfo.txt  ## make the text version
make draft-ietf-radext-connectinfo.html ## make the html version
```

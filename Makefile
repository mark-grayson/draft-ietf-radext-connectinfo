# Build the Internet-Draft from Markdown.
# Requires: kramdown-rfc (gem), xml2rfc (pip); curl + jq for "submit"; aspell for "spell".

DRAFT := $(basename $(wildcard draft*.md))

VERSION := $(shell sed -n -e'/docname/s,.*[^0-9]*-\([0-9]*\).*,\1,p' ${DRAFT}.md )

EXAMPLES =

# Address the Datatracker sends the confirmation email to.
# Override on the command line: make submit SUBMITTER=you@example.com
SUBMITTER ?= $(shell git config user.email)

${DRAFT}-${VERSION}.txt: ${DRAFT}.txt
	@cp ${DRAFT}.txt ${DRAFT}-${VERSION}.txt

%.xml: %.md ${EXAMPLES}
	@kramdown-rfc2629 -3 ${DRAFT}.md > ${DRAFT}.xml
	@xml2rfc --v2v3 ${DRAFT}.xml
	@mv ${DRAFT}.v2v3.xml ${DRAFT}.xml

%.txt: %.xml
	@xml2rfc --text -o $@ $?

%.html: %.xml
	@xml2rfc --html -o $@ $?

.PHONY: html
html: ${DRAFT}.html

.PHONY: submit
submit: ${DRAFT}.xml
	@test -n "${SUBMITTER}" || (echo "Set SUBMITTER=<author email>"; exit 1)
	@curl -S -F "user=${SUBMITTER}" -F "xml=@${DRAFT}.xml" https://datatracker.ietf.org/api/submission | jq
	@echo "Check ${SUBMITTER} for the Datatracker confirmation, then run 'make tag'."

.PHONY: version
version:
	@echo Version: ${VERSION}

.PHONY: clean
clean:
	@rm -f *.xml *.txt *.html *~

.PHONY: tag
tag:
	@git tag ${DRAFT}-${VERSION}

.PRECIOUS: ${DRAFT}.xml

.PHONY: spell
spell: $(DRAFT).md
	aspell -d en_US -c $<

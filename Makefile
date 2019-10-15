#!/usr/bin/make -f

MAKEFLAGS += -Rr
SHELL != which bash
SHELL += -o pipefail

top:; @date

self := $(lastword $(MAKEFILE_LIST))

include conf.mk

site := $(src)/oxa/ips

tmp := tmp
out := out
dirs := $(tmp) $(out) legacy
$(self): $(dirs:%=%/.stone)
%/.stone:; mkdir -p $(@D); touch $@

.DEFAULT_GOAL := main
.DELETE_ON_ERROR:

indent := 2
yaml2json.py := import sys, yaml, json;
yaml2json.py += json.dump(yaml.load(sys.stdin), sys.stdout, indent=$(indent), default=str, sort_keys=True)
yaml2json_py := python -c '$(yaml2json.py)'

depth = $(shell echo $$(($1 * $(indent))))
pretty  = BEGIN { ORS = "" }
pretty += !/^ {$(call depth, $1),}/ { print; print "\n"; next }
pretty += /}, *$$/ { gsub(/ +/, " "); print; print "\n"; next }
pretty += /^ {$(call depth, $1)}{$$/ { print; next }
pretty += { gsub(/ +/, " "); print }

yml2js = python -c '$(yaml2json.py)'
yml2js-pretty = $(yml2js) | awk '$(call pretty, 2)' > $@

oxa.networks := $(wildcard $(site)/*.oxa.yml)
oxa.ips := $(oxa.networks:$(site)/%.oxa.yml=%)
oxa.ips.js := $(oxa.ips:%=$(tmp)/%.oxa.js)

$(tmp)/%.js: $(site)/%.yml; < $< $(yml2js-pretty)

diffable = $(tmp)/tmp.js && cp --backup=numbered $(tmp)/tmp.js $@

####

networks.src := $(site)/networks.yml
$(networks.src).jq := { site, networks } | walk(if type == "object" then with_entries(.key |= sub("^id$$"; "cidr")) else . end)
networks := $(out)/networks.js

$(tmp)/networks.js: $(site)/networks.yml $(self); < $< $(yml2js) | jq '$($<.jq)' > $@
$(networks): networks.jsonnet $(tmp)/networks.js; ./$< > $(diffable)
networks: $(networks)

####

networks.libsonnet = echo '{'; $(foreach _, $(oxa.ips), echo '$_: import "$_.oxa.js",';) echo '}';
$(tmp)/networks.libsonnet: $(self) $(oxa.networks); ($($(@F))) | jsonnet fmt - > $@

ips := $(out)/ips.js
ips.js  = ./$< --ext-code-file 'networks=$(tmp)/networks.libsonnet' | jq . > $(tmp)/tmp.js &&
ips.js += cp --backup=numbered $(tmp)/tmp.js $@
$(ips): ips.jsonnet loc.libsonnet $(oxa.ips.js) $(tmp)/networks.libsonnet; $($(@F))
ips: $(ips)

####

serial := $(out)/serial.js
serial.jq := .list.name | join("\n")
serial.js  = (echo '{';
serial.js += jq -r '$(serial.jq)' $<
serial.js += | xargs -i stat -c '{}: %Y,' $(site)/{}.oxa.yml;
serial.js += echo '}')
serial.js += | jsonnet /dev/stdin
$(serial): $(networks) $(self); $($(@F)) > $(diffable)
serial: $(serial)

###

legacy := legacy/ips.js legacy/networks.js
legacy/networks.js: $(networks)
legacy/ips.js: $(networks) $(ips) $(serial)
$(legacy): legacy/%.js : %-legacy.jsonnet $(self); ./$< > $(diffable)
legacy: $(legacy)

####

mds.js := $(filter $(tmp)/public%, $(oxa.ips.js))
mds.csv := $(mds.js:$(tmp)/%.js=$(out)/%.csv)
mds.md := $(mds.csv:%.csv=%.md)
mds: $(mds.csv) $(mds.md)

csvtomd := ~/.local/bin/csvtomd
pip3    := /usr/bin/pip3

$(out)/%.csv: csv.jq $(tmp)/%.js; ./$^ > $@
$(out)/%.md: $(csvtomd) $(out)/%.csv; $^ > $@

$(csvtomd): $(pip3); $< install $(@F)

$(pip3) := python3-pip
$(pip3):; sudo aptitude install $($@)

main: networks ips legacy mds

diff/%:; p=$$(ls -t $*.~*~ 2> /dev/null | head -1); test $$p && diff $$p $* || true
diff := $(networks) $(ips) $(legacy) $(serial)
diff: $(diff:%=diff/%)

clean:; @echo rm -r $(tmp) $(out) legacy

.PHONY: top main networks ips mds legacy diff

oxa := $(data)/oxa
install.dirs := $(oxa)/legacy $(doc)

install = install $< $@
$(oxa)/legacy/%.js: legacy/%.js; $(install)
$(oxa)/%.js: $(out)/%.js; $(install)
$(doc)/%.md: $(out)/%.md; $(install)

installed := $(networks:$(out)/%=$(oxa)/%)
installed += $(ips:$(out)/%=$(oxa)/%)
installed += $(mds.md:$(out)/%=$(doc)/%)
installed += $(legacy:legacy/%=$(oxa)/legacy/%)

install: $(install.dirs:%=%/.stone) $(installed)
.PHONY: install

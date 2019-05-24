#!/usr/bin/make -f

MAKEFLAGS += -Rr
SHELL != which bash

top:; @date

self := $(lastword $(MAKEFILE_LIST))

site := oxa

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

oxa.networks := $(wildcard oxa/*.oxa.yml)
oxa.ips := $(oxa.networks:oxa/%.oxa.yml=%)
oxa.ips.js := $(oxa.ips:%=$(tmp)/%.oxa.js)

$(tmp)/%.js: oxa/%.yml; < $< $(yml2js-pretty)

diffable = $(tmp)/tmp.js && cp --backup=numbered $(tmp)/tmp.js $@

####

networks.src := $(site)/networks.yml
$(networks.src).jq := { site, networks } | walk(if type == "object" then with_entries(.key |= sub("^id$$"; "cidr")) else . end)
networks := $(out)/networks.js

$(tmp)/networks.js: $(site)/networks.yml $(self); < $< $(yml2js) | jq '$($<.jq)' > $@
$(out)/networks.js: networks.jsonnet $(tmp)/networks.js; $< > $(diffable)

networks: $(out)/networks.js

legacy/networks.js: networks-legacy.jsonnet $(out)/networks.js $(self); $< > $(diffable)
legacy/ips.js: ips-legacy.jsonnet $(out)/networks.js $(out)/ips.js $(self); $< > $(diffable)

legacy := legacy/networks.js legacy/ips.js
legacy: $(legacy)

####

networks.libsonnet = echo '{'; $(foreach _, $(oxa.ips), echo '$_: import "$_.oxa.js",';) echo '}';
$(tmp)/networks.libsonnet: $(self) $(oxa.networks); ($($(@F))) | jsonnet fmt - > $@

ips := $(out)/ips.js
ips.js  = $< --ext-code-file 'networks=$(tmp)/networks.libsonnet' | jq . > $(tmp)/tmp.js &&
ips.js += cp --backup=numbered $(tmp)/tmp.js $@
$(ips): ips.jsonnet $(oxa.ips.js) $(tmp)/networks.libsonnet; $($(@F))
ips: $(ips)

mds.js := $(filter $(tmp)/public%, $(oxa.ips.js))
mds.csv := $(mds.js:$(tmp)/%.js=$(out)/%.csv)
mds.md := $(mds.csv:%.csv=%.md)
mds: $(mds.csv) $(mds.md)

csvtomd := ~/.local/bin/csvtomd
pip3    := /usr/bin/pip3

$(out)/%.csv: csv.jq $(tmp)/%.js; $^ > $@
$(out)/%.md: $(csvtomd) $(out)/%.csv; $^ > $@

$(csvtomd): $(pip3); $< install $(@F)

$(pip3) := python3-pip
$(pip3):; sudo aptitude install $($@))

main: networks ips legacy mds

diff/%:; p=$$(ls -t $*.~*~ 2> /dev/null | head -1); test $$p && diff $$p $* || true
diff := $(networks) $(ips) $(legacy)
diff: $(diff:%=diff/%)

.PHONY: top main networks ips mds legacy diff

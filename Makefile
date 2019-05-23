#!/usr/bin/make -f

MAKEFLAGS += -Rr
SHELL != which bash

top:; @date

self := $(lastword $(MAKEFILE_LIST))

site := oxa

tmp := tmp
out := out
dirs := $(tmp) $(out)
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

####

networks := $(site)/networks.yml
$(networks).jq := { site, networks }

$(tmp)/networks.js: $(site)/networks.yml $(self); < $< $(yml2js) | jq '$($<.jq)' > $@
$(out)/networks.js: networks.jsonnet $(tmp)/networks.js; $< > $(tmp)/tmp.js && cp --backup=numbered $(tmp)/tmp.js $@

networks: $(out)/networks.js

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

main: networks ips mds

diff: previous != ls -t $(ips).~*~ 2> /dev/null | head -1
diff:; diff $(previous) $(ips)

.PHONY: top main networks ips mds diff

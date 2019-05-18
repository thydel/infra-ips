#!/usr/bin/make -f

MAKEFLAGS += -Rr
SHELL != which bash

top:; @date

self := $(lastword $(MAKEFILE_LIST))

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

csvtomd := ~/.local/bin/csvtomd
pip3    := /usr/bin/pip3

yml2js = < $< python -c '$(yaml2json.py)' | awk '$(call pretty, 2)' > $@

oxa.networks := $(wildcard oxa/*.oxa.yml)
oxa.ips := $(oxa.networks:oxa/%.oxa.yml=%)
oxa.ips.js := $(oxa.ips:%=$(tmp)/%.oxa.js)

$(tmp)/%.js: oxa/%.yml; $(yml2js)

networks.libsonnet = echo '{'; $(foreach _, $(oxa.ips), echo '$_: import "$_.oxa.js",';) echo '}';
$(tmp)/networks.libsonnet: $(self); ($($(@F))) | jsonnet fmt - > $@

ips := $(out)/ips.js
ips.js  = $< --ext-code-file 'networks=$(tmp)/networks.libsonnet' | jq . > $(tmp)/tmp.js &&
ips.js += cp --backup=numbered $(tmp)/tmp.js $@
$(ips): ips.jsonnet $(oxa.ips.js) $(tmp)/networks.libsonnet; $($(@F))

main: $(ips)

previous != ls -t $(ips).~*~ | head -1
diff:; diff $(previous) $(ips)

.PHONY: top main diff

#!/usr/bin/make -f

MAKEFLAGS += -Rr
SHELL != which bash
self := $(lastword $(MAKEFILE_LIST))
.DEFAULT_GOAL := main

main:
	get-priv-repos.yml -e dir=$$(pwd)
	ln -s ext/ips/oxa

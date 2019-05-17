#!/usr/bin/env jsonnet

local loc = import 'loc.libsonnet';

local networks = std.extVar('networks');

local e = loc.mwk(function(v) loc.expand(loc.hide(v.ips), [ 'name', 'id' ]), networks);
local l = loc.mwk(function(v) v.list { id: null, ip: super.id }, e);
local n = loc.mwk(function(v) v.index { name: loc.mwk(function(v) v.id, v.index.name) } { id: null }, e);
local i = n
  { [n] +: { ip: loc.permutKeyValue(i[n].name) } for n in std.objectFields(networks) }
  { [n] +: { alias: loc.extract(e[n].index.name, 'alias') } for n in std.objectFields(networks) };

std.prune({ list: l, index: i })

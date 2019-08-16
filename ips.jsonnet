#!/usr/bin/env jsonnet

local loc = import 'loc.libsonnet';

local networks = std.extVar('networks');

local h = loc.mwk(function(v) loc.hide(v.ips), networks);
local s = loc.mwk(function(v) loc.show(v, 'ssh'), h);
local e = loc.mwk(function(v) loc.expand(v, [ 'name', 'id' ]), h);
local l = loc.mwk(function(v) v.list { id: null, ip: super.id }, e);
local n = loc.mwk(function(v) v.index { name: loc.mwk(function(v) v.id, v.index.name) } { id: null }, e);

local x = loc.mwk(function(v) loc.expand(v, [ 'name' ]), s);
local y = loc.mwk(function(v) v.list, x);

local i = n
  { [n] +: { ip: loc.permutKeyValue(i[n].name) } for n in std.objectFields(networks) }
  { [n] +: { alias: loc.extract(e[n].index.name, 'alias') } for n in std.objectFields(networks) };

std.prune({ ssh: y, list: l, index: i })

//

local objectify(l, s = 'name') = std.foldl(function(a, e) a + { [e[s]]: e }, l, {});
local values(lo, a) = std.map(function(o) o[a], lo);
local permutKeyValue(o) = { [o[k]]: k for k in std.objectFields(o) };
local extract(o, f) = { [if f in o[k] then k]: o[k][f] for k in std.objectFields(o) };

local hide(l, k = 'hide') = std.filter(function(o) !(k in o), l);
local show(l, k) = std.filter(function(o) k in o && o[k] == true, l);

local expand(lo, lk) = {
  index: { [k]: { [std.toString(o[k])]: o for o in lo } for k in lk },
  list: { [k]: values(lo, k) for k in lk }
};

local expandPrune(lo, lk) = {
  index: { [k]: { [std.toString(o[k])]: std.prune(std.mapWithKey(function(kk, v) if kk != k then v, o)) for o in lo } for k in lk },
  list: { [k]: values(lo, k) for k in lk }
};

local mwk(f, l) = std.mapWithKey(function(_, v) f(v), l);

{
  values:: values,
  permutKeyValue:: permutKeyValue,
  extract:: extract,
  hide:: hide,
  show:: show,
  expand:: expand,
  expandPrune:: expandPrune,
  mwk:: mwk,
}

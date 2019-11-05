#!/usr/bin/env jsonnet

local file = import 'tmp/networks.js';

local loc = import 'loc.libsonnet';

loc.expandPrune(loc.hide(file.networks), [ 'name', 'vlan', 'vname', 'cidr' ])

# Local Variables:
# indent-tabs-mode: nil
# End:

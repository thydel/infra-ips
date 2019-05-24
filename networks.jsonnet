#!/usr/bin/env jsonnet

local file = import 'tmp/networks.js';

local loc = import 'loc.libsonnet';

loc.expandPrune(loc.hide(file.networks), [ 'name', 'vlan', 'cidr' ])

# Local Variables:
# indent-tabs-mode: nil
# End:

#!/usr/bin/env jsonnet

local networks = import 'out/networks.js';

local lk = [ 'name', 'cidr', 'vlan', 'vname' ];
{ networks_list: { [k]: networks.list[k] for k in lk } + { ['network_' + k]: networks.index[k] for k in lk } }

# Local Variables:
# indent-tabs-mode: nil
# End:

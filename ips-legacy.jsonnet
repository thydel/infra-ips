#!/usr/bin/env jsonnet

local networks = import 'out/networks.js';
local ips = import 'out/ips.js';

local nets = networks.list.name;
local networks_ip = { [net]: ips.index[net].name for net in nets };
local networks_cidr = {
  [net]: {
    [node]: ips.index[net].name[node] + '/' + std.split(networks.index.name[net].cidr, '/')[1] for node in ips.list[net].name
  } for net in nets
};

{
  networks_ip_list: { [net]: ips.list[net] for net in nets },
  networks_ip: networks_cidr,
  networks_alias: { [net]: ips.index[net].alias for net in nets if 'alias' in ips.index[net] },
  Ips: networks_ip,
}

# Local Variables:
# indent-tabs-mode: nil
# End:

oc get nodenetworkstates.nmstate.io -o json | jq ' [ .items[] | {"name": .metadata.name, "interfaces": [ .status.currentState.interfaces[] | select(.type == "ethernet" and .controller=="ovs-system"|not) |  [(.name | if length > 17 then .[0:17] + "..." else . + (" " * (20 - length)) end ),( .type | . + (" " * (20 - length))),(.ipv4.address[0]| .ip | . + ( " " * (12-length)))] | join(" ") ] }]'


## EXAMPLE OUTPUT
# [
#   {
#     "name": "node01",
#     "interfaces": [
#       "br-ex                ovs-interface        172.31.1.151",
#       "br-ex                ovs-bridge                       ",
#       "br-int               ovs-interface                    ",
#       "eno1                 ethernet                         ",
#       "lo                   loopback             127.0.0.1   ",
#       "ovn-k8s-mp0          ovs-interface        172.30.6.2  ",
#       "patch-br-ex_node0... ovs-interface                    ",
#       "patch-br-int-to-b... ovs-interface                    "
#     ]
#   },
#   {
#     "name": "node02",
#     "interfaces": [
#       "br-ex                ovs-bridge                       ",
#       "br-ex                ovs-interface        172.31.1.152",
#       "br-int               ovs-interface                    ",
#       "enp0s31f6            ethernet                         ",
#       "lo                   loopback             127.0.0.1   ",
#       "ovn-k8s-mp0          ovs-interface        172.30.8.2  ",
#       "patch-br-ex_node0... ovs-interface                    ",
#       "patch-br-int-to-b... ovs-interface                    "
#     ]
#   },
#   {
#     "name": "node03",
#     "interfaces": [
#       "br-ex                ovs-interface        172.31.1.153",
#       "br-ex                ovs-bridge                       ",
#       "br-int               ovs-interface                    ",
#       "enp0s31f6            ethernet                         ",
#       "lo                   loopback             127.0.0.1   ",
#       "ovn-k8s-mp0          ovs-interface        172.30.10.2 ",
#       "patch-br-ex_node0... ovs-interface                    ",
#       "patch-br-int-to-b... ovs-interface                    "
#     ]
#   },
#   {
#     "name": "node04",
#     "interfaces": [
#       "br-ex                ovs-interface        172.31.1.219",
#       "br-ex                ovs-bridge                       ",
#       "br-int               ovs-interface                    ",
#       "eno1                 ethernet                         ",
#       "iot-vlan             vlan                             ",
#       "iot-vlan-bridge      linux-bridge                     ",
#       "lo                   loopback             127.0.0.1   ",
#       "ovn-k8s-mp0          ovs-interface        172.30.12.2 ",
#       "patch-br-ex_node0... ovs-interface                    ",
#       "patch-br-int-to-b... ovs-interface                    "
#     ]
#   },
#   {
#     "name": "node05",
#     "interfaces": [
#       "br-ex                ovs-bridge                       ",
#       "br-ex                ovs-interface        172.31.1.217",
#       "br-int               ovs-interface                    ",
#       "enp0s31f6            ethernet                         ",
#       "iot-vlan             vlan                             ",
#       "iot-vlan-bridge      linux-bridge                     ",
#       "lo                   loopback             127.0.0.1   ",
#       "ovn-k8s-mp0          ovs-interface        172.30.0.2  ",
#       "patch-br-ex_node0... ovs-interface                    ",
#       "patch-br-int-to-b... ovs-interface                    "
#     ]
#   },
#   {
#     "name": "node06",
#     "interfaces": [
#       "br-ex                ovs-interface        172.31.1.218",
#       "br-ex                ovs-bridge                       ",
#       "br-int               ovs-interface                    ",
#       "enp0s31f6            ethernet                         ",
#       "iot-vlan             vlan                             ",
#       "iot-vlan-bridge      linux-bridge                     ",
#       "lo                   loopback             127.0.0.1   ",
#       "ovn-k8s-mp0          ovs-interface        172.30.2.2  ",
#       "patch-br-ex_node0... ovs-interface                    ",
#       "patch-br-int-to-b... ovs-interface                    ",
#       "veth01082403         ethernet                         ",
#       "vethec829156         ethernet                         "
#     ]
#   },
#   {
#     "name": "node07",
#     "interfaces": [
#       "br-ex                ovs-interface        172.31.1.158",
#       "br-ex                ovs-bridge                       ",
#       "br-int               ovs-interface                    ",
#       "enp11s0              ethernet                         ",
#       "enp12s0              ethernet                         ",
#       "iot-vlan             vlan                             ",
#       "iot-vlan-bridge      linux-bridge                     ",
#       "lo                   loopback             127.0.0.1   ",
#       "ovn-k8s-mp0          ovs-interface        172.30.4.2  ",
#       "patch-br-ex_node0... ovs-interface                    ",
#       "patch-br-int-to-b... ovs-interface                    "
#     ]
#   },
#   {
#     "name": "node08",
#     "interfaces": [
#       "br-ex                ovs-interface        172.31.1.215",
#       "br-ex                ovs-bridge                       ",
#       "br-int               ovs-interface                    ",
#       "enp1s0f0             ethernet                         ",
#       "iot-vlan             vlan                             ",
#       "iot-vlan-bridge      linux-bridge                     ",
#       "lo                   loopback             127.0.0.1   ",
#       "ovn-k8s-mp0          ovs-interface        172.30.14.2 ",
#       "patch-br-ex_node0... ovs-interface                    ",
#       "patch-br-int-to-b... ovs-interface                    "
#     ]
#   }
# ]

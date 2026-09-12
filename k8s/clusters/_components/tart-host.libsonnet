// Wake-on-LAN/Redfish/IntelManageabilityいずれのpower backendでも共通するTartHostの骨格。
// powerには`{backend: '...', wakeOnLAN: {...}}`のようなPowerSpec相当のオブジェクトをそのまま渡す。
function(name, macAddress, talosAPIAddress, labels, power, architecture='amd64') {
  apiVersion: 'infrastructure.cluster.x-k8s.io/v1alpha1',
  kind: 'TartHost',
  metadata: {
    name: name,
    labels: labels,
  },
  spec: {
    macAddress: macAddress,
    talosAPIAddress: talosAPIAddress,
    architecture: architecture,
    power: power,
  },
}

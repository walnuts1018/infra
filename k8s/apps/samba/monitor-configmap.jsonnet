local app = import 'app.json5';
{
  apiVersion: 'v1',
  kind: 'ConfigMap',
  metadata: {
    name: 'samba-monitor',
    namespace: app.namespace,
  },
  data: {
    'samba-entrypoint.sh': importstr 'samba-entrypoint.sh',
    'probe.sh': importstr 'probe.sh',
  },
}

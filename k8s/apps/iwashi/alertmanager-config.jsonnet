local app = import 'app.json5';
{
  apiVersion: 'v1',
  kind: 'ConfigMap',
  metadata: { name: app.name + '-alertmanager', namespace: app.namespace },
  data: {
    'alertmanager.yaml': |||
      route:
        receiver: email
        group_by: [organization_id, monitor_id, alertname]
        group_wait: 30s
        group_interval: 5m
        repeat_interval: 4h
      receivers:
        - name: email
          email_configs:
            - to: '{{ .CommonLabels.notification_email }}'
              from: 'iwashi@walnuts.dev'
              smarthost: 'smtp.resend.com:587'
              auth_username: 'resend'
              auth_password_file: '/etc/iwashi-secrets/SMTP_PASSWORD'
              require_tls: true
              send_resolved: true
    |||,
  },
}

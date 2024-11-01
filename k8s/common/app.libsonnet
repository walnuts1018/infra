{
  appname: error 'appname must be defined',
  namespace: 'default',
  labels: {
    app: $.appname,
    'app.kubernetes.io/name': $.appname,
  },
}

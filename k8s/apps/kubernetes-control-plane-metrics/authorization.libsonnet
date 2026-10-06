local app = import 'app.json5';
{
  type: 'Bearer',
  credentials: {
    name: app.name + '-scrape-token',
    key: 'token',
  },
}

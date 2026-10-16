local app = import 'app.json5';
local prices = importstr './_configs/gemini-model-prices.json';

(import '../../components/configmap.libsonnet') {
  name: app.name + '-gemini-model-prices',
  namespace: app.namespace,
  use_suffix: false,
  data: {
    GEMINI_MODEL_PRICES: prices,
  },
}

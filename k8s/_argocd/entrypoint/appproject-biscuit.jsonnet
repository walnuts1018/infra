local project = import '../argocd_components/appproject-biscuit.jsonnet';
project { metadata+: { annotations+: { 'argocd.argoproj.io/sync-wave': '-10' } } }

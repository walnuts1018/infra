local project = import '../argocd_components/appproject-berry.jsonnet';
project { metadata+: { annotations+: { 'argocd.argoproj.io/sync-wave': '-10' } } }

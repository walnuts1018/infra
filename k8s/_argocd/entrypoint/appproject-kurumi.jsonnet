local project = import '../argocd_components/appproject-kurumi.jsonnet';
project { metadata+: { annotations+: { 'argocd.argoproj.io/sync-wave': '-10' } } }

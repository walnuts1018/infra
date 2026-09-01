// VersaTiles configのConfigMap名だけを定義する非manifestヘルパー。
// このConfigMap自体はjsonnet(ArgoCD管理)ではなくupdate-cronjob.jsonnetが
// kubectl applyで都度書き込む(presigned URLを含む動的な内容のため、
// selfHeal:trueなArgoCD管理下に置くと直後に元へ巻き戻されてしまう)。
{
  name: (import 'app.json5').name + '-versatiles-config',
}

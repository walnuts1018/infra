
locals {
  org_id = "237477062321897835"
}

import {
  to = module.zitadel.zitadel_org.ZITADEL
  id = "237477062321897835"
}

import {
  to = module.zitadel.zitadel_organization_domain.walnuts_dev
  id = "walnuts.dev:237477062321897835"
}

import {
  to = module.zitadel.zitadel_organization_domain.kmc_gr_jp
  id = "kmc.gr.jp:237477062321897835"
}

import {
  to = module.zitadel.zitadel_idp_google.google
  id = "260968596954415251"
}

import {
  to = module.zitadel.zitadel_org_idp_github.github
  id = "240667268147577736:237477062321897835"
}

import {
  to = module.zitadel.zitadel_project.openchokin
  id = "325476305464197242:237477062321897835"
}

import {
  to = module.zitadel.zitadel_project.ipu_oauth2_proxy
  id = "326185042176901521:237477062321897835"
}

import {
  to = module.zitadel.zitadel_project.aerial
  id = "333339106471837764:237477062321897835"
}

import {
  to = module.zitadel.zitadel_project.ipxe_manager
  id = "336650775264493758:237477062321897835"
}

import {
  to = module.zitadel.zitadel_project.minio_biscuit
  id = "340410924558975368:237477062321897835"
}

import {
  to = module.zitadel.zitadel_project.httpdump
  id = "341715548272329202:237477062321897835"
}

import {
  to = module.zitadel.zitadel_project.terrakube
  id = "349881613179420909:237477062321897835"
}

import {
  to = module.zitadel.zitadel_project.aws
  id = "354022115113959482:237477062321897835"
}

import {
  to = module.zitadel.zitadel_project.walnuts_dev
  id = "237477822715658605:237477062321897835"
}

import {
  to = module.zitadel.zitadel_project.terraform_cloud
  id = "354047244682396117:237477062321897835"
}

import {
  to = module.zitadel.zitadel_project.pomerium
  id = "356681781363081691:237477062321897835"
}

import {
  to = module.zitadel.zitadel_project.stalwart
  id = "360384713841443019:237477062321897835"
}

import {
  to = module.zitadel.zitadel_project.thermohygrometer
  id = "375241036420612774:237477062321897835"
}

import {
  to = module.zitadel.zitadel_project_role.ipu_viewer
  id = "viewer:326185042176901521:237477062321897835"
}

import {
  to = module.zitadel.zitadel_project_role.minio_biscuit_console_admin
  id = "minio-consoleAdmin:340410924558975368:237477062321897835"
}

import {
  to = module.zitadel.zitadel_project_role.terrakube_admin
  id = "admin:349881613179420909:237477062321897835"
}

import {
  to = module.zitadel.zitadel_project_role.walnuts_dev_admin
  id = "admin:237477822715658605:237477062321897835"
}

import {
  to = module.zitadel.zitadel_project_role.walnuts_dev_nextcloud_admin
  id = "nextcloud-admin:237477822715658605:237477062321897835"
}

import {
  to = module.zitadel.zitadel_project_role.walnuts_dev_longhorn_admin
  id = "longhorn-admin:237477822715658605:237477062321897835"
}

import {
  to = module.zitadel.zitadel_project_role.walnuts_dev_victoria_metrics
  id = "victoria-metrics:237477822715658605:237477062321897835"
}

import {
  to = module.zitadel.zitadel_project_role.walnuts_dev_sweets_rebellion
  id = "sweets-rebellion:237477822715658605:237477062321897835"
}

import {
  to = module.zitadel.zitadel_project_role.walnuts_dev_nextcloud_pro
  id = "nextcloud-pro:237477822715658605:237477062321897835"
}

import {
  to = module.zitadel.zitadel_project_role.walnuts_dev_oekaki_admin
  id = "oekaki-admin:237477822715658605:237477062321897835"
}

import {
  to = module.zitadel.zitadel_project_role.walnuts_dev_hedgedoc_user
  id = "hedgedoc-user:237477822715658605:237477062321897835"
}

import {
  to = module.zitadel.zitadel_project_role.walnuts_dev_dashy
  id = "dashy:237477822715658605:237477062321897835"
}

import {
  to = module.zitadel.zitadel_project_role.walnuts_dev_grafana_editor
  id = "grafana-editor:237477822715658605:237477062321897835"
}

import {
  to = module.zitadel.zitadel_project_role.walnuts_dev_grafana_viewer
  id = "grafana-viewer:237477822715658605:237477062321897835"
}

import {
  to = module.zitadel.zitadel_project_role.walnuts_dev_kibana_admin
  id = "kibana-admin:237477822715658605:237477062321897835"
}

import {
  to = module.zitadel.zitadel_project_role.walnuts_dev_zalando_admin
  id = "zalando-admin:237477822715658605:237477062321897835"
}

import {
  to = module.zitadel.zitadel_project_role.walnuts_dev_ac_hacking_admin
  id = "ac-hacking-admin:237477822715658605:237477062321897835"
}

import {
  to = module.zitadel.zitadel_project_role.walnuts_dev_archivebox
  id = "archivebox:237477822715658605:237477062321897835"
}

import {
  to = module.zitadel.zitadel_project_role.walnuts_dev_prometheus_admin
  id = "prometheus-admin:237477822715658605:237477062321897835"
}

import {
  to = module.zitadel.zitadel_project_role.walnuts_dev_minio_console_admin
  id = "minio-consoleAdmin:237477822715658605:237477062321897835"
}

import {
  to = module.zitadel.zitadel_project_role.walnuts_dev_hubble_admin
  id = "hubble-admin:237477822715658605:237477062321897835"
}

import {
  to = module.zitadel.zitadel_project_role.walnuts_dev_argocd_admin
  id = "argocd-admin:237477822715658605:237477062321897835"
}

import {
  to = module.zitadel.zitadel_project_role.walnuts_dev_openclarity_admin
  id = "openclarity-admin:237477822715658605:237477062321897835"
}

import {
  to = module.zitadel.zitadel_project_role.walnuts_dev_teddy_admin
  id = "teddy-admin:237477822715658605:237477062321897835"
}

import {
  to = module.zitadel.zitadel_project_role.walnuts_dev_teddy_ryokohbato
  id = "teddy-ryokohbato:237477822715658605:237477062321897835"
}

import {
  to = module.zitadel.zitadel_project_role.walnuts_dev_teddy_segre
  id = "teddy-segre:237477822715658605:237477062321897835"
}

import {
  to = module.zitadel.zitadel_project_role.walnuts_dev_teddy_crash
  id = "teddy-crash:237477822715658605:237477062321897835"
}

import {
  to = module.zitadel.zitadel_project_role.walnuts_dev_teddy_akikaze
  id = "teddy-akikaze:237477822715658605:237477062321897835"
}

import {
  to = module.zitadel.zitadel_project_role.walnuts_dev_teddy_cicada
  id = "teddy-cicada:237477822715658605:237477062321897835"
}

import {
  to = module.zitadel.zitadel_project_role.walnuts_dev_warrior
  id = "warrior:237477822715658605:237477062321897835"
}

import {
  to = module.zitadel.zitadel_project_role.walnuts_dev_adguard_admin
  id = "adguard-admin:237477822715658605:237477062321897835"
}

import {
  to = module.zitadel.zitadel_project_role.walnuts_dev_argocd_viewer
  id = "argocd-viewer:237477822715658605:237477062321897835"
}

import {
  to = module.zitadel.zitadel_project_role.pomerium_longhorn_admin
  id = "longhorn-admin:356681781363081691:237477062321897835"
}

import {
  to = module.zitadel.zitadel_project_role.pomerium_warrior_user
  id = "warrior-user:356681781363081691:237477062321897835"
}

import {
  to = module.zitadel.zitadel_project_role.pomerium_hubble_user
  id = "hubble-user:356681781363081691:237477062321897835"
}

import {
  to = module.zitadel.zitadel_project_role.pomerium_prometheus_user
  id = "prometheus-user:356681781363081691:237477062321897835"
}

import {
  to = module.zitadel.zitadel_project_role.pomerium_oekaki_admin
  id = "oekaki-admin:356681781363081691:237477062321897835"
}

import {
  to = module.zitadel.zitadel_project_role.thermohygrometer_read
  id = "thermohygrometer.read:375241036420612774:237477062321897835"
}

import {
  to = module.zitadel.zitadel_project_member.walnuts_dev_zitadel_admin
  id = "237477062321963371:237477822715658605:237477062321897835"
}

import {
  to = module.zitadel.zitadel_application_oidc.walnuts_dev_komga
  id = "279063228187672839:237477822715658605:237477062321897835"
}

import {
  to = module.zitadel.zitadel_application_oidc.walnuts_dev_longhorn
  id = "237478017381695853:237477822715658605:237477062321897835"
}

import {
  to = module.zitadel.zitadel_application_oidc.walnuts_dev_teddy
  id = "312272470495199412:237477822715658605:237477062321897835"
}

import {
  to = module.zitadel.zitadel_application_oidc.walnuts_dev_test
  id = "307695520292274188:237477822715658605:237477062321897835"
}

import {
  to = module.zitadel.zitadel_application_oidc.walnuts_dev_openclarity
  id = "304079079714324766:237477822715658605:237477062321897835"
}

import {
  to = module.zitadel.zitadel_application_oidc.walnuts_dev_openchokin_legacy
  id = "238653199337128329:237477822715658605:237477062321897835"
}

import {
  to = module.zitadel.zitadel_application_oidc.walnuts_dev_warrior
  id = "321616293079810231:237477822715658605:237477062321897835"
}

import {
  to = module.zitadel.zitadel_application_oidc.walnuts_dev_adguard
  id = "322893443263103283:237477822715658605:237477062321897835"
}

import {
  to = module.zitadel.zitadel_application_oidc.walnuts_dev_jmw
  id = "324765291663851642:237477822715658605:237477062321897835"
}

import {
  to = module.zitadel.zitadel_application_oidc.walnuts_dev_argocd
  id = "296595833422348756:237477822715658605:237477062321897835"
}

import {
  to = module.zitadel.zitadel_application_oidc.openchokin_frontend
  id = "325476373009268858:325476305464197242:237477062321897835"
}

import {
  to = module.zitadel.zitadel_application_oidc.ipu_oauth2_proxy_app
  id = "326185123647062417:326185042176901521:237477062321897835"
}

import {
  to = module.zitadel.zitadel_application_oidc.ipxe_manager_front
  id = "336658504880226460:336650775264493758:237477062321897835"
}

import {
  to = module.zitadel.zitadel_application_oidc.httpdump_envoy
  id = "341715627427234290:341715548272329202:237477062321897835"
}

import {
  to = module.zitadel.zitadel_application_oidc.terrakube_ui
  id = "349881633530184098:349881613179420909:237477062321897835"
}

import {
  to = module.zitadel.zitadel_application_oidc.pomerium_app
  id = "356681904340074971:356681781363081691:237477062321897835"
}

import {
  to = module.zitadel.zitadel_application_api.openchokin_backend
  id = "325476408660852806:325476305464197242:237477062321897835"
}

import {
  to = module.zitadel.zitadel_application_api.aerial_api_server
  id = "333339441898717252:333339106471837764:237477062321897835"
}

import {
  to = module.zitadel.zitadel_application_api.ipxe_manager_api_server
  id = "336650899332006083:336650775264493758:237477062321897835"
}

import {
  to = module.zitadel.zitadel_application_saml.terraform_cloud_app
  id = "354047473087414330:354047244682396117:237477062321897835"
}

import {
  to = module.zitadel.zitadel_application_saml.aws_iam_identity_center
  id = "354022169019155440:354022115113959482:237477062321897835"
}

import {
  to = module.zitadel.zitadel_human_user.zitadel_admin
  id = "237477062321963371:237477062321897835"
}

import {
  to = module.zitadel.zitadel_human_user.test
  id = "240249362981061512:237477062321897835"
}

import {
  to = module.zitadel.zitadel_machine_user.terraform
  id = "293475111627915658:237477062321897835"
}

import {
  to = module.zitadel.zitadel_machine_user.thermohygrometer_exporter
  id = "375322474050486927:237477062321897835"
}

import {
  to = module.zitadel.zitadel_machine_user.kurumi
  id = "353148243216957761:237477062321897835"
}

import {
  to = module.zitadel.zitadel_machine_key.terraform
  id = "354043749568873456:293475111627915658:237477062321897835"
}

import {
  to = module.zitadel.zitadel_machine_key.thermohygrometer_exporter
  id = "375331462108414607:375322474050486927:237477062321897835"
}

import {
  to = module.zitadel.zitadel_org_member.zitadel_admin
  id = "237477062321897835:237477062321963371"
}

import {
  to = module.zitadel.zitadel_org_member.walnuts
  id = "237477062321897835:237477703714865517"
}

import {
  to = module.zitadel.zitadel_instance_member.zitadel_admin
  id = "237477062321963371"
}

import {
  to = module.zitadel.zitadel_instance_member.walnuts
  id = "237477703714865517"
}

import {
  to = module.zitadel.zitadel_instance_member.terraform
  id = "293475111627915658"
}

import {
  to = module.zitadel.zitadel_action.flat_roles
  id = "240247921298113416:237477062321897835"
}

import {
  to = module.zitadel.zitadel_action.flat_minio_roles
  id = "276087763395150247:237477062321897835"
}

import {
  to = module.zitadel.zitadel_login_policy.default
  id = "237477062321897835"
}

import {
  to = module.zitadel.zitadel_password_complexity_policy.default
  id = "237477062321897835"
}

import {
  to = module.zitadel.zitadel_user_grant.walnuts_ipu_viewer
  id = "326185291100455344:237477703714865517:237477062321897835"
}

import {
  to = module.zitadel.zitadel_user_grant.walnuts_minio_biscuit_console_admin
  id = "340418828674531565:237477703714865517:237477062321897835"
}

import {
  to = module.zitadel.zitadel_user_grant.walnuts_terrakube_admin
  id = "349974042268139674:237477703714865517:237477062321897835"
}

import {
  to = module.zitadel.zitadel_user_grant.zitadel_admin_walnuts_dev_admin
  id = "237478436040343917:237477062321963371:237477062321897835"
}

import {
  to = module.zitadel.zitadel_user_grant.rh_98_walnuts_dev
  id = "238838888255193481:238838777223577993:237477062321897835"
}

import {
  to = module.zitadel.zitadel_user_grant.latticeheart_walnuts_dev
  id = "239471785458794931:239374746813202867:237477062321897835"
}

import {
  to = module.zitadel.zitadel_user_grant.walnuts_walnuts_dev
  id = "237911216641540467:237477703714865517:237477062321897835"
}

import {
  to = module.zitadel.zitadel_user_grant.tawara_ryota_walnuts_dev
  id = "352146402584822613:352141163228037441:237477062321897835"
}

import {
  to = module.zitadel.zitadel_user_grant.junya_walnuts_dev
  id = "352146128478667073:352145707823530837:237477062321897835"
}

import {
  to = module.zitadel.zitadel_user_grant.walnuts_pomerium
  id = "356685865994420699:237477703714865517:237477062321897835"
}

import {
  to = module.zitadel.zitadel_user_grant.thermohygrometer_exporter_grant
  id = "375322491465237135:375322474050486927:237477062321897835"
}

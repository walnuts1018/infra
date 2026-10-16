// {
//   apiVersion: 'networking.k8s.io/v1',
//   kind: 'NetworkPolicy',
//   metadata: {
//     name: 'victoria-metrics-vminsert-egress',
//     namespace: 'victoria-metrics',
//   },
//   spec: {
//     podSelector: {
//       matchLabels: {
//         app: 'vminsert',
//         'app.kubernetes.io/instance': 'victoria-metrics',
//         'app.kubernetes.io/name': 'victoria-metrics-cluster',
//       },
//     },
//     policyTypes: [
//       'Egress',
//     ],
//     egress: [
//       {
//         to: [
//           {
//             namespaceSelector: {
//               matchLabels: {
//                 'kubernetes.io/metadata.name': 'kube-system',
//               },
//             },
//             podSelector: {
//               matchLabels: {
//                 'k8s-app': 'kube-dns',
//               },
//             },
//           },
//         ],
//         ports: [
//           {
//             protocol: 'UDP',
//             port: 53,
//           },
//           {
//             protocol: 'TCP',
//             port: 53,
//           },
//         ],
//       },
//       {
//         to: [
//           {
//             podSelector: {
//               matchLabels: {
//                 app: 'vmstorage',
//                 'app.kubernetes.io/instance': 'victoria-metrics',
//                 'app.kubernetes.io/name': 'victoria-metrics-cluster',
//               },
//             },
//           },
//         ],
//         ports: [
//           {
//             protocol: 'TCP',
//             port: 8400,
//           },
//         ],
//       },
//     ],
//   },
// }

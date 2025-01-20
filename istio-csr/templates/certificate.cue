package templates

import (
  certmanager "cert-manager.io/certificate/v1"
  "list"
  "net"
)

#Certificate: certmanager.#Certificate & {
  #config: #Config
  #dnsNames: [...net.FQDN] & { list.FlattenN([
    if list.Contains(#config.app.istio.revisions, "default") {
      ["istiod.\(#config.app.istio.namespace).svc"],
    }
    [
      for revision in #config.app.istio.revisions
      if revision != "default" {
        "istiod-\(revision).\(#config.app.istio.namespace).svc",
      }
    ],
    if #config.app.tls.istiodAdditionalDNSNames != _|_ {
      #config.app.tls.istiodAdditionalDNSNames,
    }
  ], -1)}
  metadata: #config.metadata
  spec: certmanager.#CertificateSpec & {
    commonName: net.FQDN & "istiod.\(#config.app.istio.namespace).svc"
    dnsNames: #dnsNames
    uris: [
    "spiffe://\(#config.app.tls.trustDomain)/ns/\(#config.app.istio.namespace)/sa/istiod-service-account",
    ]
    secretName: "istiod-tls"
    duration: #config.app.tls.istiodCertificateDuration
    renewBefore: #config.app.tls.istiodCertificateRenewBefore
    privateKey: {
      rotationPolicy: "Always"
      algorithm: #config.app.tls.istiodPrivateKeyAlgorithm
      size: #config.app.tls.istiodPrivateKeySize
    }
    revisionHistoryLimit: 1
    issuerRef: {
      name: #config.app.certmanager.issuer.name
      kind: #config.app.certmanager.issuer.kind
      group: #config.app.certmanager.issuer.group
    }
  }
}

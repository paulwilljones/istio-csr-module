package templates

import (
  certmanager "cert-manager.io/certificate/v1"
  issuer "cert-manager.io/issuer/v1"
  corev1 "k8s.io/api/core/v1"
)

#IstioNamespace: corev1.#Namespace & {
    metadata: name: "istio-system"
    apiVersion: "v1"
	kind:       "Namespace"
}

#SelfSignedIssuer: issuer.#Issuer & {
    #config: #Config
    metadata: name: "selfsigned"
    metadata: namespace: #config.app.istio.namespace
    spec: issuer.#IssuerSpec & {
        selfSigned: {}
    }
}

#IstioCACert: certmanager.#Certificate & {
    #config: #Config
    metadata: name: "istio-ca"
    metadata: namespace: #config.app.istio.namespace
    spec: certmanager.#CertificateSpec & {
        isCA: true
        duration: "87600h"
        secretName: "istio-ca"
        commonName: "istio-ca"
        privateKey: {
            algorithm: "ECDSA"
            size: 256
        }
        subject: {
            organizations: [
                "cluster.local",
                "cert-manager"
            ]
        }
        issuerRef: {
            name: "selfsigned"
            kind: "Issuer"
            group: "cert-manager.io"
        }
    }
}

#IstioCAIssuer: issuer.#Issuer & {
    #config: #Config
    metadata: name: "istio-ca"
    metadata: namespace: #config.app.istio.namespace
    spec: issuer.#IssuerSpec & {
        ca: {
            secretName: "istio-ca"
        }
    }
}

#IstioRootCA: corev1.#Secret & {
    #config: #Config
    metadata: name: "istio-root-ca"
    metadata: namespace: #config.metadata.namespace
    apiVersion: "v1"
	kind:       "Secret"
    stringData: "ca.pem": #config.app.tls.istioRootCA
}

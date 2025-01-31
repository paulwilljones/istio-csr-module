bundle: {
	apiVersion: "v1alpha1"
	name:       "istio-csr"
	instances: {
		"cert-manager": {
			module: {
				url:     "oci://ghcr.io/nalum/timoni/modules/cert-manager"
				version: "1.14.5-0"
			}
			namespace: "cert-manager"
			values: {
				highAvailability: enabled: true

                controller: {
                    config: logging: format: "json"
                    podDisruptionBudget: minAvailable: 2

                    monitoring: {
                        enabled: true
                    }

                    image: {
                        tag:    "v1.14.0"
                        digest: "sha256:2547fde4e736101abf33f8c2503f12aa3a0b42614d3d64cfecf2835c0ee81c10"
                    }
                }

                webhook: {
                    podDisruptionBudget: minAvailable: 3
                }
            }
		}
		"cert-manager-istio-csr": {
			module: {
				//url:     "oci://ghcr.io/paulwilljones/modules/istio-csr"
				//version: "6.5.3"
				url: "file://istio-csr/"
			}
			namespace: "cert-manager"
			values: {
				createSelfSignedCA: true
				app: certmanager: issuer: enabled: false
				app: certmanager: issuer: name: ""
				app: certmanager: issuer: kind: ""
				app: certmanager: issuer: group: ""
				app: tls: istiodCertificateEnable: "dynamic"
				app: runtimeConfiguration: create: true
				app: runtimeConfiguration: name: "istio-issuer"
				app: runtimeConfiguration: issuer: name: "istio-ca"
				app: runtimeConfiguration: issuer: kind: "Issuer"
				app: runtimeConfiguration: issuer: group: "cert-manager.io"
			}
		}
	}
}

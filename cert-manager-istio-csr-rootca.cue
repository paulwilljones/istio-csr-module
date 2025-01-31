bundle: {
	apiVersion: "v1alpha1"
	name:       "istio-csr"
	instances: {
		"cert-manager-istio-csr": {
			module: {
				//url:     "oci://ghcr.io/paulwilljones/modules/istio-csr"
				//version: "6.5.3"
				url: "file://istio-csr/"
			}
			namespace: "cert-manager"
			values: {
				createSelfSignedCA: false
				app: tls: rootCAFile: "/var/run/secrets/istio-csr/ca.pem"
				app: certmanager: {
					issuer: {
						name: "istio-ca"
						kind: "Issuer"
						group: "cert-manager.io"
					}
				}
				app: tls: istioRootCA: "" @timoni(runtime:string:ISTIO_CA)
				volumeMounts: [{
					name: "root-ca"
					mountPath: "/var/run/secrets/istio-csr"
				}]
				volumes: [{
					name: "root-ca"
					secret: secretName: "istio-root-ca"
				}]
			}
		}
	}
}

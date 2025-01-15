package templates

import (
	appsv1 "k8s.io/api/apps/v1"
	corev1 "k8s.io/api/core/v1"
	"strings"
)

#Deployment: appsv1.#Deployment & {
	#config:    #Config
	apiVersion: "apps/v1"
	kind:       "Deployment"
	metadata:   #config.metadata
	spec: appsv1.#DeploymentSpec & {
		replicas: #config.replicas
		selector: matchLabels: #config.selector.labels
		template: corev1.#PodTemplateSpec & {
			metadata: {
				labels: #config.selector.labels
				if #config.podAnnotations != _|_ {
					annotations: #config.podAnnotations
				}
			}
			spec: corev1.#PodSpec & {
			if #config.imagePullSecrets != _|_ {
				imagePullSecrets: #config.imagePullSecrets
			}
			serviceAccountName: #config.metadata.name
			if #config.podSecurityContext != _|_ {
				securityContext: #config.podSecurityContext
			}
			if #config.topologySpreadConstraints != _|_ {
				topologySpreadConstraints: #config.topologySpreadConstraints
			}
			if #config.affinity != _|_ {
				affinity: #config.affinity
			}
			if #config.tolerations != _|_ {
				tolerations: #config.tolerations
			}
			if #config.nodeSelector != _|_ {
				nodeSelector: #config.nodeSelector
			}
			if #config.volumes != _|_ {
				volumes: #config.volumes
			}
				containers: [...corev1.#Container] & [
					{
						name:            #config.metadata.name
						image:           #config.image.reference
						imagePullPolicy: #config.image.pullPolicy
						ports: [...corev1.#ContainerPort] & [
							{
								containerPort: #config.app.server.serving.port
							},
							{
								containerPort: #config.app.metrics.port
							}
						]
						readinessProbe:  {
							httpGet: {
								path: #config.app.readinessProbe.path
								port: #config.app.readinessProbe.port
							}
							initialDelaySeconds: 3
          					periodSeconds: 7
						}
						args: [...string] & [
							"--log-level=\(#config.app.logLevel)",
							"--log-format=\(#config.app.logFormat)",
							"--metrics-port=\(#config.app.metrics.port)",
							"--readiness-probe-port=\(#config.app.readinessProbe.port)",
							"--readiness-probe-path=\(#config.app.readinessProbe.path)",

							// cert-manager
							"--certificate-namespace=\(#config.app.certmanager.namespace)",
							"--issuer-enabled=\(#config.app.certmanager.issuer.enabled)",
							"--issuer-name=\(#config.app.certmanager.issuer.name)",
							"--issuer-kind=\(#config.app.certmanager.issuer.kind)",
							"--issuer-group=\(#config.app.certmanager.issuer.group)",
							"--preserve-certificate-requests=\(#config.app.certmanager.preserveCertificateRequests)",
							
							// AdditionalAnnotations
						if #config.app.certmanager.additionalAnnotations != _|_ {
							// TODO better list comprehension
							#annotations: [for k,v in #config.app.certmanager.additionalAnnotations {k+"="+v}]
							"--certificate-request-additional-annotations=\(strings.Join(#annotations, ","))",
						}

							// tls
							"--root-ca-file=\(#config.app.tls.rootCAFile)",
							for dnsName in #config.app.tls.certificateDNSNames { "--serving-certificate-dns-names=\(dnsName)", }
							"--serving-certificate-duration=\(#config.app.tls.certificateDuration)",
							"--trust-domain=\(#config.app.tls.trustDomain)",

							// server
							"--cluster-id=\(#config.app.server.clusterID)",
							"--max-client-certificate-duration=\(#config.app.server.maxCertificateDuration)",
							"--serving-address=\(#config.app.server.serving.address):\(#config.app.server.serving.port)",
							"--serving-certificate-key-size=\(#config.app.server.serving.certificateKeySize)",
							"--serving-signature-algorithm=\(#config.app.server.serving.signatureAlgorithm)",

							// server authenticators
							"--enable-client-cert-authenticator=\(#config.app.server.authenticators.enableClientCert)",

							// trusted node accounts
						if #config.app.server.caTrustedNodeAccounts != _|_ {
							"--ca-trusted-node-accounts=\(#config.app.server.caTrustedNodeAccounts)",
						}
							// controller
							"--leader-election-namespace=\(#config.app.controller.leaderElectionNamespace)",

						if #config.app.controller.configmapNamespaceSelector != _|_ {
							"--configmap-namespace-selector=\(#config.app.controller.configmapNamespaceSelector)",
						}
							"--disable-kubernetes-client-rate-limiter=\(#config.app.controller.disableKubernetesClientRateLimiter)",

							"--runtime-issuance-config-map-name=\(#config.app.runtimeConfiguration.name)",
							"--runtime-issuance-config-map-namespace=\(#config.metadata.namespace)",
					
							// dynamic istiod cert
							"--istiod-cert-enabled=\(#config.app.tls.istiodCertificateEnable)",
							"--istiod-cert-name=istiod-dynamic",
							"--istiod-cert-namespace=\(#config.app.istio.namespace)",
							"--istiod-cert-duration=\(#config.app.tls.istiodCertificateDuration)",
							"--istiod-cert-renew-before=\(#config.app.tls.istiodCertificateRenewBefore)",
							"--istiod-cert-key-algorithm=\(#config.app.tls.istiodPrivateKeyAlgorithm)",
							"--istiod-cert-key-size=\(#config.app.tls.istiodPrivateKeySize)",
							"--istiod-cert-additional-dns-names=\(strings.Join(#config.app.tls.istiodAdditionalDNSNames, ","))",
						if #config.app.certmanager.additionalAnnotations != _|_ {
							// TODO better list comprehension
							#annotations: [for k,v in #config.app.certmanager.additionalAnnotations {k+"="+v}]
							"--istiod-cert-additional-annotations=\(strings.Join(#annotations, ","))",
						}
							"--istiod-cert-istio-revisions=\(strings.Join(#config.app.istio.revisions, ","))"
						]
					if #config.volumeMounts != _|_ {
						volumeMounts: #config.volumeMounts
					}
						resources: #config.resources
						securityContext: #config.securityContext
					}
				]
			}
		}
	}
}

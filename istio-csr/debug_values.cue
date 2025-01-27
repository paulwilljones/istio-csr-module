@if(debug)

package main

// Values used by debug_tool.cue.
// Debug example 'cue cmd -t debug -t name=test -t namespace=test -t mv=1.0.0 -t kv=1.28.0 build'.
values: {
	image: {
		repository: "quay.io/jetstack/cert-manager-istio-csr"
		digest:     "sha256:1f761380cd12767e0cbe0840bb829d4c530635e15eead11ff217fc3a6d1d05d2"
		tag:        "0.13.0"
	}
	moduleVersion: "0.0.0-devel"
	test: {
		enabled: true
	}
	replicas: 2
	resources: limits: {
		cpu: "20m"
		memory: "64Mi"
	}
	resources: requests: {
		cpu: "10m"
		memory: "32Mi"
	}
	securityContext: {
		allowPrivilegeEscalation: true
		readOnlyRootFilesystem: false
		runAsNonRoot: false
		capabilities: {
			add: ["CAP_SYS_ADMIN"]
		} 
	}
	service: {
		type: "NodePort"
		port: 6443
		nodePort: 30001
	}
	volumes: [{
		name: "myvol"
	}]
	volumeMounts: [{
		name: "myvolmount"
		mountPath: "/etc/something"
	}]
	app: {
		logLevel: 5
		logFormat: "json"
		metrics: {
			port: 9401
			service: {
				type: "NodePort"
				servicemonitor: {
					enabled: true
					prometheusInstance: "prom-operator"
					interval: "30s"
					scrapeTimeout: "10s"
					labels: {"test": "label"}
				}
			}
		}
		server: {
			serving: {
				address: "1.2.3.4"
				certificateKeySize: 256
				signatureAlgorithm: "ECDSA"
				port: 6446
			}
			clusterID: "myCluster"
			maxCertificateDuration: "2h"
			authenticators: {
				enableClientCert: true
			}
			caTrustedNodeAccounts: ["istio-system/ztunnel", "istio-system/mysa"]
		}
		istio: {
			namespace: "default"
			revisions: ["1-9-5"]
		}
		controller: {
			leaderElectionNamespace: "cert-manager"
			configmapNamespaceSelector: "maistra.io/member-of=istio-system"
			disableKubernetesClientRateLimiter: true
		}
		tls: {
			rootCAFile: "/var/certs/ca.pem"
			certificateDNSNames: ["istio-csr.cert-manager.svc"]
			certificateDuration: "2h"
			trustDomain: "jetstack.io"
			istiodCertificateEnable: "dynamic"
			istiodCertificateDuration: "3h"
			istiodCertificateRenewBefore: "15m"
			istiodPrivateKeyAlgorithm: "RSA"
			istiodPrivateKeySize: 4096
			istiodAdditionalDNSNames: ["istio.jetstack.io"]
		}
		readinessProbe: {
			port: 6161
			path: "/livez"
		}
		certmanager: {
			additionalAnnotations: {"test": "annotation"}
			namespace: "default"
			preserveCertificateRequests: true
			issuer: {
				name: "self-signed-ca"
				kind: "ClusterIssuer"
				group: "cert-manager.com"
			}
		}
		runtimeConfiguration: {
			name: "myRuntimeConfig"
			issuer:{
				kind: "ClusterIssuer"
				group: "cert-manager.co.uk"
			}
		}
	}
	podLabels: "podLabel": "test"
	podAnnotations: "cluster-autoscaler.kubernetes.io/safe-to-evict": "true"
	podSecurityContext: {
		runAsUser: 65534
		runAsNonRoot: false
		fsGroup: 2000
	}
	imagePullSecrets: [{name: "myimagepullsecret"}]
	tolerations: [{
		key: "example-key"
		operator: "Exists"
		effect: "NoSchedule"
	}]
	affinity: nodeAffinity: requiredDuringSchedulingIgnoredDuringExecution: nodeSelectorTerms: [{
		matchExpressions: [{
			key:      "kubernetes.io/os"
			operator: "In"
			values: ["linux"]
		}]
	}]
	nodeSelector: "disktype": "ssd"
	topologySpreadConstraints: [{
		maxSkew: 1
		topologyKey: "kubernetes.io/hostname"
		whenUnsatisfiable: "DoNotSchedule"
		labelSelector:
			matchLabels:
				"app": "foo"
		matchLabelKeys: ["pod-template-hash"]
	}]
	extraObjects: [{
		metadata: name: "extra-configmap"
		apiVersion: "v1"
		kind: "ConfigMap"
	}, {
		metadata: name: "extra-job"
		apiVersion: "batch/v1"
		kind: "Job"
		spec: {
			template: {
    			spec: {
      				containers: [{
      					name: "pi"
        				image: "perl:5.34.0"
        				command: [
							"perl",
							"-Mbignum=bpi",
							"-wle",
							"print bpi(2000)",
						]
					}]
					restartPolicy: "Never"
				}
			}
			backoffLimit: 4
		}
	}]
	createSelfSignedCA: true
}

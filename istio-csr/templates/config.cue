package templates

import (
	corev1 "k8s.io/api/core/v1"
	timoniv1 "timoni.sh/core/v1alpha1"
	"net"
)

#Duration: string & =~"^[+-]?((\\d+h)?(\\d+m)?(\\d+s)?(\\d+ms)?(\\d+(us|µs))?(\\d+ns)?)$"

// Config defines the schema and defaults for the Instance values.
#Config: {
	// The kubeVersion is a required field, set at apply-time
	// via timoni.cue by querying the user's Kubernetes API.
	kubeVersion!: string
	// Using the kubeVersion you can enforce a minimum Kubernetes minor version.
	// By default, the minimum Kubernetes version is set to 1.20.
	clusterVersion: timoniv1.#SemVer & {#Version: kubeVersion, #Minimum: "1.20.0"}

	// The moduleVersion is set from the user-supplied module version.
	// This field is used for the `app.kubernetes.io/version` label.
	moduleVersion!: string

	// The Kubernetes metadata common to all resources.
	// The `metadata.name` and `metadata.namespace` fields are
	// set from the user-supplied instance name and namespace.
	metadata: timoniv1.#Metadata & {#Version: moduleVersion}

	// The labels allows adding `metadata.labels` to all resources.
	// The `app.kubernetes.io/name` and `app.kubernetes.io/version` labels
	// are automatically generated and can't be overwritten.
	metadata: labels: timoniv1.#Labels

	// // The annotations allows adding `metadata.annotations` to all resources.
	metadata: annotations?: timoniv1.#Annotations

	// The selector allows adding label selectors to Deployments and Services.
	// The `app.kubernetes.io/name` label selector is automatically generated
	// from the instance name and can't be overwritten.
	selector: timoniv1.#Selector & {#Name: metadata.name}

	// The image allows setting the container image repository,
	// tag, digest and pull policy.
	// The default image repository and tag is set in `values.cue`.
	image: timoniv1.#Image & {
		repository: "quay.io/jetstack/cert-manager-istio-csr"
		digest:     "sha256:1f761380cd12767e0cbe0840bb829d4c530635e15eead11ff217fc3a6d1d05d2"
		tag:        "0.13.0"
		pullPolicy: "IfNotPresent"
	}

	// The resources allows setting the container resource requirements.
	// By default, the container requests 10m CPU and 32Mi memory.
	resources?: timoniv1.#ResourceRequirements

	// The number of pods replicas.
	// By default, the number of replicas is 1.
	replicas: *1 | int & >0

	// The securityContext allows setting the container security context.
	// By default, the container is denied privilege escalation.
	securityContext: corev1.#SecurityContext & {
		allowPrivilegeEscalation: *false | true
		readOnlyRootFilesystem: *true | false
		runAsNonRoot: *true | false
		capabilities: {
			drop: *["ALL"] | [...string]
		}
		//TODO 
		seccompProfile: type: "RuntimeDefault"
	}

	// The service allows setting the Kubernetes Service annotations and port.
	// By default, the HTTPS port is 443.
	service: {
		type: *corev1.#ServiceTypeClusterIP | corev1.#enumServiceType
		port: *443 | int & >0 & <=65535
		nodePort?: int & >30000 & <=32767
	}

	volumes?: [...corev1.#Volume]
	volumeMounts?: [...corev1.#VolumeMount]

	app: {
		logLevel: *1 | int & >=1 & <=5
		logFormat: *"text" | "json"
		metrics: {
			port: *9402 | int & >=1 & <=65535
			service: {
				enabled: *true | false
				type: *corev1.#ServiceTypeClusterIP | corev1.#enumServiceType
				servicemonitor: {
					enabled: *false | true
					prometheusInstance: *"default" | string
					interval: *"10s" | #Duration
					scrapeTimeout: *"5s" | #Duration
					labels: timoniv1.#Labels
				}
			}
		}
		server: {
			serving: {
				address: *"0.0.0.0" | net.IP
				certificateKeySize: *2048 | int
				//certificateKeySize: *2048 | int & if signatureAlgorithm == "RSA" { >= 2048 } else { 256 | 348 }
				signatureAlgorithm: *"RSA" | "ECDSA"
				port: *6443 | int & >0 & <=65535
			}
			clusterID: *"Kubernetes" | string
			maxCertificateDuration: *"1h" | #Duration
			authenticators: {
				enableClientCert: *false | true
			}
			caTrustedNodeAccounts?: [...string]
		}
		istio: {
			namespace: *"istio-system" | string
			revisions: *["default"] | [...string]
		}
		controller: {
			leaderElectionNamespace: *"istio-system" | string
			configmapNamespaceSelector?: string
			disableKubernetesClientRateLimiter: *false | true
		}
		tls: {
			istioRootCA?: string
			rootCAFile: *"" | string
			certificateDNSNames: *["cert-manager-istio-csr.cert-manager.svc"] | [...string]
			certificateDuration: *"1h" | #Duration
			trustDomain: *"cluster.local" | string
			istiodCertificateEnable: *"true" | "dynamic" | "false"
			istiodCertificateDuration: *"1h" | #Duration
			istiodCertificateRenewBefore: *"30m" | #Duration
			istiodPrivateKeyAlgorithm: *app.server.serving.signatureAlgorithm | "RSA" | "ECDSA"
			istiodPrivateKeySize: *2048 | int
			istiodAdditionalDNSNames: *[] | [...string]
		}
		readinessProbe: {
			port: *6060 | int & >0 & <=65535
			path: *"/readyz" | string
		}
		certmanager: {
			additionalAnnotations?: timoniv1.#Annotations
			namespace: *"istio-system" | string
			preserveCertificateRequests: *false | true
			issuer: {
				enabled: *true | false
				name: *"istio-ca" | string
				kind: *"Issuer" | "ClusterIssuer" | ""
				group: *"cert-manager.io" | string
			}
		}
		runtimeConfiguration: {
			create: *false | true
			name: *"" | string
			issuer: {
				name: *"istio-ca" | string
				kind: *"Issuer" | "ClusterIssuer"
				group: *"cert-manager.io" | string
			}
		}
	}

	// Pod optional settings.
	podLabels?: timoniv1.#Labels
	podAnnotations?: timoniv1.#Annotations
	podSecurityContext?: corev1.#PodSecurityContext
	imagePullSecrets?: [...timoniv1.#ObjectReference]
	tolerations?: [...corev1.#Toleration]
	affinity?: corev1.#Affinity
	nodeSelector: timoniv1.#Labels & {"kubernetes.io/os": "linux"}
	topologySpreadConstraints?: [...corev1.#TopologySpreadConstraint]
	extraObjects?: [...]

	test: {
		enabled: *false | bool
	}
	createSelfSignedCA: *false | true
}

// Instance takes the config values and outputs the Kubernetes objects.
#Instance: {
	config: #Config

	objects: {
		if config.createSelfSignedCA == true {
			istioNamespace: #IstioNamespace
			selfSignedIssuer: #SelfSignedIssuer & {#config: config}
			istioCACert: #IstioCACert & {#config: config}
			istioCAIssuer: #IstioCAIssuer & {#config: config}
		}
		if config.app.tls.istioRootCA != _|_ {
			istioRootCA: #IstioRootCA & {#config: config}
		}
		svc: #Service & {#config: config}
		deploy: #Deployment & {#config: config}
		sa: #ServiceAccount & {#config: config}
		clusterrole: #ClusterRole & {#config: config}
		clusterrolebinding: #ClusterRoleBinding & {#config: config}
		role: #Role & {#config: config}
		roleBinding: #RoleBinding & {#config: config}
		roleLeases: #RoleLeases & {#config: config}
		roleBindingLeases: #RoleBindingLeases& {#config: config}
		if config.app.tls.istiodCertificateEnable == "dynamic" {
			roleDynamicCert: #RoleDynamicCert & {#config: config}
		}
		roleBindingDynamicCert: #RoleBindingDynamicCert & {#config: config}
		if config.extraObjects != _|_ {
			for resource in config.extraObjects {
				"\(resource.metadata.name)": resource
			}
		}
		if config.app.tls.istiodCertificateEnable == "true" {
			certificate: #Certificate & {#config: config}	
		}
		if config.app.metrics.service.enabled == true {
			serviceMetrics: #ServiceMetrics & {#config: config}
		}
		if config.app.metrics.service.servicemonitor.enabled == true {
			serviceMonitor: #ServiceMonitor & {#config: config}
		}
		if config.app.runtimeConfiguration.create == true {
			runtimeConfiguration: #RuntimeConfigMap & {#config: config}
		}
	}
	tests: {
		test: #Deployment & {#config: config}
	}
}

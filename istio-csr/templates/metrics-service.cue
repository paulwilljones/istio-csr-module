package templates

import (
	corev1 "k8s.io/api/core/v1"
	timoniv1 "timoni.sh/core/v1alpha1"
)

#ServiceMetrics: corev1.#Service & {
	#config:    #Config
    #meta: timoniv1.#MetaComponent & {
        #Meta: #config.metadata
        #Component: "metrics"
    }
	apiVersion: "v1"
	kind:       "Service"
    metadata: #meta
    metadata: labels: {"app": #meta.name}
	spec: corev1.#ServiceSpec & {
		type: #config.app.metrics.service.type
		selector: {"app": #config.metadata.name}
		ports: [...corev1.#ServicePort] & [
			{
				port:       #config.app.metrics.port
				protocol:   corev1.#ProtocolTCP
				name:       "metrics"
				targetPort: #config.app.metrics.port
			}
		]
	}
}

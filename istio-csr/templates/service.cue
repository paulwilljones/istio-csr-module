package templates

import (
	corev1 "k8s.io/api/core/v1"
)

#Service: corev1.#Service & {
	#config:    #Config
	apiVersion: "v1"
	kind:       "Service"
	metadata:   #config.metadata
	spec: corev1.#ServiceSpec & {
		type:     corev1.#ServiceTypeClusterIP
		selector: #config.selector.labels
		ports: [...corev1.#ServicePort] & [
			{
				port:       #config.service.port
				protocol:   corev1.#ProtocolTCP
				name:       "web"
				targetPort: #config.app.server.serving.port
			if #config.service.nodePort != _|_ {
				nodePort:	#config.service.nodePort
			}
			}
		]
	}
}

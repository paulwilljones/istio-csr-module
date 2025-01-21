package templates

import (
	corev1 "k8s.io/api/core/v1"
)

#Service: corev1.#Service & {
	#config:    #Config
	apiVersion: "v1"
	kind:       "Service"
	metadata:   #config.metadata
	metadata: labels: {"app": #config.metadata.name}
	spec: corev1.#ServiceSpec & {
		type:     #config.service.type
		selector: {"app": #config.metadata.name}
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

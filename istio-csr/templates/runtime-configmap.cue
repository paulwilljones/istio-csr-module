package templates

import (
	corev1 "k8s.io/api/core/v1"
)

#RuntimeConfigMap: corev1.#ConfigMap & {
    #config: #Config
    apiVersion: "v1"
	kind:       "ConfigMap"
    if #config.app.runtimeConfiguration.name != "" {
        metadata: name: #config.app.runtimeConfiguration.name
    }
    if #config.app.runtimeConfiguration.name == "" {
        metadata: name: #config.metadata.name
    }
    metadata: namespace: #config.metadata.namespace
    metadata: labels: #config.metadata.labels
    metadata: labels: {"app": #config.metadata.name}
    data: {
        "issuer-name": #config.app.runtimeConfiguration.issuer.name
        "issuer-kind": #config.app.runtimeConfiguration.issuer.kind
        "issuer-group": #config.app.runtimeConfiguration.issuer.group
    }
}

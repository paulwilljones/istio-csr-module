package templates

import (
    rbacv1 "k8s.io/api/rbac/v1"
)

#ClusterRole: rbacv1.#ClusterRole & {
	#config:     #Config
	apiVersion: "rbac.authorization.k8s.io/v1"
	kind:       "ClusterRole"
	metadata: #config.metadata
    rules: [...rbacv1.#PolicyRule] & [
        {
            apiGroups: [""]
            resources: ["configmaps"]
            verbs: ["get", "list", "create", "update", "watch"]
        }, {
            apiGroups: [""]
            resources: ["namespaces", if #config.app.server.caTrustedNodeAccounts != _|_ {"pods"}]
            verbs: ["get", "list", "watch"]
        }, {
            apiGroups: ["authentication.k8s.io"]
            resources: ["tokenreviews"]
            verbs: ["create"]
        }, {
            if #config.app.tls.istiodCertificateEnable == "dynamic" {
                apiGroups: ["cert-manager.io"]
                resources: ["certificates"]
                verbs: ["list", "get", "watch"]
            }
        }
    ]
}

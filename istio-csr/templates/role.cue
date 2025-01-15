package templates

import (
    rbacv1 "k8s.io/api/rbac/v1"
)

#Role: rbacv1.#Role & {
	#config:     #Config
	apiVersion: "rbac.authorization.k8s.io/v1"
	kind:       "Role"
	metadata: #config.metadata
    rules: [...rbacv1.#PolicyRule] & [
        {
            apiGroups: ["cert-manager.io"]
            resources: ["certificaterequests"]
            verbs: ["get", "list", "create", "update", "delete", "watch"]
        }, {
            apiGroups: [""]
            resources: ["events"]
            verbs: ["create"]
        }, {
            apiGroups: [""]
            resources: ["configmaps"]
            verbs: ["get", "list", "watch"]
            resourceNames: [#config.app.runtimeConfiguration.name]
        }
    ]
}

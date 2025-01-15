package templates

import (
    rbacv1 "k8s.io/api/rbac/v1"
    cfg "timoni.sh/istio-csr/templates/config"
)

#RoleLeases: rbacv1.#Role & {
	#config:     cfg.#Config
	apiVersion: "rbac.authorization.k8s.io/v1"
	kind:       "Role"
	metadata: #config.metadata
    metadata.name: "\(#config.metadata.name)-leases"
    metadata: namespace: #config.app.controller.leaderElectionNamespace
    rules: [...rbacv1.#PolicyRule] & [
        {
            apiGroups:
            - "coordination.k8s.io"
            resources:
            - "leases"
            verbs:
            - "get"
            - "list"
            - "create"
            - "update"
            - "watch"
        }, {
            apiGroups: [""]
            resources:
            - "events"
            verbs: ["create"]
        }
    ]
}

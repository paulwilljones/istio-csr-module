package templates

import (
    rbacv1 "k8s.io/api/rbac/v1"
)

#ClusterRoleBinding: rbacv1.#ClusterRoleBinding & {
    #config:     #Config
	apiVersion: "rbac.authorization.k8s.io/v1"
	kind:       "ClusterRoleBinding"
	metadata: #config.metadata
    subjects: [...rbacv1.#Subject] & [
        {
            kind: "ServiceAccount"
            name: #config.metadata.name
            namespace: #config.metadata.namespace
        }
    ]
    roleRef: rbacv1.#RoleRef & {
        apiGroup: "rbac.authorization.k8s.io"
        kind: "ClusterRole"
        name: #config.metadata.name
    }
}

package templates

import (
    rbacv1 "k8s.io/api/rbac/v1"
    cfg "timoni.sh/istio-csr/templates/config"
)

#RoleDynamicCert: rbacv1.#Role & {
	#config:     cfg.#Config
	apiVersion: "rbac.authorization.k8s.io/v1"
	kind:       "Role"
	metadata: #config.metadata
    metadata: name: "\(#config.metadata.name)-dynamic-istiod"
    rules: [...rbacv1.#PolicyRule] & [
        {
            apiGroups:
            - "cert-manager.io"
            resources:
            - "certificates"
            verbs:
            - "get"
            - "list"
            - "create"
            - "update"
            - "watch"
            - "delete"
        }
    ]
}

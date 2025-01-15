package templates

import (
    rbacv1 "k8s.io/api/rbac/v1"
    cfg "timoni.sh/istio-csr/templates/config"
)

#RoleBindingDynamicCert: rbacv1.#RoleBinding & {
    #config:     cfg.#Config
	apiVersion: "rbac.authorization.k8s.io/v1"
	kind:       "RoleBinding"
	metadata: #config.metadata
    metadata: name: "\(#config.metadata.name)-dynamic-istiod"
    subjects: [...rbacv1.#Subject] & [
        {
            kind: "ServiceAccount"
            name: #config.metadata.name
            namespace: #config.metadata.namespace
        }
    roleRef: rbacv1.#RoleRef & {
        apiGroup: "rbac.authorization.k8s.io"
        kind: "Role"
        name: #config.metadata.name + "-dynamic-istiod"
    }
    ]
}

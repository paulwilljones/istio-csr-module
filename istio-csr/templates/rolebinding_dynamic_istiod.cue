package templates

import (
    rbacv1 "k8s.io/api/rbac/v1"
    timoniv1 "timoni.sh/core/v1alpha1"
)

#RoleBindingDynamicCert: rbacv1.#RoleBinding & {
    #config:     #Config
    #meta: timoniv1.#MetaComponent & {
        #Meta: #config.metadata
        #Component: "dynamic-istiod"
    }
	apiVersion: "rbac.authorization.k8s.io/v1"
    kind: "RoleBinding"
    metadata: #meta
    subjects: [...rbacv1.#Subject] & [
        {
            kind: "ServiceAccount"
            name: #config.metadata.name
            namespace: #config.metadata.namespace
        }
    ]
    roleRef: rbacv1.#RoleRef & {
        apiGroup: "rbac.authorization.k8s.io"
        kind: "Role"
        name: #config.metadata.name + "-dynamic-istiod"
    }
}

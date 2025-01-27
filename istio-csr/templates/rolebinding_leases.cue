package templates

import (
    rbacv1 "k8s.io/api/rbac/v1"
    timoniv1 "timoni.sh/core/v1alpha1"
)

#RoleBindingLeases: rbacv1.#RoleBinding & {
    #config:     #Config
    #meta: timoniv1.#MetaComponent & {
        #Meta: #config.metadata
        #Component: "leases"
    }
	apiVersion: "rbac.authorization.k8s.io/v1"
    kind: "RoleBinding"
    metadata: name: #meta.name
    metadata: namespace: #config.app.controller.leaderElectionNamespace
    metadata: labels: #config.metadata.labels
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
        name: #meta.name
    }
}

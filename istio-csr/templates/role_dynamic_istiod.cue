package templates

import (
    rbacv1 "k8s.io/api/rbac/v1"
    timoniv1 "timoni.sh/core/v1alpha1"
)

#RoleDynamicCert: rbacv1.#Role & {
	#config:     #Config
	apiVersion: "rbac.authorization.k8s.io/v1"
	kind:       "Role"
    #meta: timoniv1.#MetaComponent & {
        #Meta: #config.metadata
        #Component: "dynamic-istiod"
    }
	metadata: #meta
    rules: [...rbacv1.#PolicyRule] & [
        {
            apiGroups: ["cert-manager.io"]
            resources: ["certificates"]
            verbs: ["get", "list", "create", "update", "watch", "delete"]
        }
    ]
}

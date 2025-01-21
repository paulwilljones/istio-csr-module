package templates

import (
    rbacv1 "k8s.io/api/rbac/v1"
    timoniv1 "timoni.sh/core/v1alpha1"
)

#RoleLeases: rbacv1.#Role & {
	#config:     #Config
    #meta: timoniv1.#MetaComponent & {
        #Meta: #config.metadata
        #Component: "leases"
        #Namespace: #config.app.controller.leaderElectionNamespace
    }
	apiVersion: "rbac.authorization.k8s.io/v1"
	kind:       "Role"
    metadata: #meta
    rules: [...rbacv1.#PolicyRule] & [
        {
            apiGroups: ["coordination.k8s.io"]
            resources: ["leases"]
            verbs: ["get", "list", "create", "update", "watch"]
        }, {
            apiGroups: [""]
            resources: ["events"]
            verbs: ["create"]
        }
    ]
}

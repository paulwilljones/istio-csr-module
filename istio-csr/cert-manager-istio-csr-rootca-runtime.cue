runtime: {
    apiVersion: "v1alpha1"
    name:       "istio-csr"
	values: [
		{
			query: "k8s:v1:Secret:istio-system:istio-ca"
            for: {
                "ISTIO_CA":   "obj.data.\"tls.crt\""
            }
		}
	]
}

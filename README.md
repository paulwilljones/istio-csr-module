# istio-csr-module

> Note: this module is experimental and has not been tested with istio-csr's e2e tests, therefore should not be used in production 

Examples of using the istio-csr Timoni Module with cert-manager.

This module is designed to work with the [cert-manager-module](https://github.com/Nalum/cert-manager-module).

## Prerequisite

Install cert-manager

```sh
timoni -n cert-manager apply cert-manager oci://ghcr.io/nalum/timoni/modules/cert-manager
```

## TL;DR

```sh
timoni -n cert-manager apply istio-csr oci://ghcr.io/paulwilljones/modules/istio-csr --version=0.0.1
```

## Simple Bundle

istio-csr can be installed together with cert-manager as a Timoni [Bundle](https://timoni.sh/concepts/#bundle) using default values.

This will:

- Deploy cert-manager using the Timoni Module
- Deploy istio-csr using the Timoni Module 
- Deploy a cert-manager `Certificate` resource used by istiod

This example also:

- Uses the CA returned from cert-manager is used for the gRPC serving certificate
- Creates a self-signed `Issuer`, a self-signed root `Certificate` and CA `Issuer` used by istio-csr (see istio-csr [docs](https://cert-manager.io/docs/usage/istio-csr/installation/#4-export-the-root-ca-to-a-local-file))

```shell
timoni bundle apply -f istio-csr/cert-manager-istio-csr-simple.cue
```

## Dynamic Bundle

istio-csr can be configured to use 'dynamic' configuration which will:

- Create a `ConfigMap` containing `Issuer` configuration
- Create a `Certificate` for istiod at runtime

This example also:

- Creates a self-signed `Issuer`, a self-signed root `Certificate` and CA `Issuer` used by istio-csr (see istio-csr [docs](https://cert-manager.io/docs/usage/istio-csr/installation/#4-export-the-root-ca-to-a-local-file))
- Use the CA returned from cert-manager is used for the gRPC serving certificate

```shell
timoni bundle apply -f istio-csr/cert-manager-istio-csr-dynamic.cue
```

## Runtime Bundle

Timoni provides a 'Runtime' capability to retrieve data from existing Kubernetes resources in the cluster and use them as input values to Instances.

istio-csr can be configured with a `rootCAFile`, which is used for the serving certificate. This file is mounted as a volume from a `Secret` in the cluster. In order to create the `Secret`, the `ca.pem` must be given as part of istio-csr's installation.

Normally, this requires some manual steps to performed sequentially (see istio-csr [docs](https://cert-manager.io/docs/usage/istio-csr/installation/#4-export-the-root-ca-to-a-local-file) to create the `Issuers` and `Certificate`), however, with Timoni's Runtime, the required istio-ca `Secret` can be created by retrieving up the data from the `Secret` created from the `Certificate`, and using the retrieved data as input to the Timoni Module.

```shell
$ bat cert-manager-istio-csr-rootca-runtime.cue
───────┬───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
       │ File: cert-manager-istio-csr-rootca-runtime.cue
───────┼───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
   1   │ runtime: {
   2   │     apiVersion: "v1alpha1"
   3   │     name:       "istio-csr"
   4   │     values: [
   5   │         {
   6   │             query: "k8s:v1:Secret:istio-system:istio-ca"
   7   │             for: {
   8   │                 "ISTIO_CA":   "obj.data.\"tls.crt\""
   9   │             }
  10   │         }
  11   │     ]
  12   │ }
───────┴───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
```

```shell
$ bat cert-manager-istio-csr-rootca.cue
bundle: {
	apiVersion: "v1alpha1"
	name:       "istio-csr"
	instances: {
		"cert-manager-istio-csr": {
			module: {
				url:     "oci://ghcr.io/paulwilljones/modules/istio-csr"
			}
			namespace: "cert-manager"
			values: {
				createSelfSignedCA: false
				app: tls: rootCAFile: "/var/run/secrets/istio-csr/ca.pem"
				app: certmanager: {
					issuer: {
						name: "istio-ca"
						kind: "Issuer"
						group: "cert-manager.io"
					}
				}
				app: tls: istioRootCA: "" @timoni(runtime:string:ISTIO_CA)
				volumeMounts: [{
					name: "root-ca"
					mountPath: "/var/run/secrets/istio-csr"
				}]
				volumes: [{
					name: "root-ca"
					secret: secretName: "istio-root-ca"
				}]
			}
		}
	}
}
```

cert-manager is installed first, followed by a self-signed `Issuer`, istio-ca `Certificate` and istio-ca `Issuer`.

The `Secret` containing the istio-ca `Certificate` is then queried at runtime during the istio-csr Instance install, and the value passed used in the config to create the `Secret` mounted by istio-csr.

```shell
timoni bundle apply -f istio-csr/cert-manager-istio-csr-rootca-issuer.cue
kubectl apply -f hack/issuer.yaml
timoni bundle apply -f istio-csr/cert-manager-istio-csr-rootca.cue --runtime istio-csr/cert-manager-istio-csr-rootca-runtime.cue
```

# hack-timoni

A set of Timoni examples to deploy Bundles using CUE Modules.

## TL;DR

```sh
timoni -n cert-manager apply cert-manager oci://ghcr.io/nalum/timoni/modules/cert-manager
```

Change the default configuration using `cert-manager.cue`.

For example, set the following contents:

```
values: {
    highAvailability: enabled: true

    controller: {
        config: logging: format: "json"
        podDisruptionBudget: minAvailable: 2

        monitoring: {
            enabled: true
        }

        image: {
            tag:    "v1.14.0"
            digest: "sha256:2547fde4e736101abf33f8c2503f12aa3a0b42614d3d64cfecf2835c0ee81c10"
        }
    }

    webhook: {
        podDisruptionBudget: minAvailable: 3
    }

    test: enabled: false
}
```

Apply the values to the instance

```sh
timoni -n cert-manager apply cert-manager oci://ghcr.io/nalum/timoni/modules/cert-manager --values ./my-values.cue
```

## istio-csr

Apply the istio-csr bundle to install cert-manager and istio-csr

```sh
timoni bundle vet -f istio-csr.cue --print-value
timoni bundle apply -f istio-csr.cue
```

### Distribute

```sh
timoni mod vet ./istio-csr
timoni mod push oci://ghcr.io/paulwilljones/modules/istio-csr
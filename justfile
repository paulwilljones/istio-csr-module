build:
    timoni build cert-manager-istio-csr ./ -n istio-csr -f values.cue

vet:
    timoni mod vet --name istio-csr -n istio-csr

push:
    timoni mod push ./istio-csr/ oci://ghcr.io/paulwilljones/modules/istio-csr --version=0.0.1 --creds=timoni:$GITHUB_TOKEN

apply-runtime:
    timoni bundle apply -f istio-csr/cert-manager-istio-csr-rootca-issuer.cue
    kubectl apply -f hack/issuer.yaml
    timoni bundle apply -f istio-csr/cert-manager-istio-csr-rootca.cue --runtime istio-csr/cert-manager-istio-csr-rootca-runtime.cue

delete-runtime:
    timoni bundle delete -f istio-csr/cert-manager-istio-csr-rootca.cue --runtime istio-csr/cert-manager-istio-csr-rootca-runtime.cue
    kubectl delete -f hack/issuer.yaml
    timoni bundle delete -f istio-csr/cert-manager-istio-csr-rootca-issuer.cue

apply-dynamic:
    timoni bundle apply -f istio-csr/cert-manager-istio-csr-dynamic.cue

delete-dynamic:
    timoni bundle delete -f istio-csr/cert-manager-istio-csr-dynamic.cue

apply:
    timoni bundle apply -f istio-csr/cert-manager-istio-csr-simple.cue

delete:
    timoni bundle delete -f istio-csr/cert-manager-istio-cue-simple.cue

kind:
    kind create cluster -n istio-csr

rm-kind:
    kind delete cluster -n istio-csr

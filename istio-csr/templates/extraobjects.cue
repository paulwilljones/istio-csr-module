package templates

import (
    cfg "timoni.sh/istio-csr/templates/config"
)

#ExtraObjects: [...timoniv1.#ObjectReference] & extraObjects

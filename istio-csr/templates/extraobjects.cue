package templates

import (
	timoniv1 "timoni.sh/core/v1alpha1"
)

#config: #Config
#ExtraObjects: [...timoniv1.#ObjectReference] & #config.extraObjects

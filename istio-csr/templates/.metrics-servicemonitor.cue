package templates

import (
    promv1 "monitoring.coreos.com/servicemonitor/v1"
)

#ServiceMonitor: promv1.#ServiceMonitor & {
    #config:  #Config
    metadata: #config.metadata
    spec: {
        endpoints: [{
            // Change this to match the Service port where
            // your app exposes the /metrics endpoint
            port:     "http-metrics"
            path:     "/metrics"
            interval: "\(#config.monitoring.interval)s"
        }]
        namespaceSelector: matchNames: [#config.metadata.namespace]
        selector: matchLabels: #config.selector.labels
    }
}
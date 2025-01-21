package templates

import (
    promv1 "monitoring.coreos.com/servicemonitor/v1"
)

#ServiceMonitor: promv1.#ServiceMonitor & {
    #config:  #Config
    metadata: #config.metadata
    metadata: labels: {"prometheus": #config.app.metrics.service.servicemonitor.prometheusInstance}
if #config.app.metrics.service.servicemonitor.labels != _|_ {
    metadata: labels: #config.app.metrics.service.servicemonitor.labels
}
    spec: promv1.#ServiceMonitorSpec & {
        jobLabel: #config.metadata.name
        selector: matchLabels: {"app": #config.metadata.name+"-metrics"}
        namespaceSelector: matchNames: [#config.metadata.namespace]
        endpoints: [{
            targetPort: #config.app.metrics.port
            path:     "/metrics"
            interval: #config.app.metrics.service.servicemonitor.interval
            scrapeTimeout: #config.app.metrics.service.servicemonitor.scrapeTimeout
        }]
    }
}

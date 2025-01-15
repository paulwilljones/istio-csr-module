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
package com.mateusz.microservices.limitsservice.config

import org.springframework.boot.context.properties.ConfigurationProperties
import org.springframework.stereotype.Component

@Component
@ConfigurationProperties(prefix = "limits-service")
class Configuration {
    var minimum: Int = 0
    var maximum: Int = 0
}
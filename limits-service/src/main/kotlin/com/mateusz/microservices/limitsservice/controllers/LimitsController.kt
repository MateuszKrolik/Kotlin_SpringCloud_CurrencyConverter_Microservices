package com.mateusz.microservices.limitsservice.controllers

import com.mateusz.microservices.limitsservice.config.Configuration
import com.mateusz.microservices.limitsservice.dto.Limits
import org.springframework.web.bind.annotation.GetMapping
import org.springframework.web.bind.annotation.RestController

@RestController
class LimitsController(private var configuration: Configuration) {

    @GetMapping("/limits")
    fun retrieveLimits(): Limits {
        return Limits(configuration.minimum, configuration.maximum)
    }
}
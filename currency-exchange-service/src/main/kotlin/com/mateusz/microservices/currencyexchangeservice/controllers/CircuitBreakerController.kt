package com.mateusz.microservices.currencyexchangeservice.controllers

import io.github.resilience4j.circuitbreaker.annotation.CircuitBreaker
// import io.github.resilience4j.retry.annotation.Retry
import org.slf4j.Logger
import org.slf4j.LoggerFactory
import org.springframework.web.bind.annotation.GetMapping
import org.springframework.web.bind.annotation.RestController
import org.springframework.web.client.RestTemplate
import java.lang.Exception

// spam requests for circuit-breaker testing purposes:
// "watch -n 0.1 curl http://localhost:8000/sample-api"

@RestController
class CircuitBreakerController {

    private val logger: Logger = LoggerFactory.getLogger(CircuitBreakerController::class.java)

    @GetMapping("/sample-api")
    // @Retry(name = "sample-api", fallbackMethod = "hardCodedResponse")
    @CircuitBreaker(name = "default", fallbackMethod = "hardCodedResponse")
    fun sampleApi():String {
        logger.info("Sample Api Call Received")
        val forEntity = RestTemplate().getForEntity("http://localhost:8080/some-dummy-url", String::class.java)
        return forEntity.body!!
    }

    fun hardCodedResponse(ex: Exception): String {
        return "fallback-response"
    }
}
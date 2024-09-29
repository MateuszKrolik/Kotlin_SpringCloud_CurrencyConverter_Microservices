package com.mateusz.microservices.currencyexchangeservice.controllers

import io.github.resilience4j.retry.annotation.Retry
import org.slf4j.Logger
import org.slf4j.LoggerFactory
import org.springframework.web.bind.annotation.GetMapping
import org.springframework.web.bind.annotation.RestController
import org.springframework.web.client.RestTemplate
import java.lang.Exception

@RestController
class CircuitBreakerController {

    private val logger: Logger = LoggerFactory.getLogger(CircuitBreakerController::class.java)

    @GetMapping("/sample-api")
    @Retry(name = "sample-api", fallbackMethod = "hardCodedResponse")
    fun sampleApi():String {
        logger.info("Sample Api Call Received")
        val forEntity = RestTemplate().getForEntity("http://localhost:8080/some-dummy-url", String::class.java)
        return forEntity.body!!
    }

    fun hardCodedResponse(ex: Exception): String {
        return "fallback-response"
    }
}
package com.mateusz.microservices.currencyexchangeservice.controllers

import com.mateusz.microservices.currencyexchangeservice.models.CurrencyExchange
import org.springframework.core.env.Environment
import org.springframework.web.bind.annotation.GetMapping
import org.springframework.web.bind.annotation.RestController
import org.springframework.web.bind.annotation.PathVariable
import java.math.BigDecimal
import java.util.*

@RestController
class CurrencyExchangeController(private var environment: Environment) {

    @GetMapping("/currency-exchange/from/{from}/to/{to}")
    fun retrieveExchangeValue(@PathVariable from: String, @PathVariable to:String): CurrencyExchange {
        val currencyExchange = CurrencyExchange(UUID.randomUUID(), from, to, BigDecimal.valueOf(50))
        val port = environment.getProperty("local.server.port")
        currencyExchange.environment = port!!
        return currencyExchange
    }
}
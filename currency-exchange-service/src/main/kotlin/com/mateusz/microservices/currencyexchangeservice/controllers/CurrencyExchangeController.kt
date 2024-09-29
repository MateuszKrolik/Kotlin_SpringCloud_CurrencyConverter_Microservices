package com.mateusz.microservices.currencyexchangeservice.controllers

import com.mateusz.microservices.currencyexchangeservice.models.CurrencyExchange
import com.mateusz.microservices.currencyexchangeservice.repositories.CurrencyExchangeRepository
import org.springframework.core.env.Environment
import org.springframework.web.bind.annotation.GetMapping
import org.springframework.web.bind.annotation.RestController
import org.springframework.web.bind.annotation.PathVariable

@RestController
class CurrencyExchangeController(private var environment: Environment, private var currencyExchangeRepository: CurrencyExchangeRepository) {

    @GetMapping("/currency-exchange/from/{from}/to/{to}")
    fun retrieveExchangeValue(@PathVariable from: String, @PathVariable to:String): CurrencyExchange {
        val currencyExchange = currencyExchangeRepository.findByFromAndTo(from, to)
            ?: throw RuntimeException("Unable to find data for $from and $to") // unchecked exc

        val port = environment.getProperty("local.server.port")
        currencyExchange.environment = port!!
        return currencyExchange
    }
}
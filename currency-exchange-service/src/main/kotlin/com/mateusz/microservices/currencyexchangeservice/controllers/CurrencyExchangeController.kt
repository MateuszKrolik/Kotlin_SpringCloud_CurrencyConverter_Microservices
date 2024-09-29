package com.mateusz.microservices.currencyexchangeservice.controllers

import com.mateusz.microservices.currencyexchangeservice.models.CurrencyExchange
import com.mateusz.microservices.currencyexchangeservice.repositories.CurrencyExchangeRepository
import org.slf4j.Logger
import org.slf4j.LoggerFactory
import org.springframework.core.env.Environment
import org.springframework.web.bind.annotation.GetMapping
import org.springframework.web.bind.annotation.RestController
import org.springframework.web.bind.annotation.PathVariable

@RestController
class CurrencyExchangeController(private var environment: Environment, private var currencyExchangeRepository: CurrencyExchangeRepository) {

    // INFO [currency-exchange,6d7f30758079ae4a3da67c16545cb6b2,2ddd8f929dbc06c2] ... : retrieveExchangeValue called with USD to PLN
    private var logger: Logger = LoggerFactory.getLogger(CurrencyExchangeController::class.java)

    @GetMapping("/currency-exchange/from/{from}/to/{to}")
    fun retrieveExchangeValue(@PathVariable from: String, @PathVariable to:String): CurrencyExchange {

        logger.info("retrieveExchangeValue called with {} to {}", from, to)

        val currencyExchange = currencyExchangeRepository.findByFromAndTo(from, to)
            ?: throw RuntimeException("Unable to find data for $from and $to") // unchecked exc

        val port = environment.getProperty("local.server.port")
        currencyExchange.environment = port!!
        return currencyExchange
    }
}
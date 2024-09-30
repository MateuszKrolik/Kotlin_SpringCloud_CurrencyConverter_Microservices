package com.mateusz.microservices.currencyconversionservice.feign

import com.mateusz.microservices.currencyconversionservice.dto.CurrencyExchange
import org.springframework.cloud.openfeign.FeignClient
import org.springframework.web.bind.annotation.GetMapping
import org.springframework.web.bind.annotation.PathVariable

//@FeignClient(value = "currency-exchange", url = "localhost:8000")
//@FeignClient(value = "currency-exchange") // enable load-balancing
//@FeignClient(name = "currency-exchange", url = "\${CURRENCY_EXCHANGE_SERVICE_HOST:http://localhost}:8000")
@FeignClient(name = "currency-exchange", url = "\${CURRENCY_EXCHANGE_URI:http://localhost}:8000")
interface CurrencyExchangeProxy {
    @GetMapping("/currency-exchange/from/{from}/to/{to}")
    fun retrieveExchangeValue(@PathVariable from: String, @PathVariable to: String): CurrencyExchange
}

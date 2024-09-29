package com.mateusz.microservices.currencyconversionservice.controllers

import com.mateusz.microservices.currencyconversionservice.dto.CurrencyConversion
import org.springframework.web.bind.annotation.GetMapping
import org.springframework.web.bind.annotation.PathVariable
import org.springframework.web.bind.annotation.RestController
import java.math.BigDecimal
import java.util.*

@RestController
class CurrencyConversionController {

    @GetMapping("/currency-conversion/from/{from}/to/{to}/quantity/{quantity}")
    fun calculateCurrencyConversion(@PathVariable from:String, @PathVariable to: String, @PathVariable quantity: BigDecimal): CurrencyConversion {
        return CurrencyConversion(UUID.randomUUID(), from, to, quantity, BigDecimal.ONE, BigDecimal.ONE, "")
    }
}
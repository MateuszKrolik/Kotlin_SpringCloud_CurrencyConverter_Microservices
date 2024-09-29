package com.mateusz.microservices.currencyconversionservice.controllers

import com.mateusz.microservices.currencyconversionservice.dto.CurrencyConversion
import com.mateusz.microservices.currencyconversionservice.dto.CurrencyExchange
import com.mateusz.microservices.currencyconversionservice.feign.CurrencyExchangeProxy
import org.springframework.web.bind.annotation.GetMapping
import org.springframework.web.bind.annotation.PathVariable
import org.springframework.web.bind.annotation.RestController
import org.springframework.web.client.RestTemplate
import java.math.BigDecimal
import java.util.*

@RestController
class CurrencyConversionController(private val currencyExchangeProxy: CurrencyExchangeProxy) {


    @GetMapping("/currency-conversion/from/{from}/to/{to}/quantity/{quantity}")
    fun calculateCurrencyConversion(@PathVariable from:String, @PathVariable to: String, @PathVariable quantity: BigDecimal): CurrencyConversion {

        val uriVariables: HashMap<String,String> = HashMap()
        uriVariables["from"] = from
        uriVariables["to"] = to

        val responseEntity = RestTemplate().getForEntity(
            "http://localhost:8000/currency-exchange/from/{from}/to/{to}",
            CurrencyExchange::class.java,
            uriVariables
        )

        val currencyConversion = responseEntity.body!!

        return CurrencyConversion(
            currencyConversion.id,
            from,
            to,
            quantity,
            currencyConversion.conversionMultiple,
            quantity.multiply(currencyConversion.conversionMultiple),
            currencyConversion.environment + " " + "rest template"
        )
    }

    @GetMapping("/currency-conversion-feign/from/{from}/to/{to}/quantity/{quantity}")
    fun calculateCurrencyConversionFeign(@PathVariable from:String, @PathVariable to: String, @PathVariable quantity: BigDecimal): CurrencyConversion {

        val currencyConversion = currencyExchangeProxy.retrieveExchangeValue(from, to)

        return CurrencyConversion(
            currencyConversion.id,
            from,
            to,
            quantity,
            currencyConversion.conversionMultiple,
            quantity.multiply(currencyConversion.conversionMultiple),
            currencyConversion.environment + " " + "feign"
        )
    }

}
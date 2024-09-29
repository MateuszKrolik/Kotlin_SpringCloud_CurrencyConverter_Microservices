package com.mateusz.microservices.currencyconversionservice

import org.springframework.boot.autoconfigure.SpringBootApplication
import org.springframework.boot.runApplication
import org.springframework.cloud.openfeign.EnableFeignClients

@SpringBootApplication
@EnableFeignClients
class CurrencyConversionServiceApplication

fun main(args: Array<String>) {
	runApplication<CurrencyConversionServiceApplication>(*args)
}

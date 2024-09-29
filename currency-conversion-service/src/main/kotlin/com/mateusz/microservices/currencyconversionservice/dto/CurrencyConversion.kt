package com.mateusz.microservices.currencyconversionservice.dto

import java.math.BigDecimal
import java.util.UUID

data class CurrencyConversion(
    val id: UUID,
    val from: String,
    val to: String,
    val quantity: BigDecimal,
    val conversionMultiple: BigDecimal,
    val totalCalculatedAmount: BigDecimal,
    val environment: String)

//    val id: UUID = UUID.randomUUID()
//    val from: String = ""
//    val to: String = ""
//    val conversionMultiple: BigDecimal = BigDecimal(0)
//    val quantity: BigDecimal = BigDecimal(0)
//    val totalCalculatedAmount: BigDecimal = BigDecimal(0)
//    val environment: String = ""


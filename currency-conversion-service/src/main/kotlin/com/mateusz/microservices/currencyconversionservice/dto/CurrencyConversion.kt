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


package com.mateusz.microservices.currencyconversionservice.dto

import java.math.BigDecimal
import java.util.UUID

data class CurrencyExchange(
    val id: UUID,
    val from: String,
    val to: String,
    val conversionMultiple: BigDecimal,
    val environment: String
)
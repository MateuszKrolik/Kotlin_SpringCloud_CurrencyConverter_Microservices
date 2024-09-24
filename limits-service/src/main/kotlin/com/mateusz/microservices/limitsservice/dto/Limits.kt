package com.mateusz.microservices.limitsservice.dto

data class Limits(
    val minimum: Int = 0,
    val maximum: Int = 0
)

package com.mateusz.microservices.currencyexchangeservice.repositories

import com.mateusz.microservices.currencyexchangeservice.models.CurrencyExchange
import org.springframework.data.jpa.repository.JpaRepository
import java.util.UUID

interface CurrencyExchangeRepository: JpaRepository<CurrencyExchange, UUID> {
    fun findByFromAndTo(from: String, to: String): CurrencyExchange?
}
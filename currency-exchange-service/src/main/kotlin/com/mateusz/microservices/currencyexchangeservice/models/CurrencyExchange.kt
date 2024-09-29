package com.mateusz.microservices.currencyexchangeservice.models

import java.math.BigDecimal
import java.util.*

class CurrencyExchange {
    var id: UUID? = null
    var from: String? = null
    var to: String? = null
    var conversionMultiple: BigDecimal? = null

    constructor()

    constructor(id: UUID?, from: String?, to: String?, conversionMultiple: BigDecimal?) {
        this.id = id
        this.from = from
        this.to = to
        this.conversionMultiple = conversionMultiple
    }


    override fun toString(): String {
        return "CurrencyExchange{" +
                "id=" + id +
                ", from='" + from + '\'' +
                ", to='" + to + '\'' +
                ", conversionMultiple=" + conversionMultiple +
                '}'
    }
}
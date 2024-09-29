package com.mateusz.microservices.currencyexchangeservice.models

import jakarta.persistence.*
import java.math.BigDecimal
import java.util.*

@Entity
@Table(
    name = "currency_exchange",
    uniqueConstraints = [UniqueConstraint(columnNames = ["currency_from", "currency_to"])]
)
class CurrencyExchange {
    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    lateinit var id: UUID
    @Column(name = "currency_from")
    var from: String = ""
    @Column(name = "currency_to")
    var to: String = ""
    var conversionMultiple: BigDecimal = BigDecimal(0)
    var environment: String = ""

    constructor()

    constructor(id: UUID, from: String, to: String, conversionMultiple: BigDecimal) {
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
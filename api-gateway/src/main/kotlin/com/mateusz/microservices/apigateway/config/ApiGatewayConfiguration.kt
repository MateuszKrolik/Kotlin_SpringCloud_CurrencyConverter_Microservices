package com.mateusz.microservices.apigateway.config

import org.springframework.cloud.gateway.route.RouteLocator
import org.springframework.cloud.gateway.route.builder.RouteLocatorBuilder
import org.springframework.context.annotation.Bean
import org.springframework.context.annotation.Configuration

@Configuration
class ApiGatewayConfiguration {
    @Bean
    fun  gatewayRouter(builder: RouteLocatorBuilder):RouteLocator {

        return builder
            .routes()
            .route { predicateSpec ->
                predicateSpec
                    .path("/get")
                    .filters { f ->
                        f
                            .addRequestHeader("MyHeader", "MyURI")
                            .addRequestParameter("Param", "MyValue")
                    }
                    .uri("http://httpbin.org:80")
            }
            .route { p ->
                p.path("/currency-exchange/**")
                    .uri("lb://currency-exchange")
            }
            .route { p ->
                p.path("/currency-conversion/**")
                    .uri("lb://currency-conversion")
            }
            .route { p ->
                p.path("/currency-conversion-feign/**")
                    .uri("lb://currency-conversion")
            }
            .route { p ->
                p.path("/currency-conversion-new/**")
                    .filters { f ->
                        f
                            .rewritePath(
                                "/currency-conversion-new/(?<segment>.*)", // define next thing in url as segment via regex
                                "/currency-conversion-feign/\${segment}"
                            ) // escape interpolation
                    }
                    .uri("lb://currency-conversion")
            }
            .build()
    }
}
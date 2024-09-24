package com.mateusz.microservices.springcloudconfigserver

import org.springframework.boot.autoconfigure.SpringBootApplication
import org.springframework.boot.runApplication
import org.springframework.cloud.config.server.EnableConfigServer

@EnableConfigServer
@SpringBootApplication
class SpringCloudConfigServerApplication

fun main(args: Array<String>) {
    runApplication<SpringCloudConfigServerApplication>(*args)
}

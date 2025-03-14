package com.example.workflow;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.boot.autoconfigure.jdbc.DataSourceAutoConfiguration;

@SpringBootApplication
public class BusinessProcessApplication {
    public static void main(String[] args) {
        SpringApplication.run(BusinessProcessApplication.class, args);
    }
}
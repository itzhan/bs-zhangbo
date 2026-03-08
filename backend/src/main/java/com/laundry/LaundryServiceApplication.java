package com.laundry;

import org.mybatis.spring.annotation.MapperScan;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;

@SpringBootApplication
@MapperScan("com.laundry.mapper")
public class LaundryServiceApplication {
    public static void main(String[] args) {
        SpringApplication.run(LaundryServiceApplication.class, args);
    }
}

package com.devfly.photostore;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.scheduling.annotation.EnableAsync;

@SpringBootApplication
@EnableAsync
public class PhotoStoreApplication {
    public static void main(String[] args) {
        SpringApplication.run(PhotoStoreApplication.class, args);
    }
}

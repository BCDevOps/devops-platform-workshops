package com.mycompany.app.controller;

import org.springframework.web.bind.annotation.*;
import org.springframework.http.ResponseEntity;

import java.util.concurrent.atomic.AtomicLong;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

@RestController
public class MyLoggingController {
    private static final java.util.logging.Logger LOGGER = LoggerFactory.getLogger(MyLoggingController.class);

    private static final String template = "[%d]: Hello, %s!";
    private final AtomicLong counter = new AtomicLong();

    @GetMapping("/hello/{user}")
    public ResponseEntity<String> hello(@PathParam String user) {
        long lc = counter.incrementAndGet();
        LOGGER.info("hello called {} times.", lc);

        return ResponseEntity.ok(String.format(template, lc, user));
    }
    
}

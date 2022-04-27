package com.mycompany.app.controller;

import org.springframework.web.bind.annotation.*;
import org.springframework.http.ResponseEntity;

@RestController
public class MyAppController {

    @GetMapping("/hello")
    public ResponseEntity<String> hello() {
        String name = System.getenv().getOrDefault("NAME", "unknown");
        String message = System.getenv().getOrDefault("APP_MSG", null);
        String response = "";

      	if (message == null)
      	  response = "Hello world from "+name+"\n";
      	else
      	  response = "Hello world from ["+name+"]. Message received = "+message+"\n";

        return ResponseEntity.ok(response);
    }
    
}

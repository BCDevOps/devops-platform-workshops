package com.mycompany.app.controller;

import org.springframework.web.bind.annotation.*;
import org.springframework.http.ResponseEntity;

@RestController
public class MyAppController {

    @GetMapping("/hello")
    public ResponseEntity<String> hello() {
        String name = System.getenv().getOrDefault("NAME", "unknown");
        String message = System.getenv().getOrDefault("APP_MSG", null);
        String secret = System.getenv().getOrDefault("SECRET_APP_MSG", null);
        StringBuilder response = new StringBuilder();

      	if (message == null) {
      	  response.append("Hello world from ").append(name);
          if (null != secret) {
              response.append(" with secret message: ").append(secret);
          }

          response.append("\n");
        } else {
      	  response.append("Hello world from [")
                  .append(name)
                  .append("]. Message received = ")
                  .append(message);
                  
          if (null != secret) {
              response.append(" with secret message: ")
                      .append(secret);
          }
        
          response.append("\n");
        }

        return ResponseEntity.ok(response.toString());
    }
    
}

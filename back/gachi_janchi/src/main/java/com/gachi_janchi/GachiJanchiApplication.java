package com.gachi_janchi;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.scheduling.annotation.EnableScheduling;

@SpringBootApplication
@EnableScheduling
public class GachiJanchiApplication {

  public static void main(String[] args) {

    SpringApplication.run(GachiJanchiApplication.class, args);
  }

}

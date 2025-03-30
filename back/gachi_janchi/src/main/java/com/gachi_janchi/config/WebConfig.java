package com.gachi_janchi.config;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.annotation.Configuration;
import org.springframework.web.servlet.config.annotation.ResourceHandlerRegistry;
import org.springframework.web.servlet.config.annotation.WebMvcConfigurer;

@Configuration
public class WebConfig implements WebMvcConfigurer{

  @Value("${REVIEW_IMAGE_PATH}")
  private String reviewImageRelativePath;

  @Override
  public void addResourceHandlers(ResourceHandlerRegistry registry) {
    registry.addResourceHandler("/images/review/**")
            .addResourceLocations("file:" + reviewImageRelativePath + "/");
  }
  
}



⸻

1. Update your CorsConfig class:

package com.platform.workflow.config;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.web.servlet.config.annotation.CorsRegistry;
import org.springframework.web.servlet.config.annotation.WebMvcConfigurer;

@Configuration
public class CorsConfig {

    @Value("${cors.allowed-origins:*}")
    private String[] allowedOrigins;

    @Bean
    public WebMvcConfigurer corsConfigurer() {
        return new WebMvcConfigurer() {
            @Override
            public void addCorsMappings(CorsRegistry registry) {
                registry.addMapping("/**")
                        .allowedOrigins(allowedOrigins)
                        .allowedMethods("GET", "POST", "PUT", "DELETE", "OPTIONS")
                        .allowedHeaders("*")
                        .allowCredentials(true)
                        .maxAge(3600);
            }
        };
    }
}

allowedOrigins is now injected as a string array from the property cors.allowed-origins. You can pass multiple origins separated by commas.

⸻

2. Set the environment variable

In your application.yml or .properties, add:

cors:
  allowed-origins: "http://localhost:3000,http://your-domain.com"

Or set it via environment variable:

export CORS_ALLOWED_ORIGINS=http://localhost:3000,http://your-domain.com

and in application.yml:

cors:
  allowed-origins: ${CORS_ALLOWED_ORIGINS}



⸻

🛑 Important Note:

If you’re using .allowedOrigins("*"), you cannot have .allowCredentials(true) at the same time — that’s a CORS spec violation.

So if you want to allow credentials (e.g., cookies, auth headers), you must specify exact domains.



⸻

How to Add Spring Boot Security?

To secure your Camunda + Spring Boot application, follow these steps:

⸻

1. Add Spring Security Dependency

Modify your pom.xml to include:

<dependency>
    <groupId>org.springframework.boot</groupId>
    <artifactId>spring-boot-starter-security</artifactId>
</dependency>

This will enable Spring Security by default.

⸻

2. Configure Security in application-prod.yaml

Modify application-prod.yaml to enforce authentication in production:

camunda:
  bpm:
    webapp:
      index-redirect-enabled: true
    authorization:
      enabled: true
    login:
      enabled: true

spring:
  security:
    user:
      name: admin  # Default admin user
      password: ${ADMIN_PASSWORD}  # Set password via environment variable
      roles: ADMIN

✅ Enables Camunda login in production
✅ Secures Camunda Webapp
✅ Prevents unauthorized API access
✅ Uses environment variables for password security

⸻

3. Disable Security in application-dev.yaml (for local development)

For development, disable security to make testing easier:

camunda:
  bpm:
    webapp:
      index-redirect-enabled: true
    authorization:
      enabled: false  # No authentication in dev mode
    login:
      enabled: false

spring:
  security:
    user:
      name: admin
      password: admin
      roles: ADMIN

🚀 Allows local testing without authentication
🔒 Security is only enabled in production

⸻

4. Implement Spring Security Configuration (SecurityConfig.java)

Create a SecurityConfig.java class in your project:

import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.security.config.annotation.web.builders.HttpSecurity;
import org.springframework.security.config.annotation.web.configuration.EnableWebSecurity;
import org.springframework.security.web.SecurityFilterChain;

@Configuration
@EnableWebSecurity
public class SecurityConfig {

    @Bean
    public SecurityFilterChain securityFilterChain(HttpSecurity http) throws Exception {
        http
            .authorizeHttpRequests(authorizeRequests ->
                authorizeRequests
                    .requestMatchers("/camunda/**").authenticated()  // Protect Camunda Webapp
                    .requestMatchers("/api/**").hasRole("ADMIN")  // Protect API endpoints
                    .anyRequest().permitAll()
            )
            .formLogin()
            .and()
            .logout();
        
        return http.build();
    }
}

✅ Protects Camunda Webapp (/camunda)
✅ Restricts API endpoints (/api/) to ADMIN role
✅ Uses login form authentication

⸻

5. Run with Secure Production Profile

To run the application with security enabled, set the Spring Profile to prod:

export SPRING_PROFILES_ACTIVE=prod
export ADMIN_PASSWORD=securepassword
java -jar target/Lafayette-1.0.0.jar



⸻

Final Setup Summary

🔹 Spring Security enabled only in production
🔹 Development mode (dev) has security disabled for testing
🔹 Authentication enforced on /camunda and /api/**
🔹 Password stored securely via environment variables

⸻

Next Steps

✅ Do you need JWT or OAuth2 authentication instead?
✅ Would you like to integrate Camunda with Single Sign-On (SSO)?

Let me know, and I can help configure advanced security features! 🚀🔐
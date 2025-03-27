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
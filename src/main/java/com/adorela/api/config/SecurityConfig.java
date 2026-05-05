package com.adorela.api.config;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.web.cors.CorsConfiguration;
import org.springframework.web.cors.CorsConfigurationSource;
import org.springframework.web.cors.UrlBasedCorsConfigurationSource;
import org.springframework.security.config.annotation.method.configuration.EnableMethodSecurity;
import org.springframework.security.config.annotation.web.builders.HttpSecurity;
import org.springframework.security.config.annotation.web.configuration.EnableWebSecurity;
import org.springframework.security.config.annotation.web.configurers.AbstractHttpConfigurer;
import org.springframework.security.web.SecurityFilterChain;
import org.springframework.security.oauth2.server.resource.authentication.JwtAuthenticationConverter;
import org.springframework.security.oauth2.server.resource.authentication.JwtGrantedAuthoritiesConverter;

import java.util.Arrays;
import java.util.List;
import org.springframework.http.HttpMethod;

/**
 * Configuração de segurança do Adorela.
 *
 * 4 perfis funcionais (alinhados ao realm `adorela` do Keycloak):
 *  - admin (composto pelas roles dono + gerente + revisao): acesso total
 *  - limitado:    visualização apenas do catálogo público de produtos
 *  - exclusivo1:  leitura + área exclusiva do grupo 1
 *  - exclusivo2:  leitura + área exclusiva do grupo 2
 *
 * Mapeamento das roles do JWT:
 *  - O claim `roles` (mapper customizado no realm) é convertido em authorities
 *    com prefixo `ROLE_` para que `hasRole(...)` / `hasAnyRole(...)` funcionem.
 *
 * Mapeamento de endpoints (defesa em profundidade — também há @PreAuthorize):
 *  - GET  /api/products/**   → público (limitado pode visualizar catálogo)
 *  - GET  /api/categories/** → bloqueado para limitado (via @PreAuthorize)
 *  - GET  /api/uploads/**    → público (serve imagens do catálogo)
 *  - POST/PUT/PATCH /api/**  → dono ou gerente
 *  - DELETE /api/**          → apenas dono
 */
@Configuration
@EnableWebSecurity
@EnableMethodSecurity
public class SecurityConfig {

    @Value("${adorela.cors.allowed-origins:http://localhost:4200}")
    private String allowedOrigins;

    @Bean
    public SecurityFilterChain securityFilterChain(HttpSecurity http) throws Exception {
        http
            .cors(cors -> cors.configurationSource(corsConfigurationSource()))
            // API stateless baseada em JWT — CSRF não se aplica (sem cookies de sessão).
            .csrf(AbstractHttpConfigurer::disable)
            // Headers de segurança (defesa em profundidade — apoio a #18/#19 OWASP).
            .headers(headers -> headers
                .contentTypeOptions(ct -> {})
                .frameOptions(frame -> frame.deny())
                .referrerPolicy(rp -> rp.policy(
                    org.springframework.security.web.header.writers.ReferrerPolicyHeaderWriter.ReferrerPolicy.NO_REFERRER))
                .httpStrictTransportSecurity(hsts -> hsts
                    .includeSubDomains(true)
                    .maxAgeInSeconds(31_536_000))
            )
            .authorizeHttpRequests(auth -> auth
                // Swagger / OpenAPI — público
                .requestMatchers("/swagger-ui/**", "/swagger-ui.html", "/api-docs/**", "/v3/api-docs/**").permitAll()
                // Preflight CORS
                .requestMatchers(HttpMethod.OPTIONS, "/**").permitAll()
                // Leitura pública — produtos e arquivos servidos
                .requestMatchers(HttpMethod.GET, "/api/products/**").permitAll()
                .requestMatchers(HttpMethod.GET, "/api/uploads/**").permitAll()
                // Categorias: leitura restrita (limitado é negado pelo @PreAuthorize do controller)
                .requestMatchers(HttpMethod.GET, "/api/categories/**").permitAll()
                // Criação e edição — dono ou gerente
                .requestMatchers(HttpMethod.POST, "/api/**").hasAnyRole("dono", "gerente")
                .requestMatchers(HttpMethod.PUT, "/api/**").hasAnyRole("dono", "gerente")
                .requestMatchers(HttpMethod.PATCH, "/api/**").hasAnyRole("dono", "gerente")
                // Exclusão — apenas dono
                .requestMatchers(HttpMethod.DELETE, "/api/**").hasRole("dono")
                .anyRequest().permitAll()
            )
            .oauth2ResourceServer(oauth -> oauth
                .jwt(jwt -> jwt.jwtAuthenticationConverter(jwtAuthenticationConverter()))
            );

        return http.build();
    }

    @Bean
    public CorsConfigurationSource corsConfigurationSource() {
        CorsConfiguration config = new CorsConfiguration();
        config.setAllowCredentials(true);
        List<String> origins = Arrays.asList(allowedOrigins.split(","));
        config.setAllowedOriginPatterns(origins);
        config.setAllowedHeaders(List.of("*"));
        config.setAllowedMethods(List.of("GET", "POST", "PUT", "DELETE", "OPTIONS", "PATCH"));
        config.setExposedHeaders(List.of("Authorization", "Content-Disposition"));
        config.setMaxAge(3600L);

        UrlBasedCorsConfigurationSource source = new UrlBasedCorsConfigurationSource();
        source.registerCorsConfiguration("/**", config);
        return source;
    }

    private JwtAuthenticationConverter jwtAuthenticationConverter() {
        JwtGrantedAuthoritiesConverter grantedAuthoritiesConverter = new JwtGrantedAuthoritiesConverter();
        // Buscar roles no claim "roles" mapeado pelo Keycloak via protocolMapper
        grantedAuthoritiesConverter.setAuthorityPrefix("ROLE_");
        grantedAuthoritiesConverter.setAuthoritiesClaimName("roles");
        JwtAuthenticationConverter converter = new JwtAuthenticationConverter();
        converter.setJwtGrantedAuthoritiesConverter(grantedAuthoritiesConverter);
        return converter;
    }
}
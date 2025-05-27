#!/bin/bash

# Script de configuration du projet QuizAcademy
# Version révisée - Configuration complète et fonctionnelle
# Ce script va créer la structure du projet avec tous les fichiers nécessaires

set -e # Le script s'arrête en cas d'erreur

echo "==========================================="
echo "🚀 Configuration du projet QuizAcademy"
echo "==========================================="
echo "Ce script va configurer l'environnement de développement complet"
echo ""

# Vérification des prérequis
echo "📋 Vérification des prérequis..."

command -v docker >/dev/null 2>&1 || { echo "❌ Docker n'est pas installé. Veuillez l'installer avant de continuer." >&2; exit 1; }
command -v docker-compose >/dev/null 2>&1 || { echo "❌ Docker Compose n'est pas installé. Veuillez l'installer avant de continuer." >&2; exit 1; }
command -v java >/dev/null 2>&1 || { echo "⚠️  Java n'est pas installé. Il sera nécessaire pour le développement local." >&2; }
command -v node >/dev/null 2>&1 || { echo "⚠️  Node.js n'est pas installé. Il sera nécessaire pour le développement local." >&2; }
command -v flutter >/dev/null 2>&1 || { echo "⚠️  Flutter n'est pas installé. Il sera nécessaire pour l'application mobile." >&2; }

echo "✅ Prérequis vérifiés"
echo ""

# Création de la structure des répertoires
echo "📁 Création de la structure des répertoires..."
mkdir -p quizacademy/backend/user-service/src/main/java/com/quizacademy/userservice/{controller,model,repository,security,service,dto,config}
mkdir -p quizacademy/backend/user-service/src/main/resources
mkdir -p quizacademy/backend/user-service/src/test/java
mkdir -p quizacademy/backend/content-service/src/{controllers,models,routes,services,middleware}
mkdir -p quizacademy/backend/content-service/tests
mkdir -p quizacademy/mobile/lib/{models,providers,screens/{auth,questions,profile},services,widgets,config,utils}
mkdir -p quizacademy/mobile/assets/images
mkdir -p quizacademy/docs
mkdir -p quizacademy/scripts

cd quizacademy
echo "✅ Structure des répertoires créée"
echo ""

# ===========================================
# SERVICE UTILISATEURS (JAVA/SPRING BOOT)
# ===========================================

echo "☕ Configuration du service utilisateur (Java/Spring Boot)..."

# Build configuration
cat > backend/user-service/build.gradle << 'EOF'
plugins {
    id 'org.springframework.boot' version '3.1.5'
    id 'io.spring.dependency-management' version '1.1.3'
    id 'java'
}

group = 'com.quizacademy'
version = '1.0.0'
sourceCompatibility = '17'

repositories {
    mavenCentral()
}

dependencies {
    implementation 'org.springframework.boot:spring-boot-starter-web'
    implementation 'org.springframework.boot:spring-boot-starter-data-jpa'
    implementation 'org.springframework.boot:spring-boot-starter-security'
    implementation 'org.springframework.boot:spring-boot-starter-validation'
    implementation 'org.springframework.boot:spring-boot-starter-actuator'
    implementation 'io.jsonwebtoken:jjwt-api:0.11.5'
    implementation 'io.jsonwebtoken:jjwt-impl:0.11.5'
    implementation 'io.jsonwebtoken:jjwt-jackson:0.11.5'
    runtimeOnly 'com.h2database:h2'
    testImplementation 'org.springframework.boot:spring-boot-starter-test'
    testImplementation 'org.springframework.security:spring-security-test'
}

test {
    useJUnitPlatform()
}

jar {
    enabled = false
}
EOF

cat > backend/user-service/settings.gradle << 'EOF'
rootProject.name = 'user-service'
EOF

# Gradle wrapper
cat > backend/user-service/gradlew << 'EOF'
#!/bin/sh
exec java -jar gradle/wrapper/gradle-wrapper.jar "$@"
EOF

chmod +x backend/user-service/gradlew

# Dockerfile optimisé
cat > backend/user-service/Dockerfile << 'EOF'
FROM gradle:8.4-jdk17 as build
WORKDIR /app
COPY build.gradle settings.gradle ./
COPY src ./src
RUN gradle build --no-daemon -x test

FROM openjdk:17-jdk-slim
WORKDIR /app
COPY --from=build /app/build/libs/*.jar app.jar
EXPOSE 8080
HEALTHCHECK --interval=30s --timeout=10s --start-period=30s --retries=3 \
  CMD curl -f http://localhost:8080/actuator/health || exit 1
ENTRYPOINT ["java", "-jar", "app.jar"]
EOF

# Application principale
cat > backend/user-service/src/main/java/com/quizacademy/userservice/UserServiceApplication.java << 'EOF'
package com.quizacademy.userservice;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;

@SpringBootApplication
public class UserServiceApplication {
    public static void main(String[] args) {
        SpringApplication.run(UserServiceApplication.class, args);
    }
}
EOF

# Configuration application
cat > backend/user-service/src/main/resources/application.yml << 'EOF'
server:
  port: 8080

spring:
  application:
    name: user-service
  datasource:
    url: jdbc:h2:mem:userdb;DB_CLOSE_DELAY=-1;DB_CLOSE_ON_EXIT=FALSE
    driver-class-name: org.h2.Driver
    username: sa
    password: password
  jpa:
    database-platform: org.hibernate.dialect.H2Dialect
    hibernate:
      ddl-auto: update
    show-sql: false
  h2:
    console:
      enabled: true
      path: /h2-console

jwt:
  secret: ${JWT_SECRET:your_jwt_secret_key_here_make_it_very_long_and_secure}
  expirationMs: 86400000

management:
  endpoints:
    web:
      exposure:
        include: health,info
  endpoint:
    health:
      show-details: always

logging:
  level:
    com.quizacademy: INFO
    org.springframework.security: INFO
EOF

# Modèle User complet
cat > backend/user-service/src/main/java/com/quizacademy/userservice/model/User.java << 'EOF'
package com.quizacademy.userservice.model;

import com.fasterxml.jackson.annotation.JsonIgnore;
import jakarta.persistence.*;
import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;

import java.time.LocalDateTime;
import java.util.HashSet;
import java.util.Set;

@Entity
@Table(name = "users", uniqueConstraints = {
    @UniqueConstraint(columnNames = "username"),
    @UniqueConstraint(columnNames = "email")
})
public class User {
    
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @NotBlank
    @Size(min = 3, max = 20)
    @Column(nullable = false, unique = true)
    private String username;

    @NotBlank
    @Size(max = 50)
    @Email
    @Column(nullable = false, unique = true)
    private String email;

    @NotBlank
    @Size(min = 6, max = 120)
    @JsonIgnore
    @Column(nullable = false)
    private String password;

    @Column(name = "profile_picture")
    private String profilePicture;

    @Column(name = "first_name")
    private String firstName;

    @Column(name = "last_name")
    private String lastName;

    @ElementCollection(fetch = FetchType.EAGER)
    @CollectionTable(name = "user_roles", joinColumns = @JoinColumn(name = "user_id"))
    @Column(name = "role")
    private Set<String> roles = new HashSet<>();

    @Column(nullable = false)
    private LocalDateTime createdAt;

    @Column(nullable = false)
    private LocalDateTime updatedAt;

    @Column(nullable = false)
    private Boolean active = true;

    public User() {
        this.createdAt = LocalDateTime.now();
        this.updatedAt = LocalDateTime.now();
    }

    public User(String username, String email, String password) {
        this();
        this.username = username;
        this.email = email;
        this.password = password;
        this.roles.add("ROLE_USER");
    }

    @PreUpdate
    public void preUpdate() {
        this.updatedAt = LocalDateTime.now();
    }

    // Getters and Setters
    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }

    public String getUsername() { return username; }
    public void setUsername(String username) { this.username = username; }

    public String getEmail() { return email; }
    public void setEmail(String email) { this.email = email; }

    public String getPassword() { return password; }
    public void setPassword(String password) { this.password = password; }

    public String getProfilePicture() { return profilePicture; }
    public void setProfilePicture(String profilePicture) { this.profilePicture = profilePicture; }

    public String getFirstName() { return firstName; }
    public void setFirstName(String firstName) { this.firstName = firstName; }

    public String getLastName() { return lastName; }
    public void setLastName(String lastName) { this.lastName = lastName; }

    public Set<String> getRoles() { return roles; }
    public void setRoles(Set<String> roles) { this.roles = roles; }

    public LocalDateTime getCreatedAt() { return createdAt; }
    public void setCreatedAt(LocalDateTime createdAt) { this.createdAt = createdAt; }

    public LocalDateTime getUpdatedAt() { return updatedAt; }
    public void setUpdatedAt(LocalDateTime updatedAt) { this.updatedAt = updatedAt; }

    public Boolean getActive() { return active; }
    public void setActive(Boolean active) { this.active = active; }
}
EOF

# DTOs
cat > backend/user-service/src/main/java/com/quizacademy/userservice/dto/LoginRequest.java << 'EOF'
package com.quizacademy.userservice.dto;

import jakarta.validation.constraints.NotBlank;

public class LoginRequest {
    @NotBlank
    private String username;

    @NotBlank
    private String password;

    public LoginRequest() {}

    public LoginRequest(String username, String password) {
        this.username = username;
        this.password = password;
    }

    public String getUsername() { return username; }
    public void setUsername(String username) { this.username = username; }

    public String getPassword() { return password; }
    public void setPassword(String password) { this.password = password; }
}
EOF

cat > backend/user-service/src/main/java/com/quizacademy/userservice/dto/ApiResponse.java << 'EOF'
package com.quizacademy.userservice.dto;

public class ApiResponse {
    private Boolean success;
    private String message;
    private Object data;

    public ApiResponse(Boolean success, String message) {
        this.success = success;
        this.message = message;
    }

    public ApiResponse(Boolean success, String message, Object data) {
        this.success = success;
        this.message = message;
        this.data = data;
    }

    // Getters and Setters
    public Boolean getSuccess() { return success; }
    public void setSuccess(Boolean success) { this.success = success; }

    public String getMessage() { return message; }
    public void setMessage(String message) { this.message = message; }

    public Object getData() { return data; }
    public void setData(Object data) { this.data = data; }
}
EOF

# Repository
cat > backend/user-service/src/main/java/com/quizacademy/userservice/repository/UserRepository.java << 'EOF'
package com.quizacademy.userservice.repository;

import com.quizacademy.userservice.model.User;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.Optional;

@Repository
public interface UserRepository extends JpaRepository<User, Long> {
    Optional<User> findByUsername(String username);
    Optional<User> findByEmail(String email);
    Boolean existsByUsername(String username);
    Boolean existsByEmail(String email);
}
EOF

# JWT Token Provider
cat > backend/user-service/src/main/java/com/quizacademy/userservice/security/JwtTokenProvider.java << 'EOF'
package com.quizacademy.userservice.security;

import io.jsonwebtoken.*;
import io.jsonwebtoken.security.Keys;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.security.core.Authentication;
import org.springframework.stereotype.Component;

import javax.crypto.SecretKey;
import java.util.Date;
import java.util.Set;

@Component
public class JwtTokenProvider {

    private static final Logger logger = LoggerFactory.getLogger(JwtTokenProvider.class);

    @Value("${jwt.secret}")
    private String jwtSecret;

    @Value("${jwt.expirationMs}")
    private long jwtExpirationMs;

    public String generateToken(String username, Set<String> roles) {
        Date expiryDate = new Date(System.currentTimeMillis() + jwtExpirationMs);
        
        SecretKey key = Keys.hmacShaKeyFor(jwtSecret.getBytes());

        return Jwts.builder()
                .setSubject(username)
                .claim("roles", roles)
                .setIssuedAt(new Date())
                .setExpiration(expiryDate)
                .signWith(key)
                .compact();
    }

    public String getUsernameFromToken(String token) {
        SecretKey key = Keys.hmacShaKeyFor(jwtSecret.getBytes());
        
        Claims claims = Jwts.parserBuilder()
                .setSigningKey(key)
                .build()
                .parseClaimsJws(token)
                .getBody();

        return claims.getSubject();
    }

    public boolean validateToken(String authToken) {
        try {
            SecretKey key = Keys.hmacShaKeyFor(jwtSecret.getBytes());
            
            Jwts.parserBuilder()
                .setSigningKey(key)
                .build()
                .parseClaimsJws(authToken);
            return true;
        } catch (MalformedJwtException ex) {
            logger.error("Invalid JWT token");
        } catch (ExpiredJwtException ex) {
            logger.error("Expired JWT token");
        } catch (UnsupportedJwtException ex) {
            logger.error("Unsupported JWT token");
        } catch (IllegalArgumentException ex) {
            logger.error("JWT claims string is empty.");
        }
        return false;
    }
}
EOF

# Custom User Details Service
cat > backend/user-service/src/main/java/com/quizacademy/userservice/security/UserDetailsServiceImpl.java << 'EOF'
package com.quizacademy.userservice.security;

import com.quizacademy.userservice.model.User;
import com.quizacademy.userservice.repository.UserRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.core.authority.SimpleGrantedAuthority;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.security.core.userdetails.UserDetailsService;
import org.springframework.security.core.userdetails.UsernameNotFoundException;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.stream.Collectors;

@Service
public class UserDetailsServiceImpl implements UserDetailsService {
    
    @Autowired
    UserRepository userRepository;

    @Override
    @Transactional
    public UserDetails loadUserByUsername(String username) throws UsernameNotFoundException {
        User user = userRepository.findByUsername(username)
                .orElseThrow(() -> new UsernameNotFoundException("User Not Found: " + username));

        return org.springframework.security.core.userdetails.User.builder()
                .username(user.getUsername())
                .password(user.getPassword())
                .authorities(user.getRoles().stream()
                        .map(SimpleGrantedAuthority::new)
                        .collect(Collectors.toList()))
                .build();
    }
}
EOF

# Security Configuration
cat > backend/user-service/src/main/java/com/quizacademy/userservice/security/WebSecurityConfig.java << 'EOF'
package com.quizacademy.userservice.security;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.security.authentication.AuthenticationManager;
import org.springframework.security.authentication.dao.DaoAuthenticationProvider;
import org.springframework.security.config.annotation.authentication.configuration.AuthenticationConfiguration;
import org.springframework.security.config.annotation.method.configuration.EnableMethodSecurity;
import org.springframework.security.config.annotation.web.builders.HttpSecurity;
import org.springframework.security.config.annotation.web.configuration.EnableWebSecurity;
import org.springframework.security.config.http.SessionCreationPolicy;
import org.springframework.security.core.userdetails.UserDetailsService;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.security.web.SecurityFilterChain;
import org.springframework.web.cors.CorsConfiguration;
import org.springframework.web.cors.CorsConfigurationSource;
import org.springframework.web.cors.UrlBasedCorsConfigurationSource;

import java.util.Arrays;

@Configuration
@EnableWebSecurity
@EnableMethodSecurity(prePostEnabled = true)
public class WebSecurityConfig {

    @Autowired
    UserDetailsService userDetailsService;

    @Bean
    public PasswordEncoder passwordEncoder() {
        return new BCryptPasswordEncoder();
    }

    @Bean
    public DaoAuthenticationProvider authenticationProvider() {
        DaoAuthenticationProvider authProvider = new DaoAuthenticationProvider();
        authProvider.setUserDetailsService(userDetailsService);
        authProvider.setPasswordEncoder(passwordEncoder());
        return authProvider;
    }

    @Bean
    public AuthenticationManager authenticationManager(AuthenticationConfiguration authConfig) throws Exception {
        return authConfig.getAuthenticationManager();
    }

    @Bean
    public SecurityFilterChain filterChain(HttpSecurity http) throws Exception {
        http.cors().and().csrf().disable()
                .sessionManagement().sessionCreationPolicy(SessionCreationPolicy.STATELESS)
                .and()
                .authorizeHttpRequests()
                .requestMatchers("/api/auth/**").permitAll()
                .requestMatchers("/h2-console/**").permitAll()
                .requestMatchers("/actuator/**").permitAll()
                .anyRequest().authenticated();

        http.headers().frameOptions().disable();
        http.authenticationProvider(authenticationProvider());

        return http.build();
    }

    @Bean
    public CorsConfigurationSource corsConfigurationSource() {
        CorsConfiguration configuration = new CorsConfiguration();
        configuration.setAllowedOriginPatterns(Arrays.asList("*"));
        configuration.setAllowedMethods(Arrays.asList("GET", "POST", "PUT", "PATCH", "DELETE", "OPTIONS"));
        configuration.setAllowedHeaders(Arrays.asList("authorization", "content-type", "x-auth-token"));
        configuration.setExposedHeaders(Arrays.asList("x-auth-token"));
        configuration.setAllowCredentials(true);
        
        UrlBasedCorsConfigurationSource source = new UrlBasedCorsConfigurationSource();
        source.registerCorsConfiguration("/**", configuration);
        return source;
    }
}
EOF

# Service d'authentification
cat > backend/user-service/src/main/java/com/quizacademy/userservice/service/AuthService.java << 'EOF'
package com.quizacademy.userservice.service;

import com.quizacademy.userservice.model.User;
import com.quizacademy.userservice.repository.UserRepository;
import com.quizacademy.userservice.security.JwtTokenProvider;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.authentication.AuthenticationManager;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;
import java.util.HashMap;
import java.util.Map;
import java.util.Set;

@Service
public class AuthService {

    @Autowired
    AuthenticationManager authenticationManager;

    @Autowired
    UserRepository userRepository;

    @Autowired
    PasswordEncoder encoder;

    @Autowired
    JwtTokenProvider jwtUtils;

    public User registerUser(User user) {
        if (userRepository.existsByUsername(user.getUsername())) {
            throw new RuntimeException("Error: Username is already taken!");
        }

        if (userRepository.existsByEmail(user.getEmail())) {
            throw new RuntimeException("Error: Email is already in use!");
        }

        // Create new user account
        user.setPassword(encoder.encode(user.getPassword()));
        user.setRoles(Set.of("ROLE_USER"));
        user.setCreatedAt(LocalDateTime.now());
        user.setUpdatedAt(LocalDateTime.now());
        user.setActive(true);

        return userRepository.save(user);
    }

    public Map<String, Object> authenticateUser(String username, String password) {
        Authentication authentication = authenticationManager.authenticate(
                new UsernamePasswordAuthenticationToken(username, password));

        SecurityContextHolder.getContext().setAuthentication(authentication);
        String jwt = jwtUtils.generateToken(username, Set.of("ROLE_USER"));

        User user = userRepository.findByUsername(username)
                .orElseThrow(() -> new RuntimeException("User not found"));

        Map<String, Object> response = new HashMap<>();
        response.put("token", jwt);
        response.put("type", "Bearer");
        response.put("user", user);

        return response;
    }
}
EOF

# Contrôleur d'authentification
cat > backend/user-service/src/main/java/com/quizacademy/userservice/controller/AuthController.java << 'EOF'
package com.quizacademy.userservice.controller;

import com.quizacademy.userservice.dto.ApiResponse;
import com.quizacademy.userservice.dto.LoginRequest;
import com.quizacademy.userservice.model.User;
import com.quizacademy.userservice.service.AuthService;
import jakarta.validation.Valid;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.Map;

@CrossOrigin(origins = "*", maxAge = 3600)
@RestController
@RequestMapping("/api/auth")
public class AuthController {
    
    @Autowired
    AuthService authService;

    @PostMapping("/login")
    public ResponseEntity<?> authenticateUser(@Valid @RequestBody LoginRequest loginRequest) {
        try {
            Map<String, Object> response = authService.authenticateUser(
                    loginRequest.getUsername(),
                    loginRequest.getPassword()
            );
            
            return ResponseEntity.ok(response);
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED)
                    .body(new ApiResponse(false, "Invalid credentials: " + e.getMessage()));
        }
    }

    @PostMapping("/register")
    public ResponseEntity<?> registerUser(@Valid @RequestBody User user) {
        try {
            User result = authService.registerUser(user);
            result.setPassword(null); // Don't return password
            
            return ResponseEntity.status(HttpStatus.CREATED)
                    .body(new ApiResponse(true, "User registered successfully", result));
        } catch (Exception e) {
            return ResponseEntity.badRequest()
                    .body(new ApiResponse(false, e.getMessage()));
        }
    }

    @GetMapping("/health")
    public ResponseEntity<?> healthCheck() {
        return ResponseEntity.ok(new ApiResponse(true, "User service is running"));
    }
}
EOF

echo "✅ Service utilisateur configuré"

# ===========================================
# SERVICE CONTENT (NODE.JS/EXPRESS)
# ===========================================

echo "🚀 Configuration du service content (Node.js/Express)..."

# Package.json
cat > backend/content-service/package.json << 'EOF'
{
  "name": "content-service",
  "version": "1.0.0",
  "description": "Service de gestion du contenu pour QuizAcademy",
  "main": "src/index.js",
  "scripts": {
    "start": "node src/index.js",
    "dev": "nodemon src/index.js",
    "test": "jest",
    "lint": "eslint src/"
  },
  "dependencies": {
    "express": "^4.18.2",
    "mongoose": "^7.6.3",
    "cors": "^2.8.5",
    "dotenv": "^16.3.1",
    "jsonwebtoken": "^9.0.2",
    "morgan": "^1.10.0",
    "helmet": "^7.0.0",
    "express-rate-limit": "^7.1.3",
    "express-validator": "^7.0.1"
  },
  "devDependencies": {
    "nodemon": "^3.0.1",
    "jest": "^29.7.0",
    "eslint": "^8.51.0"
  },
  "keywords": ["nodejs", "express", "mongodb", "microservice"],
  "author": "QuizAcademy Team",
  "license": "MIT"
}
EOF

# Dockerfile
cat > backend/content-service/Dockerfile << 'EOF'
FROM node:18-alpine

WORKDIR /app

COPY package*.json ./
RUN npm ci --only=production

COPY . .

EXPOSE 3000

HEALTHCHECK --interval=30s --timeout=10s --start-period=30s --retries=3 \
  CMD node healthcheck.js || exit 1

USER node

CMD ["npm", "start"]
EOF

# Healthcheck
cat > backend/content-service/healthcheck.js << 'EOF'
const http = require('http');

const options = {
  hostname: 'localhost',
  port: 3000,
  path: '/health',
  method: 'GET',
  timeout: 2000
};

const req = http.request(options, (res) => {
  if (res.statusCode === 200) {
    process.exit(0);
  } else {
    process.exit(1);
  }
});

req.on('error', () => {
  process.exit(1);
});

req.on('timeout', () => {
  req.destroy();
  process.exit(1);
});

req.end();
EOF

# Fichier principal
cat > backend/content-service/src/index.js << 'EOF'
const express = require('express');
const mongoose = require('mongoose');
const cors = require('cors');
const morgan = require('morgan');
const helmet = require('helmet');
const rateLimit = require('express-rate-limit');
require('dotenv').config();

// Routes
const categoryRoutes = require('./routes/category.routes');
const questionRoutes = require('./routes/question.routes');
const answerRoutes = require('./routes/answer.routes');

const app = express();
const PORT = process.env.PORT || 3000;
const MONGODB_URI = process.env.MONGODB_URI || 'mongodb://localhost:27017/quizacademy';

// Rate limiting
const limiter = rateLimit({
  windowMs: 15 * 60 * 1000, // 15 minutes
  max: 100 // limit each IP to 100 requests per windowMs
});

// Middleware
app.use(helmet());
app.use(limiter);
app.use(cors({
  origin: '*',
  methods: ['GET', 'POST', 'PUT', 'DELETE', 'OPTIONS'],
  allowedHeaders: ['Content-Type', 'Authorization']
}));
app.use(express.json({ limit: '10mb' }));
app.use(express.urlencoded({ extended: true }));
app.use(morgan('combined'));

// Connect to MongoDB
mongoose.connect(MONGODB_URI, {
  useNewUrlParser: true,
  useUnifiedTopology: true,
})
.then(() => {
  console.log('✅ Connected to MongoDB');
})
.catch(err => {
  console.error('❌ MongoDB connection error:', err);
  process.exit(1);
});

// Routes
app.use('/api/categories', categoryRoutes);
app.use('/api/questions', questionRoutes);
app.use('/api/answers', answerRoutes);

// Health check
app.get('/health', (req, res) => {
  res.status(200).json({
    status: 'OK',
    timestamp: new Date().toISOString(),
    service: 'content-service',
    version: '1.0.0'
  });
});

// Root endpoint
app.get('/', (req, res) => {
  res.json({
    message: 'QuizAcademy Content Service API',
    version: '1.0.0',
    status: 'Running'
  });
});

// Error handling middleware
app.use((err, req, res, next) => {
  console.error(err.stack);
  res.status(500).json({
    error: 'Something went wrong!',
    message: process.env.NODE_ENV === 'development' ? err.message : 'Internal server error'
  });
});

// 404 handler
app.use('*', (req, res) => {
  res.status(404).json({
    error: 'Route not found',
    path: req.originalUrl
  });
});

// Start server
const server = app.listen(PORT, '0.0.0.0', () => {
  console.log(`🚀 Content Service running on port ${PORT}`);
});

// Graceful shutdown
process.on('SIGTERM', () => {
  console.log('SIGTERM received, shutting down gracefully');
  server.close(() => {
    console.log('Process terminated');
    mongoose.connection.close();
  });
});

module.exports = app;
EOF

# Configuration d'environnement
cat > backend/content-service/.env << 'EOF'
NODE_ENV=production
PORT=3000
MONGODB_URI=mongodb://mongodb:27017/quizacademy
USER_SERVICE_URL=http://user-service:8080
JWT_SECRET=your_jwt_secret_key_here_make_it_very_long_and_secure
EOF

# Service d'authentification
cat > backend/content-service/src/services/auth.service.js << 'EOF'
const jwt = require('jsonwebtoken');
const JWT_SECRET = process.env.JWT_SECRET || 'your_jwt_secret_key_here_make_it_very_long_and_secure';

class AuthService {
  verifyToken(req) {
    try {
      const authHeader = req.headers.authorization;
      if (!authHeader || !authHeader.startsWith('Bearer ')) {
        return null;
      }

      const token = authHeader.split(' ')[1];
      const decodedToken = jwt.verify(token, JWT_SECRET);
      
      return {
        userId: decodedToken.sub,
        username: decodedToken.sub,
        roles: decodedToken.roles || ['ROLE_USER']
      };
    } catch (error) {
      console.error('Token verification error:', error);
      return null;
    }
  }

  requireAuth(req, res, next) {
    const user = this.verifyToken(req);
    if (!user) {
      return res.status(401).json({ error: 'Unauthorized' });
    }
    req.user = user;
    next();
  }
}

module.exports = new AuthService();
EOF

# Modèles
cat > backend/content-service/src/models/category.model.js << 'EOF'
const mongoose = require('mongoose');

const CategorySchema = new mongoose.Schema({
  name: {
    type: String,
    required: true,
    unique: true,
    trim: true,
    minlength: 2,
    maxlength: 50
  },
  description: {
    type: String,
    required: true,
    trim: true,
    maxlength: 200
  },
  color: {
    type: String,
    default: '#007bff'
  },
  icon: {
    type: String,
    default: 'book'
  },
  isActive: {
    type: Boolean,
    default: true
  }
}, {
  timestamps: true
});

CategorySchema.index({ name: 1 });

module.exports = mongoose.model('Category', CategorySchema);
EOF

cat > backend/content-service/src/models/question.model.js << 'EOF'
const mongoose = require('mongoose');

const QuestionSchema = new mongoose.Schema({
  title: {
    type: String,
    required: true,
    trim: true,
    minlength: 5,
    maxlength: 200
  },
  content: {
    type: String,
    required: true,
    trim: true,
    minlength: 10,
    maxlength: 5000
  },
  authorId: {
    type: String,
    required: true,
    index: true
  },
  authorName: {
    type: String,
    required: true
  },
  categoryId: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'Category',
    required: true,
    index: true
  },
  tags: [{
    type: String,
    trim: true,
    maxlength: 30
  }],
  viewCount: {
    type: Number,
    default: 0,
    min: 0
  },
  answerCount: {
    type: Number,
    default: 0,
    min: 0
  },
  isActive: {
    type: Boolean,
    default: true
  }
}, {
  timestamps: true
});

// Text search index
QuestionSchema.index({
  title: 'text',
  content: 'text',
  tags: 'text'
});

// Compound indexes
QuestionSchema.index({ categoryId: 1, createdAt: -1 });
QuestionSchema.index({ authorId: 1, createdAt: -1 });

module.exports = mongoose.model('Question', QuestionSchema);
EOF

cat > backend/content-service/src/models/answer.model.js << 'EOF'
const mongoose = require('mongoose');

const VoteSchema = new mongoose.Schema({
  userId: {
    type: String,
    required: true
  },
  vote: {
    type: Number,
    required: true,
    enum: [1, -1]
  }
}, { _id: false });

const AnswerSchema = new mongoose.Schema({
  questionId: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'Question',
    required: true,
    index: true
  },
  content: {
    type: String,
    required: true,
    trim: true,
    minlength: 5,
    maxlength: 3000
  },
  authorId: {
    type: String,
    required: true,
    index: true
  },
  authorName: {
    type: String,
    required: true
  },
  votes: [VoteSchema],
  score: {
    type: Number,
    default: 0
  },
  isAccepted: {
    type: Boolean,
    default: false
  },
  isActive: {
    type: Boolean,
    default: true
  }
}, {
  timestamps: true
});

// Indexes
AnswerSchema.index({ questionId: 1, score: -1 });
AnswerSchema.index({ authorId: 1, createdAt: -1 });

// Update question answer count on save/remove
AnswerSchema.post('save', async function() {
  const Question = mongoose.model('Question');
  const count = await mongoose.model('Answer').countDocuments({ 
    questionId: this.questionId,
    isActive: true 
  });
  await Question.updateOne(
    { _id: this.questionId },
    { answerCount: count }
  );
});

module.exports = mongoose.model('Answer', AnswerSchema);
EOF

# Contrôleurs
cat > backend/content-service/src/controllers/category.controller.js << 'EOF'
const Category = require('../models/category.model');
const { validationResult } = require('express-validator');

class CategoryController {
  async getAllCategories(req, res) {
    try {
      const categories = await Category.find({ isActive: true })
        .sort({ name: 1 })
        .select('-__v');
      
      res.json({
        success: true,
        data: categories,
        count: categories.length
      });
    } catch (error) {
      console.error('Error fetching categories:', error);
      res.status(500).json({
        success: false,
        error: 'Failed to fetch categories'
      });
    }
  }

  async createCategory(req, res) {
    try {
      const errors = validationResult(req);
      if (!errors.isEmpty()) {
        return res.status(400).json({
          success: false,
          errors: errors.array()
        });
      }

      const { name, description, color, icon } = req.body;
      
      const existingCategory = await Category.findOne({ 
        name: { $regex: new RegExp(`^${name}$`, 'i') }
      });
      
      if (existingCategory) {
        return res.status(400).json({
          success: false,
          error: 'Category with this name already exists'
        });
      }

      const category = new Category({
        name,
        description,
        color: color || '#007bff',
        icon: icon || 'book'
      });

      const savedCategory = await category.save();
      
      res.status(201).json({
        success: true,
        data: savedCategory
      });
    } catch (error) {
      console.error('Error creating category:', error);
      res.status(500).json({
        success: false,
        error: 'Failed to create category'
      });
    }
  }

  async getCategoryById(req, res) {
    try {
      const { id } = req.params;
      
      const category = await Category.findById(id).select('-__v');
      if (!category || !category.isActive) {
        return res.status(404).json({
          success: false,
          error: 'Category not found'
        });
      }

      res.json({
        success: true,
        data: category
      });
    } catch (error) {
      console.error('Error fetching category:', error);
      res.status(500).json({
        success: false,
        error: 'Failed to fetch category'
      });
    }
  }
}

module.exports = new CategoryController();
EOF

cat > backend/content-service/src/controllers/question.controller.js << 'EOF'
const Question = require('../models/question.model');
const Answer = require('../models/answer.model');
const Category = require('../models/category.model');
const authService = require('../services/auth.service');
const { validationResult } = require('express-validator');

class QuestionController {
  async createQuestion(req, res) {
    try {
      const errors = validationResult(req);
      if (!errors.isEmpty()) {
        return res.status(400).json({
          success: false,
          errors: errors.array()
        });
      }

      const user = authService.verifyToken(req);
      if (!user) {
        return res.status(401).json({
          success: false,
          error: 'Unauthorized'
        });
      }

      const { title, content, categoryId, tags } = req.body;

      // Verify category exists
      const category = await Category.findById(categoryId);
      if (!category || !category.isActive) {
        return res.status(400).json({
          success: false,
          error: 'Invalid category'
        });
      }

      const question = new Question({
        title,
        content,
        categoryId,
        tags: tags || [],
        authorId: user.userId,
        authorName: user.username
      });

      const savedQuestion = await question.save();
      await savedQuestion.populate('categoryId', 'name description');

      res.status(201).json({
        success: true,
        data: savedQuestion
      });
    } catch (error) {
      console.error('Error creating question:', error);
      res.status(500).json({
        success: false,
        error: 'Failed to create question'
      });
    }
  }

  async getQuestionsByCategory(req, res) {
    try {
      const { categoryId } = req.params;
      const page = parseInt(req.query.page) || 1;
      const limit = Math.min(parseInt(req.query.limit) || 10, 50);
      const skip = (page - 1) * limit;

      // Verify category exists
      const category = await Category.findById(categoryId);
      if (!category || !category.isActive) {
        return res.status(404).json({
          success: false,
          error: 'Category not found'
        });
      }

      const questions = await Question.find({ 
        categoryId, 
        isActive: true 
      })
        .sort({ createdAt: -1 })
        .skip(skip)
        .limit(limit)
        .populate('categoryId', 'name description')
        .select('-__v');

      const totalQuestions = await Question.countDocuments({ 
        categoryId, 
        isActive: true 
      });

      const totalPages = Math.ceil(totalQuestions / limit);

      res.json({
        success: true,
        data: {
          questions,
          pagination: {
            currentPage: page,
            totalPages,
            totalItems: totalQuestions,
            hasMore: page < totalPages,
            itemsPerPage: limit
          }
        }
      });
    } catch (error) {
      console.error('Error fetching questions:', error);
      res.status(500).json({
        success: false,
        error: 'Failed to fetch questions'
      });
    }
  }

  async getQuestionById(req, res) {
    try {
      const { id } = req.params;

      const question = await Question.findById(id)
        .populate('categoryId', 'name description')
        .select('-__v');

      if (!question || !question.isActive) {
        return res.status(404).json({
          success: false,
          error: 'Question not found'
        });
      }

      // Increment view count
      await Question.updateOne(
        { _id: id },
        { $inc: { viewCount: 1 } }
      );
      question.viewCount += 1;

      // Get answers
      const answers = await Answer.find({ 
        questionId: id, 
        isActive: true 
      })
        .sort({ isAccepted: -1, score: -1, createdAt: -1 })
        .select('-__v');

      res.json({
        success: true,
        data: {
          question,
          answers
        }
      });
    } catch (error) {
      console.error('Error fetching question:', error);
      res.status(500).json({
        success: false,
        error: 'Failed to fetch question'
      });
    }
  }

  async searchQuestions(req, res) {
    try {
      const { q: query } = req.query;
      const page = parseInt(req.query.page) || 1;
      const limit = Math.min(parseInt(req.query.limit) || 10, 50);
      const skip = (page - 1) * limit;

      if (!query || query.trim().length < 2) {
        return res.status(400).json({
          success: false,
          error: 'Search query must be at least 2 characters long'
        });
      }

      const searchFilter = {
        $text: { $search: query },
        isActive: true
      };

      const questions = await Question.find(searchFilter)
        .sort({ score: { $meta: 'textScore' }, createdAt: -1 })
        .skip(skip)
        .limit(limit)
        .populate('categoryId', 'name description')
        .select('-__v');

      const totalQuestions = await Question.countDocuments(searchFilter);
      const totalPages = Math.ceil(totalQuestions / limit);

      res.json({
        success: true,
        data: {
          questions,
          pagination: {
            currentPage: page,
            totalPages,
            totalItems: totalQuestions,
            hasMore: page < totalPages,
            itemsPerPage: limit
          },
          query
        }
      });
    } catch (error) {
      console.error('Error searching questions:', error);
      res.status(500).json({
        success: false,
        error: 'Failed to search questions'
      });
    }
  }
}

module.exports = new QuestionController();
EOF

cat > backend/content-service/src/controllers/answer.controller.js << 'EOF'
const Answer = require('../models/answer.model');
const Question = require('../models/question.model');
const authService = require('../services/auth.service');
const { validationResult } = require('express-validator');

class AnswerController {
  async createAnswer(req, res) {
    try {
      const errors = validationResult(req);
      if (!errors.isEmpty()) {
        return res.status(400).json({
          success: false,
          errors: errors.array()
        });
      }

      const user = authService.verifyToken(req);
      if (!user) {
        return res.status(401).json({
          success: false,
          error: 'Unauthorized'
        });
      }

      const { questionId } = req.params;
      const { content } = req.body;

      // Verify question exists
      const question = await Question.findById(questionId);
      if (!question || !question.isActive) {
        return res.status(404).json({
          success: false,
          error: 'Question not found'
        });
      }

      const answer = new Answer({
        questionId,
        content,
        authorId: user.userId,
        authorName: user.username
      });

      const savedAnswer = await answer.save();

      res.status(201).json({
        success: true,
        data: savedAnswer
      });
    } catch (error) {
      console.error('Error creating answer:', error);
      res.status(500).json({
        success: false,
        error: 'Failed to create answer'
      });
    }
  }

  async voteAnswer(req, res) {
    try {
      const errors = validationResult(req);
      if (!errors.isEmpty()) {
        return res.status(400).json({
          success: false,
          errors: errors.array()
        });
      }

      const user = authService.verifyToken(req);
      if (!user) {
        return res.status(401).json({
          success: false,
          error: 'Unauthorized'
        });
      }

      const { answerId } = req.params;
      const { vote } = req.body;

      if (![1, -1].includes(vote)) {
        return res.status(400).json({
          success: false,
          error: 'Vote must be 1 (upvote) or -1 (downvote)'
        });
      }

      const answer = await Answer.findById(answerId);
      if (!answer || !answer.isActive) {
        return res.status(404).json({
          success: false,
          error: 'Answer not found'
        });
      }

      // Check if user already voted
      const existingVoteIndex = answer.votes.findIndex(
        v => v.userId === user.userId
      );

      if (existingVoteIndex !== -1) {
        const existingVote = answer.votes[existingVoteIndex];
        
        if (existingVote.vote === vote) {
          // Remove vote (toggle off)
          answer.votes.splice(existingVoteIndex, 1);
          answer.score -= vote;
        } else {
          // Change vote
          answer.score -= existingVote.vote;
          answer.score += vote;
          existingVote.vote = vote;
        }
      } else {
        // Add new vote
        answer.votes.push({ userId: user.userId, vote });
        answer.score += vote;
      }

      const updatedAnswer = await answer.save();

      res.json({
        success: true,
        data: updatedAnswer
      });
    } catch (error) {
      console.error('Error voting for answer:', error);
      res.status(500).json({
        success: false,
        error: 'Failed to vote for answer'
      });
    }
  }

  async getAnswersByQuestion(req, res) {
    try {
      const { questionId } = req.params;

      // Verify question exists
      const question = await Question.findById(questionId);
      if (!question || !question.isActive) {
        return res.status(404).json({
          success: false,
          error: 'Question not found'
        });
      }

      const answers = await Answer.find({ 
        questionId, 
        isActive: true 
      })
        .sort({ isAccepted: -1, score: -1, createdAt: -1 })
        .select('-__v');

      res.json({
        success: true,
        data: answers
      });
    } catch (error) {
      console.error('Error fetching answers:', error);
      res.status(500).json({
        success: false,
        error: 'Failed to fetch answers'
      });
    }
  }
}

module.exports = new AnswerController();
EOF

# Routes
cat > backend/content-service/src/routes/category.routes.js << 'EOF'
const express = require('express');
const { body } = require('express-validator');
const categoryController = require('../controllers/category.controller');
const questionController = require('../controllers/question.controller');
const router = express.Router();

// Validation middleware
const validateCategory = [
  body('name')
    .trim()
    .isLength({ min: 2, max: 50 })
    .withMessage('Name must be between 2 and 50 characters'),
  body('description')
    .trim()
    .isLength({ min: 5, max: 200 })
    .withMessage('Description must be between 5 and 200 characters')
];

// Routes
router.get('/', categoryController.getAllCategories);
router.post('/', validateCategory, categoryController.createCategory);
router.get('/:id', categoryController.getCategoryById);
router.get('/:categoryId/questions', questionController.getQuestionsByCategory);

module.exports = router;
EOF

cat > backend/content-service/src/routes/question.routes.js << 'EOF'
const express = require('express');
const { body } = require('express-validator');
const questionController = require('../controllers/question.controller');
const answerController = require('../controllers/answer.controller');
const router = express.Router();

// Validation middleware
const validateQuestion = [
  body('title')
    .trim()
    .isLength({ min: 5, max: 200 })
    .withMessage('Title must be between 5 and 200 characters'),
  body('content')
    .trim()
    .isLength({ min: 10, max: 5000 })
    .withMessage('Content must be between 10 and 5000 characters'),
  body('categoryId')
    .isMongoId()
    .withMessage('Invalid category ID'),
  body('tags')
    .optional()
    .isArray()
    .withMessage('Tags must be an array')
];

const validateAnswer = [
  body('content')
    .trim()
    .isLength({ min: 5, max: 3000 })
    .withMessage('Answer content must be between 5 and 3000 characters')
];

// Routes
router.post('/', validateQuestion, questionController.createQuestion);
router.get('/search', questionController.searchQuestions);
router.get('/:id', questionController.getQuestionById);
router.post('/:questionId/answers', validateAnswer, answerController.createAnswer);
router.get('/:questionId/answers', answerController.getAnswersByQuestion);

module.exports = router;
EOF

cat > backend/content-service/src/routes/answer.routes.js << 'EOF'
const express = require('express');
const { body } = require('express-validator');
const answerController = require('../controllers/answer.controller');
const router = express.Router();

// Validation middleware
const validateVote = [
  body('vote')
    .isInt({ min: -1, max: 1 })
    .withMessage('Vote must be 1 (upvote) or -1 (downvote)')
];

// Routes
router.post('/:answerId/vote', validateVote, answerController.voteAnswer);

module.exports = router;
EOF

echo "✅ Service content configuré"

# ===========================================
# DOCKER COMPOSE
# ===========================================

echo "🐳 Configuration Docker Compose..."

cat > backend/docker-compose.yml << 'EOF'
version: '3.8'

services:
  user-service:
    build: 
      context: ./user-service
      dockerfile: Dockerfile
    container_name: quizacademy-user-service
    ports:
      - "8080:8080"
    environment:
      - SPRING_PROFILES_ACTIVE=docker
      - JWT_SECRET=your_jwt_secret_key_here_make_it_very_long_and_secure_for_production_use
    networks:
      - quizacademy-network
    restart: unless-stopped
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:8080/actuator/health"]
      interval: 30s
      timeout: 10s
      retries: 5
      start_period: 40s

  content-service:
    build:
      context: ./content-service
      dockerfile: Dockerfile
    container_name: quizacademy-content-service
    ports:
      - "3000:3000"
    environment:
      - NODE_ENV=production
      - MONGODB_URI=mongodb://mongodb:27017/quizacademy
      - USER_SERVICE_URL=http://user-service:8080
      - JWT_SECRET=your_jwt_secret_key_here_make_it_very_long_and_secure_for_production_use
    depends_on:
      user-service:
        condition: service_healthy
      mongodb:
        condition: service_healthy
    networks:
      - quizacademy-network
    restart: unless-stopped
    healthcheck:
      test: ["CMD", "node", "healthcheck.js"]
      interval: 30s
      timeout: 10s
      retries: 5
      start_period: 40s

  mongodb:
    image: mongo:6.0
    container_name: quizacademy-mongodb
    ports:
      - "27017:27017"
    environment:
      - MONGO_INITDB_DATABASE=quizacademy
    volumes:
      - mongodb_data:/data/db
      - ./mongo-init.js:/docker-entrypoint-initdb.d/mongo-init.js:ro
    networks:
      - quizacademy-network
    restart: unless-stopped
    healthcheck:
      test: ["CMD", "mongosh", "--eval", "db.adminCommand('ping')"]
      interval: 30s
      timeout: 10s
      retries: 5
      start_period: 40s

networks:
  quizacademy-network:
    driver: bridge
    name: quizacademy-network

volumes:
  mongodb_data:
    name: quizacademy-mongodb-data
EOF

# Script d'initialisation MongoDB
cat > backend/mongo-init.js << 'EOF'
// MongoDB initialization script
db = db.getSiblingDB('quizacademy');

// Create collections
db.createCollection('categories');
db.createCollection('questions');
db.createCollection('answers');

// Insert default categories
db.categories.insertMany([
  {
    name: 'Mathématiques',
    description: 'Questions relatives aux mathématiques',
    color: '#007bff',
    icon: 'calculator',
    isActive: true,
    createdAt: new Date(),
    updatedAt: new Date()
  },
  {
    name: 'Informatique',
    description: 'Questions sur la programmation et l\'informatique',
    color: '#28a745',
    icon: 'laptop',
    isActive: true,
    createdAt: new Date(),
    updatedAt: new Date()
  },
  {
    name: 'Physique',
    description: 'Questions de physique générale',
    color: '#ffc107',
    icon: 'atom',
    isActive: true,
    createdAt: new Date(),
    updatedAt: new Date()
  },
  {
    name: 'Chimie',
    description: 'Questions de chimie',
    color: '#dc3545',
    icon: 'flask',
    isActive: true,
    createdAt: new Date(),
    updatedAt: new Date()
  }
]);

print('Database initialized successfully!');
EOF

echo "✅ Docker Compose configuré"

# ===========================================
# APPLICATION FLUTTER
# ===========================================

echo "📱 Configuration de l'application Flutter..."

# pubspec.yaml
cat > mobile/pubspec.yaml << 'EOF'
name: quizacademy
description: A Q&A platform for academic knowledge sharing

publish_to: 'none'
version: 1.0.0+1

environment:
  sdk: '>=3.0.0 <4.0.0'
  flutter: ">=3.10.0"

dependencies:
  flutter:
    sdk: flutter
  
  # HTTP & Networking
  http: ^1.1.0
  
  # State Management
  provider: ^6.1.0
  
  # Local Storage
  shared_preferences: ^2.2.2
  
  # UI & Utilities
  intl: ^0.18.1
  flutter_markdown: ^0.6.18
  
  # Icons
  cupertino_icons: ^1.0.6

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^3.0.0

flutter:
  uses-material-design: true
  
  assets:
    - assets/images/
    
  fonts:
    - family: Roboto
      fonts:
        - asset: fonts/Roboto-Regular.ttf
        - asset: fonts/Roboto-Bold.ttf
          weight: 700
EOF

# Configuration API
cat > mobile/lib/config/api_config.dart << 'EOF'
class ApiConfig {
  // Pour l'émulateur Android
  static const String userServiceBaseUrl = 'http://10.0.2.2:8080/api';
  static const String contentServiceBaseUrl = 'http://10.0.2.2:3000/api';
  
  // Pour un dispositif physique, remplacez par l'IP de votre machine
  // static const String userServiceBaseUrl = 'http://192.168.1.100:8080/api';
  // static const String contentServiceBaseUrl = 'http://192.168.1.100:3000/api';
  
  // Timeouts
  static const Duration requestTimeout = Duration(seconds: 30);
  static const Duration connectionTimeout = Duration(seconds: 15);
  
  // Headers
  static Map<String, String> get defaultHeaders => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };
  
  static Map<String, String> getAuthHeaders(String token) => {
    ...defaultHeaders,
    'Authorization': 'Bearer $token',
  };
}
EOF

# Modèles
cat > mobile/lib/models/user.dart << 'EOF'
class User {
  final String? id;
  final String username;
  final String email;
  final String? firstName;
  final String? lastName;
  final String? profilePicture;
  final List<String> roles;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool active;

  User({
    this.id,
    required this.username,
    required this.email,
    this.firstName,
    this.lastName,
    this.profilePicture,
    required this.roles,
    required this.createdAt,
    required this.updatedAt,
    this.active = true,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id']?.toString(),
      username: json['username'] ?? '',
      email: json['email'] ?? '',
      firstName: json['firstName'],
      lastName: json['lastName'],
      profilePicture: json['profilePicture'],
      roles: List<String>.from(json['roles'] ?? ['ROLE_USER']),
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'])
          : DateTime.now(),
      active: json['active'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'firstName': firstName,
      'lastName': lastName,
      'profilePicture': profilePicture,
      'roles': roles,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'active': active,
    };
  }

  String get displayName {
    if (firstName != null && lastName != null) {
      return '$firstName $lastName';
    }
    return username;
  }
}
EOF

cat > mobile/lib/models/category.dart << 'EOF'
class Category {
  final String id;
  final String name;
  final String description;
  final String color;
  final String icon;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  Category({
    required this.id,
    required this.name,
    required this.description,
    this.color = '#007bff',
    this.icon = 'book',
    this.isActive = true,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['_id'] ?? json['id'],
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      color: json['color'] ?? '#007bff',
      icon: json['icon'] ?? 'book',
      isActive: json['isActive'] ?? true,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'color': color,
      'icon': icon,
      'isActive': isActive,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}
EOF

cat > mobile/lib/models/question.dart << 'EOF'
class Question {
  final String id;
  final String title;
  final String content;
  final String authorId;
  final String authorName;
  final String categoryId;
  final Category? category;
  final List<String> tags;
  final int viewCount;
  final int answerCount;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  Question({
    required this.id,
    required this.title,
    required this.content,
    required this.authorId,
    required this.authorName,
    required this.categoryId,
    this.category,
    required this.tags,
    this.viewCount = 0,
    this.answerCount = 0,
    this.isActive = true,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Question.fromJson(Map<String, dynamic> json) {
    return Question(
      id: json['_id'] ?? json['id'],
      title: json['title'] ?? '',
      content: json['content'] ?? '',
      authorId: json['authorId'] ?? '',
      authorName: json['authorName'] ?? '',
      categoryId: json['categoryId'] ?? '',
      category: json['categoryId'] != null && json['categoryId'] is Map
          ? Category.fromJson(json['categoryId'])
          : null,
      tags: List<String>.from(json['tags'] ?? []),
      viewCount: json['viewCount'] ?? 0,
      answerCount: json['answerCount'] ?? 0,
      isActive: json['isActive'] ?? true,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'authorId': authorId,
      'authorName': authorName,
      'categoryId': categoryId,
      'tags': tags,
      'viewCount': viewCount,
      'answerCount': answerCount,
      'isActive': isActive,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}
EOF

cat > mobile/lib/models/answer.dart << 'EOF'
class Answer {
  final String id;
  final String questionId;
  final String content;
  final String authorId;
  final String authorName;
  final List<Vote> votes;
  final int score;
  final bool isAccepted;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  Answer({
    required this.id,
    required this.questionId,
    required this.content,
    required this.authorId,
    required this.authorName,
    required this.votes,
    this.score = 0,
    this.isAccepted = false,
    this.isActive = true,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Answer.fromJson(Map<String, dynamic> json) {
    List<Vote> votesList = [];
    if (json['votes'] != null) {
      votesList = List<Vote>.from(
        (json['votes'] as List).map((v) => Vote.fromJson(v)),
      );
    }

    return Answer(
      id: json['_id'] ?? json['id'],
      questionId: json['questionId'] ?? '',
      content: json['content'] ?? '',
      authorId: json['authorId'] ?? '',
      authorName: json['authorName'] ?? '',
      votes: votesList,
      score: json['score'] ?? 0,
      isAccepted: json['isAccepted'] ?? false,
      isActive: json['isActive'] ?? true,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'questionId': questionId,
      'content': content,
      'authorId': authorId,
      'authorName': authorName,
      'votes': votes.map((v) => v.toJson()).toList(),
      'score': score,
      'isAccepted': isAccepted,
      'isActive': isActive,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  Vote? getUserVote(String userId) {
    try {
      return votes.firstWhere((vote) => vote.userId == userId);
    } catch (e) {
      return null;
    }
  }
}

class Vote {
  final String userId;
  final int vote;

  Vote({
    required this.userId,
    required this.vote,
  });

  factory Vote.fromJson(Map<String, dynamic> json) {
    return Vote(
      userId: json['userId'] ?? '',
      vote: json['vote'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'vote': vote,
    };
  }
}
EOF

# Services
cat > mobile/lib/services/auth_service.dart << 'EOF'
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../config/api_config.dart';
import '../models/user.dart';

class AuthService {
  static const String _tokenKey = 'auth_token';
  static const String _userKey = 'current_user';

  Future<User> register(String username, String email, String password) async {
    try {
      final response = await http
          .post(
            Uri.parse('${ApiConfig.userServiceBaseUrl}/auth/register'),
            headers: ApiConfig.defaultHeaders,
            body: json.encode({
              'username': username,
              'email': email,
              'password': password,
            }),
          )
          .timeout(ApiConfig.requestTimeout);

      final responseData = json.decode(response.body);

      if (response.statusCode == 201) {
        if (responseData['success'] == true && responseData['data'] != null) {
          return User.fromJson(responseData['data']);
        } else {
          throw Exception('Registration successful but invalid response format');
        }
      } else {
        final error = responseData['message'] ?? 
                     responseData['error'] ?? 
                     'Registration failed';
        throw Exception(error);
      }
    } on SocketException {
      throw Exception('No internet connection');
    } on HttpException {
      throw Exception('Server error');
    } catch (e) {
      throw Exception('Registration failed: ${e.toString()}');
    }
  }

  Future<User> login(String username, String password) async {
    try {
      final response = await http
          .post(
            Uri.parse('${ApiConfig.userServiceBaseUrl}/auth/login'),
            headers: ApiConfig.defaultHeaders,
            body: json.encode({
              'username': username,
              'password': password,
            }),
          )
          .timeout(ApiConfig.requestTimeout);

      final responseData = json.decode(response.body);

      if (response.statusCode == 200) {
        final token = responseData['token'];
        final userData = responseData['user'];

        if (token != null && userData != null) {
          // Save token and user data
          await _saveToken(token);
          final user = User.fromJson(userData);
          await _saveUser(user);
          
          return user;
        } else {
          throw Exception('Invalid login response format');
        }
      } else {
        final error = responseData['message'] ?? 
                     responseData['error'] ?? 
                     'Login failed';
        throw Exception(error);
      }
    } on SocketException {
      throw Exception('No internet connection');
    } on HttpException {
      throw Exception('Server error');
    } catch (e) {
      throw Exception('Login failed: ${e.toString()}');
    }
  }

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  Future<void> _saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
  }

  Future<void> _saveUser(User user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userKey, json.encode(user.toJson()));
  }

  Future<User?> getCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userJson = prefs.getString(_userKey);
    
    if (userJson != null) {
      return User.fromJson(json.decode(userJson));
    }
    
    return null;
  }

  Future<bool> isLoggedIn() async {
    final token = await getToken();
    return token != null;
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_userKey);
  }
}
EOF

cat > mobile/lib/services/category_service.dart << 'EOF'
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../models/category.dart';
import 'auth_service.dart';

class CategoryService {
  final AuthService _authService = AuthService();

  Future<List<Category>> getAllCategories() async {
    try {
      final response = await http
          .get(
            Uri.parse('${ApiConfig.contentServiceBaseUrl}/categories'),
            headers: ApiConfig.defaultHeaders,
          )
          .timeout(ApiConfig.requestTimeout);

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        
        if (responseData['success'] == true && responseData['data'] != null) {
          return List<Category>.from(
            responseData['data'].map((json) => Category.fromJson(json))
          );
        } else {
          throw Exception('Invalid response format');
        }
      } else {
        final errorData = json.decode(response.body);
        throw Exception(errorData['error'] ?? 'Failed to fetch categories');
      }
    } on SocketException {
      throw Exception('No internet connection');
    } on HttpException {
      throw Exception('Server error');
    } catch (e) {
      throw Exception('Failed to fetch categories: ${e.toString()}');
    }
  }

  Future<Category> getCategoryById(String categoryId) async {
    try {
      final response = await http
          .get(
            Uri.parse('${ApiConfig.contentServiceBaseUrl}/categories/$categoryId'),
            headers: ApiConfig.defaultHeaders,
          )
          .timeout(ApiConfig.requestTimeout);

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        
        if (responseData['success'] == true && responseData['data'] != null) {
          return Category.fromJson(responseData['data']);
        } else {
          throw Exception('Invalid response format');
        }
      } else {
        final errorData = json.decode(response.body);
        throw Exception(errorData['error'] ?? 'Failed to fetch category');
      }
    } on SocketException {
      throw Exception('No internet connection');
    } on HttpException {
      throw Exception('Server error');
    } catch (e) {
      throw Exception('Failed to fetch category: ${e.toString()}');
    }
  }

  Future<Category> createCategory(String name, String description, {String? color, String? icon}) async {
    try {
      final token = await _authService.getToken();
      if (token == null) {
        throw Exception('User not authenticated');
      }

      final response = await http
          .post(
            Uri.parse('${ApiConfig.contentServiceBaseUrl}/categories'),
            headers: ApiConfig.getAuthHeaders(token),
            body: json.encode({
              'name': name,
              'description': description,
              if (color != null) 'color': color,
              if (icon != null) 'icon': icon,
            }),
          )
          .timeout(ApiConfig.requestTimeout);

      if (response.statusCode == 201) {
        final responseData = json.decode(response.body);
        
        if (responseData['success'] == true && responseData['data'] != null) {
          return Category.fromJson(responseData['data']);
        } else {
          throw Exception('Invalid response format');
        }
      } else {
        final errorData = json.decode(response.body);
        throw Exception(errorData['error'] ?? 'Failed to create category');
      }
    } on SocketException {
      throw Exception('No internet connection');
    } on HttpException {
      throw Exception('Server error');
    } catch (e) {
      throw Exception('Failed to create category: ${e.toString()}');
    }
  }
}
EOF

cat > mobile/lib/services/question_service.dart << 'EOF'
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../models/question.dart';
import '../models/answer.dart';
import 'auth_service.dart';

class QuestionService {
  final AuthService _authService = AuthService();

  Future<Map<String, dynamic>> getQuestionsByCategory(
    String categoryId, {
    int page = 1,
    int limit = 10,
  }) async {
    try {
      final uri = Uri.parse(
        '${ApiConfig.contentServiceBaseUrl}/categories/$categoryId/questions'
      ).replace(queryParameters: {
        'page': page.toString(),
        'limit': limit.toString(),
      });

      final response = await http
          .get(uri, headers: ApiConfig.defaultHeaders)
          .timeout(ApiConfig.requestTimeout);

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        
        if (responseData['success'] == true && responseData['data'] != null) {
          final data = responseData['data'];
          final List<Question> questions = List<Question>.from(
            data['questions'].map((json) => Question.fromJson(json))
          );
          
          return {
            'questions': questions,
            'pagination': data['pagination'],
          };
        } else {
          throw Exception('Invalid response format');
        }
      } else {
        final errorData = json.decode(response.body);
        throw Exception(errorData['error'] ?? 'Failed to fetch questions');
      }
    } on SocketException {
      throw Exception('No internet connection');
    } on HttpException {
      throw Exception('Server error');
    } catch (e) {
      throw Exception('Failed to fetch questions: ${e.toString()}');
    }
  }

  Future<Question> createQuestion(
    String title,
    String content,
    String categoryId,
    List<String> tags,
  ) async {
    try {
      final token = await _authService.getToken();
      if (token == null) {
        throw Exception('User not authenticated');
      }

      final response = await http
          .post(
            Uri.parse('${ApiConfig.contentServiceBaseUrl}/questions'),
            headers: ApiConfig.getAuthHeaders(token),
            body: json.encode({
              'title': title,
              'content': content,
              'categoryId': categoryId,
              'tags': tags,
            }),
          )
          .timeout(ApiConfig.requestTimeout);

      if (response.statusCode == 201) {
        final responseData = json.decode(response.body);
        
        if (responseData['success'] == true && responseData['data'] != null) {
          return Question.fromJson(responseData['data']);
        } else {
          throw Exception('Invalid response format');
        }
      } else {
        final errorData = json.decode(response.body);
        throw Exception(errorData['error'] ?? 'Failed to create question');
      }
    } on SocketException {
      throw Exception('No internet connection');
    } on HttpException {
      throw Exception('Server error');
    } catch (e) {
      throw Exception('Failed to create question: ${e.toString()}');
    }
  }

  Future<Map<String, dynamic>> getQuestionById(String questionId) async {
    try {
      final response = await http
          .get(
            Uri.parse('${ApiConfig.contentServiceBaseUrl}/questions/$questionId'),
            headers: ApiConfig.defaultHeaders,
          )
          .timeout(ApiConfig.requestTimeout);

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        
        if (responseData['success'] == true && responseData['data'] != null) {
          final data = responseData['data'];
          final question = Question.fromJson(data['question']);
          final List<Answer> answers = List<Answer>.from(
            data['answers'].map((json) => Answer.fromJson(json))
          );
          
          return {
            'question': question,
            'answers': answers,
          };
        } else {
          throw Exception('Invalid response format');
        }
      } else {
        final errorData = json.decode(response.body);
        throw Exception(errorData['error'] ?? 'Failed to fetch question');
      }
    } on SocketException {
      throw Exception('No internet connection');
    } on HttpException {
      throw Exception('Server error');
    } catch (e) {
      throw Exception('Failed to fetch question: ${e.toString()}');
    }
  }

  Future<Map<String, dynamic>> searchQuestions(
    String query, {
    int page = 1,
    int limit = 10,
  }) async {
    try {
      final uri = Uri.parse(
        '${ApiConfig.contentServiceBaseUrl}/questions/search'
      ).replace(queryParameters: {
        'q': query,
        'page': page.toString(),
        'limit': limit.toString(),
      });

      final response = await http
          .get(uri, headers: ApiConfig.defaultHeaders)
          .timeout(ApiConfig.requestTimeout);

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        
        if (responseData['success'] == true && responseData['data'] != null) {
          final data = responseData['data'];
          final List<Question> questions = List<Question>.from(
            data['questions'].map((json) => Question.fromJson(json))
          );
          
          return {
            'questions': questions,
            'pagination': data['pagination'],
            'query': data['query'],
          };
        } else {
          throw Exception('Invalid response format');
        }
      } else {
        final errorData = json.decode(response.body);
        throw Exception(errorData['error'] ?? 'Failed to search questions');
      }
    } on SocketException {
      throw Exception('No internet connection');
    } on HttpException {
      throw Exception('Server error');
    } catch (e) {
      throw Exception('Failed to search questions: ${e.toString()}');
    }
  }
}
EOF

cat > mobile/lib/services/answer_service.dart << 'EOF'
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../models/answer.dart';
import 'auth_service.dart';

class AnswerService {
  final AuthService _authService = AuthService();

  Future<Answer> createAnswer(String questionId, String content) async {
    try {
      final token = await _authService.getToken();
      if (token == null) {
        throw Exception('User not authenticated');
      }

      final response = await http
          .post(
            Uri.parse('${ApiConfig.contentServiceBaseUrl}/questions/$questionId/answers'),
            headers: ApiConfig.getAuthHeaders(token),
            body: json.encode({
              'content': content,
            }),
          )
          .timeout(ApiConfig.requestTimeout);

      if (response.statusCode == 201) {
        final responseData = json.decode(response.body);
        
        if (responseData['success'] == true && responseData['data'] != null) {
          return Answer.fromJson(responseData['data']);
        } else {
          throw Exception('Invalid response format');
        }
      } else {
        final errorData = json.decode(response.body);
        throw Exception(errorData['error'] ?? 'Failed to create answer');
      }
    } on SocketException {
      throw Exception('No internet connection');
    } on HttpException {
      throw Exception('Server error');
    } catch (e) {
      throw Exception('Failed to create answer: ${e.toString()}');
    }
  }

  Future<Answer> voteAnswer(String answerId, int vote) async {
    try {
      final token = await _authService.getToken();
      if (token == null) {
        throw Exception('User not authenticated');
      }

      final response = await http
          .post(
            Uri.parse('${ApiConfig.contentServiceBaseUrl}/answers/$answerId/vote'),
            headers: ApiConfig.getAuthHeaders(token),
            body: json.encode({
              'vote': vote,
            }),
          )
          .timeout(ApiConfig.requestTimeout);

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        
        if (responseData['success'] == true && responseData['data'] != null) {
          return Answer.fromJson(responseData['data']);
        } else {
          throw Exception('Invalid response format');
        }
      } else {
        final errorData = json.decode(response.body);
        throw Exception(errorData['error'] ?? 'Failed to vote for answer');
      }
    } on SocketException {
      throw Exception('No internet connection');
    } on HttpException {
      throw Exception('Server error');
    } catch (e) {
      throw Exception('Failed to vote for answer: ${e.toString()}');
    }
  }

  Future<List<Answer>> getAnswersByQuestion(String questionId) async {
    try {
      final response = await http
          .get(
            Uri.parse('${ApiConfig.contentServiceBaseUrl}/questions/$questionId/answers'),
            headers: ApiConfig.defaultHeaders,
          )
          .timeout(ApiConfig.requestTimeout);

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        
        if (responseData['success'] == true && responseData['data'] != null) {
          return List<Answer>.from(
            responseData['data'].map((json) => Answer.fromJson(json))
          );
        } else {
          throw Exception('Invalid response format');
        }
      } else {
        final errorData = json.decode(response.body);
        throw Exception(errorData['error'] ?? 'Failed to fetch answers');
      }
    } on SocketException {
      throw Exception('No internet connection');
    } on HttpException {
      throw Exception('Server error');
    } catch (e) {
      throw Exception('Failed to fetch answers: ${e.toString()}');
    }
  }
}
EOF

# Providers
cat > mobile/lib/providers/auth_provider.dart << 'EOF'
import 'package:flutter/foundation.dart';
import '../models/user.dart';
import '../services/auth_service.dart';

class AuthProvider with ChangeNotifier {
  User? _currentUser;
  bool _isLoading = false;
  String? _error;
  final AuthService _authService = AuthService();

  User? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  bool get isLoggedIn => _currentUser != null;
  String? get error => _error;

  AuthProvider() {
    _initializeAuth();
  }

  Future<void> _initializeAuth() async {
    _isLoading = true;
    notifyListeners();

    try {
      final user = await _authService.getCurrentUser();
      if (user != null && await _authService.isLoggedIn()) {
        _currentUser = user;
      }
      _error = null;
    } catch (e) {
      _error = e.toString();
      await _authService.logout(); // Clear invalid session
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> register(String username, String email, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final user = await _authService.register(username, email, password);
      _currentUser = user;
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> login(String username, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final user = await _authService.login(username, password);
      _currentUser = user;
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    _isLoading = true;
    notifyListeners();

    try {
      await _authService.logout();
      _currentUser = null;
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
EOF

cat > mobile/lib/providers/category_provider.dart << 'EOF'
import 'package:flutter/foundation.dart';
import '../models/category.dart';
import '../services/category_service.dart';

class CategoryProvider with ChangeNotifier {
  List<Category> _categories = [];
  bool _isLoading = false;
  String? _error;
  final CategoryService _categoryService = CategoryService();

  List<Category> get categories => List.unmodifiable(_categories);
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchCategories() async {
    if (_categories.isNotEmpty) return; // Don't refetch if already loaded

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _categories = await _categoryService.getAllCategories();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> refreshCategories() async {
    _categories.clear();
    await fetchCategories();
  }

  Category? getCategoryById(String categoryId) {
    try {
      return _categories.firstWhere((c) => c.id == categoryId);
    } catch (e) {
      return null;
    }
  }

  Future<bool> createCategory(String name, String description, {String? color, String? icon}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final category = await _categoryService.createCategory(name, description, color: color, icon: icon);
      _categories.add(category);
      _categories.sort((a, b) => a.name.compareTo(b.name));
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
EOF

# Application principale
cat > mobile/lib/main.dart << 'EOF'
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/auth_provider.dart';
import 'providers/category_provider.dart';
import 'screens/auth/login_screen.dart';
import 'screens/questions/question_list_screen.dart';
import 'screens/splash_screen.dart';

void main() {
  runApp(QuizAcademyApp());
}

class QuizAcademyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => CategoryProvider()),
      ],
      child: Consumer<AuthProvider>(
        builder: (context, authProvider, _) {
          return MaterialApp(
            title: 'QuizAcademy',
            debugShowCheckedModeBanner: false,
            theme: ThemeData(
              primarySwatch: Colors.blue,
              primaryColor: const Color(0xFF1976D2),
              colorScheme: ColorScheme.fromSeed(
                seedColor: const Color(0xFF1976D2),
                brightness: Brightness.light,
              ),
              appBarTheme: const AppBarTheme(
                backgroundColor: Color(0xFF1976D2),
                foregroundColor: Colors.white,
                elevation: 2,
              ),
              elevatedButtonTheme: ElevatedButtonThemeData(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1976D2),
                  foregroundColor: Colors.white,
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              cardTheme: CardTheme(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              inputDecorationTheme: InputDecorationTheme(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
              useMaterial3: true,
            ),
            home: authProvider.isLoading
                ? const SplashScreen()
                : authProvider.isLoggedIn
                    ? const QuestionListScreen()
                    : const LoginScreen(),
            routes: {
              '/login': (context) => const LoginScreen(),
              '/questions': (context) => const QuestionListScreen(),
            },
          );
        },
      ),
    );
  }
}
EOF

cat > mobile/lib/screens/splash_screen.dart << 'EOF'
import 'package:flutter/material.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.school,
              size: 80,
              color: Colors.white,
            ),
            SizedBox(height: 24),
            Text(
              'QuizAcademy',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            SizedBox(height: 16),
            Text(
              'Plateforme de partage de connaissances',
              style: TextStyle(
                fontSize: 16,
                color: Colors.white70,
              ),
            ),
            SizedBox(height: 48),
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}
EOF

# Écrans d'authentification
cat > mobile/lib/screens/auth/login_screen.dart << 'EOF'
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isPasswordVisible = false;
  bool _rememberMe = false;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    authProvider.clearError();

    final success = await authProvider.login(
      _usernameController.text.trim(),
      _passwordController.text,
    );

    if (success && mounted) {
      Navigator.of(context).pushReplacementNamed('/questions');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 60),
                // Logo and title
                const Icon(
                  Icons.school,
                  size: 80,
                  color: Color(0xFF1976D2),
                ),
                const SizedBox(height: 24),
                const Text(
                  'QuizAcademy',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1976D2),
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Connectez-vous pour continuer',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 48),

                // Error message
                Consumer<AuthProvider>(
                  builder: (context, authProvider, _) {
                    if (authProvider.error != null) {
                      return Container(
                        margin: const EdgeInsets.only(bottom: 16),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.red[50],
                          border: Border.all(color: Colors.red[200]!),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.error_outline, color: Colors.red[700], size: 20),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                authProvider.error!,
                                style: TextStyle(color: Colors.red[700], fontSize: 14),
                              ),
                            ),
                          ],
                        ),
                      );
                    }
                    return const SizedBox.shrink();
                  },
                ),

                // Username field
                TextFormField(
                  controller: _usernameController,
                  decoration: const InputDecoration(
                    labelText: 'Nom d\'utilisateur',
                    prefixIcon: Icon(Icons.person_outline),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Veuillez entrer votre nom d\'utilisateur';
                    }
                    return null;
                  },
                  textInputAction: TextInputAction.next,
                ),
                const SizedBox(height: 16),

                // Password field
                TextFormField(
                  controller: _passwordController,
                  obscureText: !_isPasswordVisible,
                  decoration: InputDecoration(
                    labelText: 'Mot de passe',
                    prefixIcon: const Icon(Icons.lock_outline),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _isPasswordVisible ? Icons.visibility_off : Icons.visibility,
                      ),
                      onPressed: () {
                        setState(() {
                          _isPasswordVisible = !_isPasswordVisible;
                        });
                      },
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Veuillez entrer votre mot de passe';
                    }
                    return null;
                  },
                  textInputAction: TextInputAction.done,
                  onFieldSubmitted: (_) => _login(),
                ),
                const SizedBox(height: 16),

                // Remember me checkbox
                Row(
                  children: [
                    Checkbox(
                      value: _rememberMe,
                      onChanged: (value) {
                        setState(() {
                          _rememberMe = value ?? false;
                        });
                      },
                    ),
                    const Text('Se souvenir de moi'),
                    const Spacer(),
                    TextButton(
                      onPressed: () {
                        // TODO: Implement forgot password
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Fonctionnalité à venir'),
                          ),
                        );
                      },
                      child: const Text('Mot de passe oublié ?'),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Login button
                Consumer<AuthProvider>(
                  builder: (context, authProvider, _) {
                    return ElevatedButton(
                      onPressed: authProvider.isLoading ? null : _login,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: authProvider.isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : const Text(
                              'Se connecter',
                              style: TextStyle(fontSize: 16),
                            ),
                    );
                  },
                ),
                const SizedBox(height: 24),

                // Register link
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('Vous n\'avez pas de compte ?'),
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => const RegisterScreen(),
                          ),
                        );
                      },
                      child: const Text('S\'inscrire'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
EOF

cat > mobile/lib/screens/auth/register_screen.dart << 'EOF'
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({Key? key}) : super(key: key);

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    authProvider.clearError();

    final success = await authProvider.register(
      _usernameController.text.trim(),
      _emailController.text.trim(),
      _passwordController.text,
    );

    if (success && mounted) {
      Navigator.of(context).pushReplacementNamed('/questions');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Inscription'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: const Color(0xFF1976D2),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header
                const Text(
                  'Créer un compte',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1976D2),
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Rejoignez la communauté QuizAcademy',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 32),

                // Error message
                Consumer<AuthProvider>(
                  builder: (context, authProvider, _) {
                    if (authProvider.error != null) {
                      return Container(
                        margin: const EdgeInsets.only(bottom: 16),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.red[50],
                          border: Border.all(color: Colors.red[200]!),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.error_outline, color: Colors.red[700], size: 20),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                authProvider.error!,
                                style: TextStyle(color: Colors.red[700], fontSize: 14),
                              ),
                            ),
                          ],
                        ),
                      );
                    }
                    return const SizedBox.shrink();
                  },
                ),

                // Username field
                TextFormField(
                  controller: _usernameController,
                  decoration: const InputDecoration(
                    labelText: 'Nom d\'utilisateur',
                    prefixIcon: Icon(Icons.person_outline),
                    helperText: 'Au moins 3 caractères',
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Veuillez entrer un nom d\'utilisateur';
                    }
                    if (value.trim().length < 3) {
                      return 'Le nom d\'utilisateur doit contenir au moins 3 caractères';
                    }
                    return null;
                  },
                  textInputAction: TextInputAction.next,
                ),
                const SizedBox(height: 16),

                // Email field
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    prefixIcon: Icon(Icons.email_outlined),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Veuillez entrer votre email';
                    }
                    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}).hasMatch(value.trim())) {
                      return 'Veuillez entrer un email valide';
                    }
                    return null;
                  },
                  textInputAction: TextInputAction.next,
                ),
                const SizedBox(height: 16),

                // Password field
                TextFormField(
                  controller: _passwordController,
                  obscureText: !_isPasswordVisible,
                  decoration: InputDecoration(
                    labelText: 'Mot de passe',
                    prefixIcon: const Icon(Icons.lock_outline),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _isPasswordVisible ? Icons.visibility_off : Icons.visibility,
                      ),
                      onPressed: () {
                        setState(() {
                          _isPasswordVisible = !_isPasswordVisible;
                        });
                      },
                    ),
                    helperText: 'Au moins 6 caractères',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Veuillez entrer un mot de passe';
                    }
                    if (value.length < 6) {
                      return 'Le mot de passe doit contenir au moins 6 caractères';
                    }
                    return null;
                  },
                  textInputAction: TextInputAction.next,
                ),
                const SizedBox(height: 16),

                // Confirm password field
                TextFormField(
                  controller: _confirmPasswordController,
                  obscureText: !_isConfirmPasswordVisible,
                  decoration: InputDecoration(
                    labelText: 'Confirmer le mot de passe',
                    prefixIcon: const Icon(Icons.lock_outline),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _isConfirmPasswordVisible ? Icons.visibility_off : Icons.visibility,
                      ),
                      onPressed: () {
                        setState(() {
                          _isConfirmPasswordVisible = !_isConfirmPasswordVisible;
                        });
                      },
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Veuillez confirmer votre mot de passe';
                    }
                    if (value != _passwordController.text) {
                      return 'Les mots de passe ne correspondent pas';
                    }
                    return null;
                  },
                  textInputAction: TextInputAction.done,
                  onFieldSubmitted: (_) => _register(),
                ),
                const SizedBox(height: 32),

                // Register button
                Consumer<AuthProvider>(
                  builder: (context, authProvider, _) {
                    return ElevatedButton(
                      onPressed: authProvider.isLoading ? null : _register,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: authProvider.isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : const Text(
                              'S\'inscrire',
                              style: TextStyle(fontSize: 16),
                            ),
                    );
                  },
                ),
                const SizedBox(height: 24),

                // Login link
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('Vous avez déjà un compte ?'),
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: const Text('Se connecter'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
EOF

# Écran de liste des questions - version simplifiée mais fonctionnelle
cat > mobile/lib/screens/questions/question_list_screen.dart << 'EOF'
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/category.dart';
import '../../models/question.dart';
import '../../providers/auth_provider.dart';
import '../../providers/category_provider.dart';
import '../../services/question_service.dart';
import '../../widgets/question_card.dart';

class QuestionListScreen extends StatefulWidget {
  const QuestionListScreen({Key? key}) : super(key: key);

  @override
  State<QuestionListScreen> createState() => _QuestionListScreenState();
}

class _QuestionListScreenState extends State<QuestionListScreen> {
  final QuestionService _questionService = QuestionService();
  Category? _selectedCategory;
  List<Question> _questions = [];
  bool _isLoading = false;
  String? _error;
  int _currentPage = 1;
  bool _hasMore = true;

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    final categoryProvider = Provider.of<CategoryProvider>(context, listen: false);
    await categoryProvider.fetchCategories();
    
    if (categoryProvider.categories.isNotEmpty && mounted) {
      setState(() {
        _selectedCategory = categoryProvider.categories.first;
      });
      _loadQuestions(refresh: true);
    }
  }

  Future<void> _loadQuestions({bool refresh = false}) async {
    if (_selectedCategory == null) return;

    setState(() {
      _isLoading = true;
      _error = null;
      if (refresh) {
        _questions.clear();
        _currentPage = 1;
        _hasMore = true;
      }
    });

    try {
      final result = await _questionService.getQuestionsByCategory(
        _selectedCategory!.id,
        page: _currentPage,
        limit: 10,
      );

      final List<Question> newQuestions = result['questions'] as List<Question>;
      final pagination = result['pagination'] as Map<String, dynamic>;

      setState(() {
        if (refresh) {
          _questions = newQuestions;
        } else {
          _questions.addAll(newQuestions);
        }
        _hasMore = pagination['hasMore'] ?? false;
        _currentPage++;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final categoryProvider = Provider.of<CategoryProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('QuizAcademy'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              // TODO: Implement search
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Recherche à venir')),
              );
            },
          ),
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'logout') {
                _showLogoutDialog(authProvider);
              }
            },
            itemBuilder: (BuildContext context) => [
              PopupMenuItem<String>(
                value: 'profile',
                child: Row(
                  children: [
                    const Icon(Icons.person_outline),
                    const SizedBox(width: 8),
                    Text('Profil (${authProvider.currentUser?.username ?? 'User'})'),
                  ],
                ),
              ),
              const PopupMenuItem<String>(
                value: 'logout',
                child: Row(
                  children: [
                    Icon(Icons.logout),
                    SizedBox(width: 8),
                    Text('Déconnexion'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          _buildCategorySelector(categoryProvider),
          Expanded(
            child: _buildQuestionList(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // TODO: Implement create question
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Création de question à venir')),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildCategorySelector(CategoryProvider categoryProvider) {
    if (categoryProvider.categories.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        border: Border(
          bottom: BorderSide(color: Colors.grey[300]!),
        ),
      ),
      child: Row(
        children: [
          const Text(
            'Catégorie:',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: DropdownButton<Category>(
              isExpanded: true,
              value: _selectedCategory,
              hint: const Text('Sélectionner une catégorie'),
              items: categoryProvider.categories.map((Category category) {
                return DropdownMenuItem<Category>(
                  value: category,
                  child: Text(category.name),
                );
              }).toList(),
              onChanged: (Category? newValue) {
                if (newValue != null && newValue != _selectedCategory) {
                  setState(() {
                    _selectedCategory = newValue;
                  });
                  _loadQuestions(refresh: true);
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuestionList() {
    if (_isLoading && _questions.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_error != null && _questions.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'Erreur: $_error',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => _loadQuestions(refresh: true),
              child: const Text('Réessayer'),
            ),
          ],
        ),
      );
    }

    if (_questions.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.help_outline,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'Aucune question dans cette catégorie',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => _loadQuestions(refresh: true),
              child: const Text('Rafraîchir'),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => _loadQuestions(refresh: true),
      child: ListView.builder(
        itemCount: _questions.length + (_hasMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == _questions.length) {
            return _buildLoadMoreButton();
          }

          final question = _questions[index];
          return QuestionCard(
            question: question,
            onTap: () {
              // TODO: Navigate to question detail
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Détail de question à venir')),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildLoadMoreButton() {
    return Container(
      padding: const EdgeInsets.all(16.0),
      alignment: Alignment.center,
      child: _isLoading
          ? const CircularProgressIndicator()
          : ElevatedButton(
              onPressed: () => _loadQuestions(refresh: false),
              child: const Text('Charger plus'),
            ),
    );
  }

  void _showLogoutDialog(AuthProvider authProvider) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Déconnexion'),
          content: const Text('Êtes-vous sûr de vouloir vous déconnecter ?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Annuler'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();
                await authProvider.logout();
                if (mounted) {
                  Navigator.of(context).pushReplacementNamed('/login');
                }
              },
              child: const Text('Déconnexion'),
            ),
          ],
        );
      },
    );
  }
}
EOF

# Widget QuestionCard
cat > mobile/lib/widgets/question_card.dart << 'EOF'
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/question.dart';

class QuestionCard extends StatelessWidget {
  final Question question;
  final VoidCallback onTap;

  const QuestionCard({
    Key? key,
    required this.question,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title
              Text(
                question.title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1976D2),
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),

              // Content preview
              Text(
                question.content.length > 120
                    ? '${question.content.substring(0, 120)}...'
                    : question.content,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[700],
                  height: 1.4,
                ),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 12),

              // Tags
              if (question.tags.isNotEmpty)
                Wrap(
                  spacing: 6,
                  runSpacing: 4,
                  children: question.tags.take(3).map((tag) {
                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.blue[50],
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.blue[200]!),
                      ),
                      child: Text(
                        tag,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.blue[700],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              if (question.tags.isNotEmpty) const SizedBox(height: 12),

              // Footer with stats and info
              Row(
                children: [
                  // Author
                  Icon(
                    Icons.person_outline,
                    size: 16,
                    color: Colors.grey[600],
                  ),
                  const SizedBox(width: 4),
                  Text(
                    question.authorName,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(width: 12),

                  // Views
                  Icon(
                    Icons.visibility_outlined,
                    size: 16,
                    color: Colors.grey[600],
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${question.viewCount}',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(width: 12),

                  // Answers
                  Icon(
                    Icons.chat_bubble_outline,
                    size: 16,
                    color: Colors.grey[600],
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${question.answerCount}',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),

                  const Spacer(),

                  // Date
                  Text(
                    DateFormat('dd/MM/yyyy').format(question.createdAt),
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[500],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
EOF

echo "✅ Application Flutter configurée"

# ===========================================
# DOCUMENTATION ET SCRIPTS
# ===========================================

echo "📚 Création de la documentation..."

# README principal
cat > README.md << 'EOF'
# QuizAcademy - Plateforme de Partage de Connaissances

QuizAcademy est une application mobile de type questions/réponses développée avec une architecture microservices moderne. Ce projet intègre Flutter pour le frontend mobile, Java/Spring Boot et Node.js/Express pour les services backend, le tout orchestré avec Docker.

## 🏗️ Architecture

### Services Backend
- **Service Utilisateurs** (Java/Spring Boot) : Authentification, gestion des utilisateurs
- **Service Content** (Node.js/Express) : Gestion des questions, réponses et votes
- **Base de données** : H2 (Service Utilisateurs) + MongoDB (Service Content)

### Frontend
- **Application Mobile** (Flutter) : Interface utilisateur multiplateforme

### Orchestration
- **Docker Compose** : Déploiement et orchestration des services

## 🚀 Installation Rapide

### Prérequis
- Docker et Docker Compose (v20.0+)
- Flutter SDK (v3.0+) pour le développement mobile
- Git

### Installation automatique
```bash
# Cloner et exécuter le script d'installation
git clone <repository-url>
cd quizacademy
chmod +x create_project.sh
./create_project.sh
```

### Démarrage des services
```bash
# Démarrer les services backend
cd backend
docker-compose up -d

# Vérifier l'état des services
docker-compose ps

# Voir les logs
docker-compose logs -f
```

### Configuration de l'application mobile
```bash
cd mobile
flutter pub get
flutter run
```

## 📱 Utilisation

### URLs des services
- **Service Utilisateurs** : http://localhost:8080
- **Service Content** : http://localhost:3000
- **Base de données MongoDB** : http://localhost:27017

### Endpoints principaux

#### Service Utilisateurs (Port 8080)
- `POST /api/auth/register` - Inscription
- `POST /api/auth/login` - Connexion
- `GET /api/auth/health` - État du service

#### Service Content (Port 3000)
- `GET /api/categories` - Liste des catégories
- `POST /api/questions` - Créer une question
- `GET /api/categories/{id}/questions` - Questions par catégorie
- `POST /api/questions/{id}/answers` - Créer une réponse
- `POST /api/answers/{id}/vote` - Voter pour une réponse

## 🧪 Tests

### Tester les services avec Postman

1. **Créer un utilisateur**
```json
POST http://localhost:8080/api/auth/register
{
  "username": "testuser",
  "email": "test@example.com",
  "password": "password123"
}
```

2. **Se connecter**
```json
POST http://localhost:8080/api/auth/login
{
  "username": "testuser",
  "password": "password123"
}
```

3. **Créer une question**
```json
POST http://localhost:3000/api/questions
Authorization: Bearer <token>
{
  "title": "Comment fonctionne Docker ?",
  "content": "Je débute avec Docker et j'aimerais comprendre les concepts de base.",
  "categoryId": "<category_id>",
  "tags": ["docker", "devops"]
}
```

### Tester l'application mobile

1. Configurer l'URL des services dans `mobile/lib/config/api_config.dart`
2. Lancer l'application : `flutter run`
3. Tester l'inscription et la connexion
4. Naviguer dans les catégories et consulter les questions

## 🔧 Développement

### Structure du projet
```
quizacademy/
├── backend/
│   ├── user-service/          # Service Java/Spring Boot
│   ├── content-service/       # Service Node.js/Express
│   └── docker-compose.yml     # Orchestration
├── mobile/                    # Application Flutter
├── docs/                      # Documentation
└── scripts/                   # Scripts utilitaires
```

### Commandes utiles

```bash
# Backend
cd backend
docker-compose up --build      # Rebuild et démarrer
docker-compose down           # Arrêter les services
docker-compose logs service   # Voir les logs d'un service

# Mobile
cd mobile
flutter clean                 # Nettoyer le cache
flutter pub get              # Installer les dépendances
flutter run --debug          # Lancer en mode debug
flutter build apk           # Compiler pour Android
```

## 🐛 Dépannage

### Problèmes courants

1. **Services ne démarrent pas**
   - Vérifier que les ports 8080, 3000, 27017 sont libres
   - Vérifier les logs : `docker-compose logs`

2. **Application mobile ne se connecte pas**
   - Vérifier les URLs dans `api_config.dart`
   - Pour émulateur Android : utiliser `10.0.2.2`
   - Pour dispositif physique : utiliser l'IP de votre machine

3. **Erreurs de compilation Flutter**
   - Exécuter `flutter clean && flutter pub get`
   - Vérifier la version de Flutter : `flutter doctor`

4. **Base de données MongoDB vide**
   - Les données d'exemple sont créées automatiquement
   - Vérifier les logs MongoDB : `docker-compose logs mongodb`

### Logs et debugging

```bash
# Voir les logs de tous les services
docker-compose logs -f

# Logs d'un service spécifique
docker-compose logs -f user-service
docker-compose logs -f content-service
docker-compose logs -f mongodb

# Accéder à un conteneur
docker-compose exec user-service bash
docker-compose exec content-service sh
```

## 📝 Fonctionnalités

### ✅ Implémentées
- ✅ Authentification utilisateur (inscription, connexion)
- ✅ Gestion des catégories de questions
- ✅ Création et consultation de questions
- ✅ Système de réponses
- ✅ Système de votes pour les réponses
- ✅ Interface mobile responsive
- ✅ Déploiement Docker
- ✅ Pagination des résultats
- ✅ Recherche de questions

### 🔄 À venir
- 🔄 Notifications push
- 🔄 Profils utilisateurs étendus
- 🔄 Statistiques et tableaux de bord
- 🔄 Modération des contenus
- 🔄 API de gamification

## 🤝 Contribution

1. Fork le projet
2. Créer une branche feature (`git checkout -b feature/AmazingFeature`)
3. Commit les changements (`git commit -m 'Add some AmazingFeature'`)
4. Push vers la branche (`git push origin feature/AmazingFeature`)
5. Ouvrir une Pull Request

## 📄 Licence

Ce projet est sous licence MIT. Voir le fichier `LICENSE` pour plus de détails.

## 👥 Équipe

- **Dr. El Hadji Bassirou TOURE** - *Encadrant du projet*
- **Étudiants** - *Développement et implémentation*

## 📞 Support

Pour toute question ou problème :
1. Consulter la documentation dans le dossier `docs/`
2. Vérifier les issues GitHub existantes
3. Créer une nouvelle issue si nécessaire

---

**QuizAcademy** - Partager les connaissances, apprendre ensemble ! 🎓
EOF

# Documentation technique
cat > docs/TECHNICAL_GUIDE.md << 'EOF'
# Guide Technique - QuizAcademy

## Architecture Détaillée

### Vue d'ensemble
QuizAcademy utilise une architecture microservices avec séparation claire des responsabilités :

- **Frontend** : Application Flutter (mobile-first)
- **Backend** : Deux microservices indépendants
  - Service Utilisateurs (Java/Spring Boot)
  - Service Content (Node.js/Express)
- **Persistence** : Bases de données séparées (H2 + MongoDB)
- **Orchestration** : Docker Compose

### Service Utilisateurs (Java/Spring Boot)

#### Technologies
- Spring Boot 3.1.5
- Spring Security 6
- Spring Data JPA
- JWT pour l'authentification
- Base de données H2 (mémoire)

#### Responsabilités
- Authentification et autorisation
- Gestion des comptes utilisateurs
- Génération et validation des tokens JWT
- Endpoints sécurisés

#### Endpoints principaux
```
POST /api/auth/register
POST /api/auth/login
GET /actuator/health
```

#### Configuration JWT
```yaml
jwt:
  secret: <secret-key>
  expirationMs: 86400000  # 24 heures
```

### Service Content (Node.js/Express)

#### Technologies
- Node.js 18+
- Express.js 4.18+
- MongoDB avec Mongoose
- JWT pour la vérification des tokens
- Validation avec express-validator

#### Responsabilités
- Gestion des catégories
- CRUD des questions et réponses
- Système de votes
- Recherche et pagination

#### Modèles de données

**Question**
```javascript
{
  title: String,
  content: String,
  authorId: String,
  authorName: String,
  categoryId: ObjectId,
  tags: [String],
  viewCount: Number,
  answerCount: Number,
  isActive: Boolean,
  timestamps: true
}
```

**Answer**
```javascript
{
  questionId: ObjectId,
  content: String,
  authorId: String,
  authorName: String,
  votes: [{userId: String, vote: Number}],
  score: Number,
  isAccepted: Boolean,
  isActive: Boolean,
  timestamps: true
}
```

### Application Mobile (Flutter)

#### Architecture
- **Pattern** : Provider pour la gestion d'état
- **Services** : Séparation des appels API
- **Modèles** : Classes Dart avec sérialisation JSON
- **Providers** : Gestion d'état réactive

#### Structure des dossiers
```
lib/
├── config/          # Configuration API
├── models/          # Modèles de données
├── providers/       # Providers pour l'état
├── screens/         # Écrans de l'application
├── services/        # Services API
├── widgets/         # Widgets réutilisables
└── utils/           # Utilitaires
```

#### Gestion de l'authentification
```dart
class AuthProvider with ChangeNotifier {
  User? _currentUser;
  bool _isLoading = false;
  String? _error;
  
  // Méthodes pour login, register, logout
}
```

## Communication Inter-Services

### Authentification distribuée
1. L'utilisateur s'authentifie via le Service Utilisateurs
2. Un token JWT est généré et retourné
3. Le token est inclus dans les requêtes vers le Service Content
4. Le Service Content valide le token avec la même clé secrète

### Format des tokens JWT
```json
{
  "sub": "username",
  "roles": ["ROLE_USER"],
  "iat": 1234567890,
  "exp": 1234654290
}
```

## Base de Données

### Service Utilisateurs (H2)
```sql
CREATE TABLE users (
  id BIGINT AUTO_INCREMENT PRIMARY KEY,
  username VARCHAR(20) UNIQUE NOT NULL,
  email VARCHAR(50) UNIQUE NOT NULL,
  password VARCHAR(120) NOT NULL,
  created_at TIMESTAMP NOT NULL,
  updated_at TIMESTAMP NOT NULL,
  active BOOLEAN DEFAULT TRUE
);

CREATE TABLE user_roles (
  user_id BIGINT,
  role VARCHAR(20),
  FOREIGN KEY (user_id) REFERENCES users(id)
);
```

### Service Content (MongoDB)
Les collections sont créées automatiquement par Mongoose avec les schémas définis.

#### Index de performance
```javascript
// Questions
db.questions.createIndex({title: "text", content: "text", tags: "text"});
db.questions.createIndex({categoryId: 1, createdAt: -1});

// Answers
db.answers.createIndex({questionId: 1, score: -1});
```

## Déploiement

### Docker Compose
```yaml
version: '3.8'
services:
  user-service:
    build: ./user-service
    ports: ["8080:8080"]
    environment:
      - JWT_SECRET=${JWT_SECRET}
    
  content-service:
    build: ./content-service
    ports: ["3000:3000"]
    environment:
      - MONGODB_URI=mongodb://mongodb:27017/quizacademy
      - JWT_SECRET=${JWT_SECRET}
    depends_on: [mongodb]
    
  mongodb:
    image: mongo:6.0
    ports: ["27017:27017"]
    volumes: [mongodb_data:/data/db]
```

### Health Checks
Tous les services implémentent des health checks :
- **User Service** : `/actuator/health`
- **Content Service** : `/health`
- **MongoDB** : `mongosh --eval "db.adminCommand('ping')"`

## Sécurité

### Authentification
- Mots de passe hashés avec BCrypt
- Tokens JWT avec expiration
- Validation des entrées utilisateur
- CORS configuré pour les origines autorisées

### Validation des données
```javascript
// Exemple pour création de question
const validateQuestion = [
  body('title').trim().isLength({ min: 5, max: 200 }),
  body('content').trim().isLength({ min: 10, max: 5000 }),
  body('categoryId').isMongoId(),
];
```

## Monitoring et Logs

### Logs structurés
- **User Service** : Logback avec format JSON
- **Content Service** : Morgan middleware pour Express
- **Niveaux** : ERROR, WARN, INFO, DEBUG

### Métriques
- Health checks exposés
- Métriques applicatives via Actuator (Spring Boot)
- Monitoring des performances MongoDB

## Tests

### Tests unitaires
```bash
# Service Utilisateurs
./gradlew test

# Service Content  
npm test

# Application Flutter
flutter test
```

### Tests d'intégration
```bash
# Tests avec Postman/Newman
newman run postman_collection.json

# Tests end-to-end
flutter drive --target=test_driver/app.dart
```

## Optimisations

### Performance
- Pagination sur toutes les listes
- Index de base de données optimisés
- Mise en cache des catégories côté client
- Lazy loading des images

### Scalabilité
- Services stateless
- Bases de données séparées
- Communication asynchrone possible
- Déploiement horizontal avec Docker Swarm/Kubernetes

## Maintenance

### Mise à jour des dépendances
```bash
# Java
./gradlew dependencyUpdates

# Node.js
npm audit
npm update

# Flutter
flutter pub upgrade
```

### Sauvegarde des données
```bash
# MongoDB
docker-compose exec mongodb mongodump --out /backup

# Restauration
docker-compose exec mongodb mongorestore /backup
```

### Monitoring en production
- Logs centralisés (ELK Stack recommandé)
- Alertes sur les erreurs
- Monitoring des ressources (CPU, mémoire, disque)
- Surveillance des temps de réponse

---

Ce guide technique fournit une vue d'ensemble complète de l'architecture et des bonnes pratiques pour maintenir et faire évoluer QuizAcademy.
EOF

# Script de test
cat > scripts/test_services.sh << 'EOF'
#!/bin/bash

# Script de test des services QuizAcademy
echo "🧪 Test des services QuizAcademy"
echo "================================"

BASE_URL_USER="http://localhost:8080/api"
BASE_URL_CONTENT="http://localhost:3000/api"

# Couleurs pour l'affichage
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Fonction pour tester un endpoint
test_endpoint() {
    local method=$1
    local url=$2
    local data=$3
    local headers=$4
    local expected_status=$5
    
    echo -n "Testing $method $url ... "
    
    if [ -n "$data" ]; then
        if [ -n "$headers" ]; then
            response=$(curl -s -w "%{http_code}" -X $method "$url" -H "Content-Type: application/json" -H "$headers" -d "$data")
        else
            response=$(curl -s -w "%{http_code}" -X $method "$url" -H "Content-Type: application/json" -d "$data")
        fi
    else
        if [ -n "$headers" ]; then
            response=$(curl -s -w "%{http_code}" -X $method "$url" -H "$headers")
        else
            response=$(curl -s -w "%{http_code}" -X $method "$url")
        fi
    fi
    
    status_code="${response: -3}"
    response_body="${response%???}"
    
    if [ "$status_code" = "$expected_status" ]; then
        echo -e "${GREEN}✓ OK${NC} (Status: $status_code)"
        return 0
    else
        echo -e "${RED}✗ FAILED${NC} (Expected: $expected_status, Got: $status_code)"
        echo "Response: $response_body"
        return 1
    fi
}

# Attendre que les services soient prêts
echo "⏳ Attente du démarrage des services..."
sleep 10

# Test 1: Health check des services
echo -e "\n${YELLOW}1. Health Checks${NC}"
test_endpoint "GET" "$BASE_URL_USER/auth/health" "" "" "200"
test_endpoint "GET" "$BASE_URL_CONTENT/categories" "" "" "200"

# Test 2: Inscription d'un utilisateur
echo -e "\n${YELLOW}2. Inscription utilisateur${NC}"
user_data='{"username":"testuser","email":"test@example.com","password":"password123"}'
register_response=$(curl -s -X POST "$BASE_URL_USER/auth/register" -H "Content-Type: application/json" -d "$user_data")
test_endpoint "POST" "$BASE_URL_USER/auth/register" "$user_data" "" "201"

# Test 3: Connexion utilisateur
echo -e "\n${YELLOW}3. Connexion utilisateur${NC}"
login_data='{"username":"testuser","password":"password123"}'
login_response=$(curl -s -X POST "$BASE_URL_USER/auth/login" -H "Content-Type: application/json" -d "$login_data")
token=$(echo $login_response | grep -o '"token":"[^"]*' | cut -d'"' -f4)

if [ -n "$token" ]; then
    echo "✓ Token récupéré: ${token:0:20}..."
    test_endpoint "POST" "$BASE_URL_USER/auth/login" "$login_data" "" "200"
else
    echo -e "${RED}✗ Impossible de récupérer le token${NC}"
    exit 1
fi

# Test 4: Récupération des catégories
echo -e "\n${YELLOW}4. Récupération des catégories${NC}"
categories_response=$(curl -s "$BASE_URL_CONTENT/categories")
test_endpoint "GET" "$BASE_URL_CONTENT/categories" "" "" "200"

# Extraire l'ID de la première catégorie
category_id=$(echo $categories_response | grep -o '"_id":"[^"]*' | head -1 | cut -d'"' -f4)
if [ -n "$category_id" ]; then
    echo "✓ Catégorie trouvée: $category_id"
else
    echo -e "${RED}✗ Aucune catégorie trouvée${NC}"
fi

# Test 5: Création d'une question
if [ -n "$token" ] && [ -n "$category_id" ]; then
    echo -e "\n${YELLOW}5. Création d'une question${NC}"
    question_data="{\"title\":\"Comment tester une API REST ?\",\"content\":\"Je cherche des conseils pour tester efficacement une API REST avec différents outils.\",\"categoryId\":\"$category_id\",\"tags\":[\"api\",\"test\",\"rest\"]}"
    question_response=$(curl -s -X POST "$BASE_URL_CONTENT/questions" -H "Content-Type: application/json" -H "Authorization: Bearer $token" -d "$question_data")
    test_endpoint "POST" "$BASE_URL_CONTENT/questions" "$question_data" "Authorization: Bearer $token" "201"
    
    # Extraire l'ID de la question créée
    question_id=$(echo $question_response | grep -o '"_id":"[^"]*' | head -1 | cut -d'"' -f4)
    if [ -n "$question_id" ]; then
        echo "✓ Question créée: $question_id"
    fi
fi

# Test 6: Récupération des questions par catégorie
if [ -n "$category_id" ]; then
    echo -e "\n${YELLOW}6. Récupération des questions par catégorie${NC}"
    test_endpoint "GET" "$BASE_URL_CONTENT/categories/$category_id/questions" "" "" "200"
fi

# Test 7: Création d'une réponse
if [ -n "$token" ] && [ -n "$question_id" ]; then
    echo -e "\n${YELLOW}7. Création d'une réponse${NC}"
    answer_data='{"content":"Pour tester une API REST, je recommande d\'utiliser Postman pour les tests manuels et Newman pour l\'automatisation. Il est important de tester tous les codes de statut HTTP et de valider les réponses JSON."}'
    answer_response=$(curl -s -X POST "$BASE_URL_CONTENT/questions/$question_id/answers" -H "Content-Type: application/json" -H "Authorization: Bearer $token" -d "$answer_data")
    test_endpoint "POST" "$BASE_URL_CONTENT/questions/$question_id/answers" "$answer_data" "Authorization: Bearer $token" "201"
    
    # Extraire l'ID de la réponse créée
    answer_id=$(echo $answer_response | grep -o '"_id":"[^"]*' | head -1 | cut -d'"' -f4)
    if [ -n "$answer_id" ]; then
        echo "✓ Réponse créée: $answer_id"
    fi
fi

# Test 8: Vote pour une réponse
if [ -n "$token" ] && [ -n "$answer_id" ]; then
    echo -e "\n${YELLOW}8. Vote pour une réponse${NC}"
    vote_data='{"vote":1}'
    test_endpoint "POST" "$BASE_URL_CONTENT/answers/$answer_id/vote" "$vote_data" "Authorization: Bearer $token" "200"
fi

# Test 9: Recherche de questions
echo -e "\n${YELLOW}9. Recherche de questions${NC}"
test_endpoint "GET" "$BASE_URL_CONTENT/questions/search?q=test" "" "" "200"

echo -e "\n${GREEN}🎉 Tests terminés !${NC}"
echo "Pour plus de tests détaillés, utilisez Postman avec la collection fournie."
EOF

chmod +x scripts/test_services.sh

# Script de nettoyage
cat > scripts/cleanup.sh << 'EOF'
#!/bin/bash

echo "🧹 Nettoyage de l'environnement QuizAcademy"
echo "==========================================="

# Arrêter et supprimer les conteneurs
echo "Arrêt des services Docker..."
cd backend
docker-compose down -v

# Supprimer les images
echo "Suppression des images Docker..."
docker rmi quizacademy_user-service quizacademy_content-service 2>/dev/null || true

# Supprimer les volumes
echo "Suppression des volumes..."
docker volume rm quizacademy-mongodb-data 2>/dev/null || true

# Nettoyer les images non utilisées
echo "Nettoyage des images non utilisées..."
docker image prune -f

# Nettoyer Flutter
echo "Nettoyage Flutter..."
cd ../mobile
flutter clean

echo "✅ Nettoyage terminé !"
EOF

chmod +x scripts/cleanup.sh

echo "✅ Documentation et scripts créés"

echo ""
echo "=========================================="
echo "🎉 Configuration terminée avec succès !"
echo "=========================================="
echo ""
echo "📁 Structure du projet créée :"
echo "   - backend/user-service (Java/Spring Boot)"
echo "   - backend/content-service (Node.js/Express)"  
echo "   - mobile (Flutter)"
echo "   - docs (Documentation)"
echo "   - scripts (Scripts utilitaires)"
echo ""
echo "🚀 Prochaines étapes :"
echo "   1. Démarrer les services backend :"
echo "      cd backend && docker-compose up -d"
echo ""
echo "   2. Configurer l'application mobile :"
echo "      cd mobile && flutter pub get"
echo ""
echo "   3. Tester les services :"
echo "      ./scripts/test_services.sh"
echo ""
echo "   4. Lancer l'application mobile :"
echo "      cd mobile && flutter run"
echo ""  
echo "📚 Documentation disponible :"
echo "   - README.md (Guide utilisateur)"
echo "   - docs/TECHNICAL_GUIDE.md (Guide technique)"
echo ""
echo "🔧 Scripts utilitaires :"
echo "   - scripts/test_services.sh (Tests automatiques)"
echo "   - scripts/cleanup.sh (Nettoyage)"
echo ""
echo "✨ Votre environnement QuizAcademy est prêt !"
echo "=========================================="
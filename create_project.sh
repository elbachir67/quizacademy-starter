#!/bin/bash

# Script de configuration du projet QuizAcademy
# Ce script va créer la structure du projet et les fichiers nécessaires
# pour démarrer le développement de l'application QuizAcademy

set -e # Le script s'arrête en cas d'erreur

echo "=== Création du projet QuizAcademy ==="
echo "Ce script va configurer l'environnement de développement complet"

# Création de la structure des répertoires
mkdir -p quizacademy/backend/user-service/src/main/java/com/quizacademy/userservice/{controller,model,repository,security,service}
mkdir -p quizacademy/backend/user-service/src/main/resources
mkdir -p quizacademy/backend/content-service/src/{controllers,models,routes,services}
mkdir -p quizacademy/mobile/lib/{models,providers,screens/auth,screens/questions,services,widgets}
mkdir -p quizacademy/mobile/assets/images

# Se positionner dans le répertoire racine
cd quizacademy

echo "=== Structure des répertoires créée ==="
echo "Création des fichiers pour le projet..."

# Création des fichiers de configuration Gradle pour le service utilisateur
echo "=== Configuration du service utilisateur (Java/Spring Boot) ==="

# Création du fichier build.gradle
cat > backend/user-service/build.gradle << 'EOF'
plugins {
    id 'org.springframework.boot' version '2.7.0'
    id 'io.spring.dependency-management' version '1.0.11.RELEASE'
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
    implementation 'io.jsonwebtoken:jjwt-api:0.11.5'
    runtimeOnly 'io.jsonwebtoken:jjwt-impl:0.11.5'
    runtimeOnly 'io.jsonwebtoken:jjwt-jackson:0.11.5'
    runtimeOnly 'com.h2database:h2'
    testImplementation 'org.springframework.boot:spring-boot-starter-test'
    testImplementation 'org.springframework.security:spring-security-test'
}

test {
    useJUnitPlatform()
}
EOF

# Création du fichier settings.gradle
cat > backend/user-service/settings.gradle << 'EOF'
rootProject.name = 'user-service'
EOF

# Création du fichier Dockerfile pour le service utilisateur
cat > backend/user-service/Dockerfile << 'EOF'
FROM gradle:7.6.1-jdk17 as build
WORKDIR /app
COPY build.gradle settings.gradle ./
COPY src ./src
RUN gradle build --no-daemon -x test

FROM openjdk:17-jdk-slim
WORKDIR /app
COPY --from=build /app/build/libs/*.jar app.jar
EXPOSE 8080
ENTRYPOINT ["java", "-jar", "app.jar"]
EOF

# Création de l'application principale Spring Boot
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

# Création du fichier application.properties
cat > backend/user-service/src/main/resources/application.properties << 'EOF'
# Configuration de la base de données H2
spring.datasource.url=jdbc:h2:mem:userdb
spring.datasource.driverClassName=org.h2.Driver
spring.datasource.username=sa
spring.datasource.password=password
spring.jpa.database-platform=org.hibernate.dialect.H2Dialect
spring.h2.console.enabled=true
spring.h2.console.path=/h2-console

# Configuration JPA
spring.jpa.hibernate.ddl-auto=update
spring.jpa.show-sql=true

# Configuration JWT
jwt.secret=your_jwt_secret_key_here
jwt.expirationMs=86400000

# Configuration du serveur
server.port=8080

# Configuration CORS
spring.mvc.cors.allowed-origins=*
spring.mvc.cors.allowed-methods=GET,POST,PUT,DELETE
spring.mvc.cors.allowed-headers=*
EOF

echo "=== Création du modèle User ==="
# Création du modèle User avec TODO-USER1
cat > backend/user-service/src/main/java/com/quizacademy/userservice/model/User.java << 'EOF'
package com.quizacademy.userservice.model;

import javax.persistence.*;
import java.time.LocalDateTime;
import java.util.HashSet;
import java.util.Set;

@Entity
@Table(name = "users")
public class User {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(nullable = false, unique = true)
    private String username;

    @Column(nullable = false, unique = true)
    private String email;

    @Column(nullable = false)
    private String password;

    @Column(name = "profile_picture")
    private String profilePicture;

    @ElementCollection(fetch = FetchType.EAGER)
    @CollectionTable(name = "user_roles", joinColumns = @JoinColumn(name = "user_id"))
    @Column(name = "role")
    private Set<String> roles = new HashSet<>();

    @Column(nullable = false)
    private LocalDateTime createdAt;

    // TODO-USER1: Ajouter les getters et setters pour tous les attributs
    // Assurez-vous d'initialiser createdAt dans les constructeurs
    
    // Constructeurs, getters et setters
}
EOF

# Création du DTO LoginRequest
cat > backend/user-service/src/main/java/com/quizacademy/userservice/dto/LoginRequest.java << 'EOF'
package com.quizacademy.userservice.dto;

public class LoginRequest {
    private String username;
    private String password;

    public LoginRequest() {
    }

    public LoginRequest(String username, String password) {
        this.username = username;
        this.password = password;
    }

    public String getUsername() {
        return username;
    }

    public void setUsername(String username) {
        this.username = username;
    }

    public String getPassword() {
        return password;
    }

    public void setPassword(String password) {
        this.password = password;
    }
}
EOF

echo "=== Création du service d'authentification ==="
# Création du repository UserRepository
cat > backend/user-service/src/main/java/com/quizacademy/userservice/repository/UserRepository.java << 'EOF'
package com.quizacademy.userservice.repository;

import com.quizacademy.userservice.model.User;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface UserRepository extends JpaRepository<User, Long> {
    User findByUsername(String username);
    boolean existsByUsername(String username);
    boolean existsByEmail(String email);
}
EOF

# Création de JwtTokenProvider
cat > backend/user-service/src/main/java/com/quizacademy/userservice/security/JwtTokenProvider.java << 'EOF'
package com.quizacademy.userservice.security;

import io.jsonwebtoken.Claims;
import io.jsonwebtoken.Jwts;
import io.jsonwebtoken.SignatureAlgorithm;
import io.jsonwebtoken.security.Keys;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.GrantedAuthority;
import org.springframework.security.core.authority.SimpleGrantedAuthority;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.stereotype.Component;

import javax.annotation.PostConstruct;
import javax.crypto.SecretKey;
import java.util.Base64;
import java.util.Collection;
import java.util.Date;
import java.util.Set;
import java.util.stream.Collectors;

@Component
public class JwtTokenProvider {

    @Value("${jwt.secret}")
    private String secretKey;

    @Value("${jwt.expirationMs}")
    private long validityInMilliseconds;
    
    private SecretKey key;

    @PostConstruct
    protected void init() {
        secretKey = Base64.getEncoder().encodeToString(secretKey.getBytes());
        key = Keys.hmacShaKeyFor(secretKey.getBytes());
    }

    public String createToken(String username, Set<String> roles) {
        Claims claims = Jwts.claims().setSubject(username);
        claims.put("roles", roles);

        Date now = new Date();
        Date validity = new Date(now.getTime() + validityInMilliseconds);

        return Jwts.builder()
                .setClaims(claims)
                .setIssuedAt(now)
                .setExpiration(validity)
                .signWith(key, SignatureAlgorithm.HS256)
                .compact();
    }

    public Authentication getAuthentication(String token) {
        UserDetails userDetails = new org.springframework.security.core.userdetails.User(
                getUsername(token),
                "",
                getAuthorities(token)
        );

        return new UsernamePasswordAuthenticationToken(userDetails, "", userDetails.getAuthorities());
    }

    public String getUsername(String token) {
        return Jwts.parserBuilder().setSigningKey(key).build().parseClaimsJws(token).getBody().getSubject();
    }

    private Collection<? extends GrantedAuthority> getAuthorities(String token) {
        Claims claims = Jwts.parserBuilder().setSigningKey(key).build().parseClaimsJws(token).getBody();
        Set<String> roles = claims.get("roles", Set.class);
        return roles.stream()
                .map(SimpleGrantedAuthority::new)
                .collect(Collectors.toList());
    }

    public boolean validateToken(String token) {
        try {
            Jwts.parserBuilder().setSigningKey(key).build().parseClaimsJws(token);
            return true;
        } catch (Exception e) {
            return false;
        }
    }
}
EOF

# Création de AuthService avec TODO-USER2 et TODO-USER3
cat > backend/user-service/src/main/java/com/quizacademy/userservice/service/AuthService.java << 'EOF'
package com.quizacademy.userservice.service;

import com.quizacademy.userservice.model.User;
import com.quizacademy.userservice.repository.UserRepository;
import com.quizacademy.userservice.security.JwtTokenProvider;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.authentication.AuthenticationManager;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.AuthenticationException;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;
import java.util.Collections;
import java.util.HashMap;
import java.util.Map;

@Service
public class AuthService {

    private final UserRepository userRepository;
    private final PasswordEncoder passwordEncoder;
    private final JwtTokenProvider jwtTokenProvider;
    private final AuthenticationManager authenticationManager;

    @Autowired
    public AuthService(UserRepository userRepository, PasswordEncoder passwordEncoder,
                       JwtTokenProvider jwtTokenProvider, AuthenticationManager authenticationManager) {
        this.userRepository = userRepository;
        this.passwordEncoder = passwordEncoder;
        this.jwtTokenProvider = jwtTokenProvider;
        this.authenticationManager = authenticationManager;
    }

    // TODO-USER2: Implementer la methode d'inscription
    // Cette methode doit :
    // - Verifier si l'utilisateur existe deja (email ou username)
    // - Encoder le mot de passe avec passwordEncoder
    // - Assigner le role "ROLE_USER" par defaut
    // - Initialiser createdAt a la date actuelle
    // - Sauvegarder l'utilisateur et retourner l'objet cree
    public User register(User user) {
        // A implementer
        return null;
    }

    // TODO-USER3: Implementer la methode d'authentification
    // Cette methode doit :
    // - Authentifier l'utilisateur avec authenticationManager
    // - Generer un token JWT avec jwtTokenProvider
    // - Retourner une Map contenant le token et les infos utilisateur
    public Map<String, Object> login(String username, String password) {
        // A implementer
        return null;
    }
}
EOF

# Création du contrôleur d'authentification avec TODO-USER4 et TODO-USER5
cat > backend/user-service/src/main/java/com/quizacademy/userservice/controller/AuthController.java << 'EOF'
package com.quizacademy.userservice.controller;

import com.quizacademy.userservice.dto.LoginRequest;
import com.quizacademy.userservice.model.User;
import com.quizacademy.userservice.service.AuthService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.Map;

@RestController
@RequestMapping("/api/auth")
@CrossOrigin(origins = "*")
public class AuthController {

    private final AuthService authService;

    @Autowired
    public AuthController(AuthService authService) {
        this.authService = authService;
    }

    // TODO-USER4: Implementer l'endpoint d'inscription
    // Cet endpoint doit :
    // - Appeler authService.register avec l'utilisateur recu
    // - Retourner un code 201 CREATED avec l'utilisateur cree (sans le mot de passe)
    // - Gerer les erreurs possibles (ex: email deja utilise)
    @PostMapping("/register")
    public ResponseEntity<?> registerUser(@RequestBody User user) {
        // A implementer
        return null;
    }

    // TODO-USER5: Implementer l'endpoint de connexion
    // Cet endpoint doit :
    // - Appeler authService.login avec username et password
    // - Retourner le token et les infos utilisateur avec un code 200 OK
    // - Gerer les erreurs d'authentification
    @PostMapping("/login")
    public ResponseEntity<?> login(@RequestBody LoginRequest loginRequest) {
        // A implementer
        return null;
    }
}
EOF

# Configuration Spring Security
cat > backend/user-service/src/main/java/com/quizacademy/userservice/security/WebSecurityConfig.java << 'EOF'
package com.quizacademy.userservice.security;

import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.security.authentication.AuthenticationManager;
import org.springframework.security.config.annotation.authentication.configuration.AuthenticationConfiguration;
import org.springframework.security.config.annotation.web.builders.HttpSecurity;
import org.springframework.security.config.annotation.web.configuration.EnableWebSecurity;
import org.springframework.security.config.http.SessionCreationPolicy;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.security.web.SecurityFilterChain;
import org.springframework.web.cors.CorsConfiguration;
import org.springframework.web.cors.CorsConfigurationSource;
import org.springframework.web.cors.UrlBasedCorsConfigurationSource;

import java.util.Arrays;

@Configuration
@EnableWebSecurity
public class WebSecurityConfig {

    @Bean
    public SecurityFilterChain filterChain(HttpSecurity http) throws Exception {
        http
            .cors().and().csrf().disable()
            .sessionManagement().sessionCreationPolicy(SessionCreationPolicy.STATELESS)
            .and()
            .authorizeRequests()
            .antMatchers("/api/auth/**").permitAll()
            .antMatchers("/h2-console/**").permitAll()
            .anyRequest().authenticated();
        
        // Pour permettre l'accès à la console H2
        http.headers().frameOptions().disable();
        
        return http.build();
    }

    @Bean
    public PasswordEncoder passwordEncoder() {
        return new BCryptPasswordEncoder();
    }

    @Bean
    public AuthenticationManager authenticationManager(AuthenticationConfiguration authenticationConfiguration) throws Exception {
        return authenticationConfiguration.getAuthenticationManager();
    }

    @Bean
    public CorsConfigurationSource corsConfigurationSource() {
        CorsConfiguration configuration = new CorsConfiguration();
        configuration.setAllowedOrigins(Arrays.asList("*"));
        configuration.setAllowedMethods(Arrays.asList("GET", "POST", "PUT", "PATCH", "DELETE", "OPTIONS"));
        configuration.setAllowedHeaders(Arrays.asList("authorization", "content-type", "x-auth-token"));
        configuration.setExposedHeaders(Arrays.asList("x-auth-token"));
        UrlBasedCorsConfigurationSource source = new UrlBasedCorsConfigurationSource();
        source.registerCorsConfiguration("/**", configuration);
        return source;
    }
}
EOF

echo "=== Service utilisateur configuré avec succès ==="

# Ajout du Gradle Wrapper au service utilisateur
echo "=== Ajout du Gradle Wrapper ==="
cd backend/user-service

# Création du wrapper.gradle pour configurer le Gradle Wrapper
cat > wrapper.gradle << 'EOF'
tasks.withType(Wrapper) {
    gradleVersion = '7.6.1'
    distributionType = Wrapper.DistributionType.BIN
}
EOF

# Initialisation du Gradle Wrapper
# Cette commande crée les fichiers gradlew, gradlew.bat et le répertoire gradle/wrapper
cat > init-wrapper.sh << 'EOF'
#!/bin/bash
gradle -b wrapper.gradle wrapper
EOF

# Rendre le script exécutable
chmod +x init-wrapper.sh

# Exécuter le script pour créer le wrapper
./init-wrapper.sh

# Suppression des fichiers temporaires
rm wrapper.gradle init-wrapper.sh

# Revenir au répertoire principal
cd ../..

echo "=== Gradle Wrapper configuré avec succès ==="

echo "=== Configuration du service Content (Node.js/Express) ==="

# Création du package.json
cat > backend/content-service/package.json << 'EOF'
{
  "name": "content-service",
  "version": "1.0.0",
  "description": "Service de gestion du contenu pour QuizAcademy",
  "main": "src/index.js",
  "scripts": {
    "start": "node src/index.js",
    "dev": "nodemon src/index.js",
    "test": "echo \"Error: no test specified\" && exit 1"
  },
  "dependencies": {
    "cors": "^2.8.5",
    "dotenv": "^16.0.0",
    "express": "^4.17.3",
    "jsonwebtoken": "^8.5.1",
    "mongoose": "^6.2.10",
    "morgan": "^1.10.0",
    "node-fetch": "^2.6.7"
  },
  "devDependencies": {
    "nodemon": "^2.0.15"
  }
}
EOF

# Création du Dockerfile
cat > backend/content-service/Dockerfile << 'EOF'
FROM node:18-alpine
WORKDIR /app
COPY package*.json ./
RUN npm install
COPY . .
EXPOSE 3000
CMD ["npm", "start"]
EOF

# Création du fichier principal index.js
cat > backend/content-service/src/index.js << 'EOF'
const express = require('express');
const mongoose = require('mongoose');
const cors = require('cors');
const morgan = require('morgan');
const dotenv = require('dotenv');

// Routes
const categoryRoutes = require('./routes/category.routes');
const questionRoutes = require('./routes/question.routes');
const answerRoutes = require('./routes/answer.routes');

// Configuration
dotenv.config();
const app = express();
const PORT = process.env.PORT || 3000;
const MONGODB_URI = process.env.MONGODB_URI || 'mongodb://localhost:27017/quizacademy';

// Middleware
app.use(cors());
app.use(express.json());
app.use(morgan('dev'));

// Connexion à MongoDB
mongoose.connect(MONGODB_URI, {
  useNewUrlParser: true,
  useUnifiedTopology: true,
})
.then(() => console.log('Connexion à MongoDB établie'))
.catch(err => console.error('Erreur de connexion à MongoDB:', err));

// Routes API
app.use('/api/categories', categoryRoutes);
app.use('/api/questions', questionRoutes);
app.use('/api/answers', answerRoutes);

// Route de base
app.get('/', (req, res) => {
  res.json({ message: 'Content Service API' });
});

// Démarrage du serveur
app.listen(PORT, () => {
  console.log(`Serveur en cours d'exécution sur le port ${PORT}`);
});
EOF

# Création d'un fichier .env
cat > backend/content-service/.env << 'EOF'
PORT=3000
MONGODB_URI=mongodb://mongodb:27017/quizacademy
USER_SERVICE_URL=http://user-service:8080
JWT_SECRET=your_jwt_secret_key_here
EOF

# Modèle de question (TODO-CONTENT1)
cat > backend/content-service/src/models/question.model.js << 'EOF'
const mongoose = require('mongoose');
const Schema = mongoose.Schema;

// TODO-CONTENT1: Definir le schema de Question
// Le schema doit contenir les champs suivants :
// - title : titre de la question (obligatoire)
// - content : contenu detaille de la question (obligatoire)
// - authorId : ID de l'utilisateur qui a pose la question (obligatoire)
// - authorName : nom d'utilisateur de l'auteur (obligatoire)
// - categoryId : ID de la categorie (obligatoire)
// - tags : tableau de tags (optionnel)
// - viewCount : nombre de vues (defaut: 0)
// - createdAt : date de creation (auto)
// - updatedAt : date de mise a jour (auto)

const QuestionSchema = new Schema(
  {
    // A implementer
  },
  {
    timestamps: true
  }
);

// Indexes pour ameliorer les performances des requetes
QuestionSchema.index({ title: 'text', content: 'text' });
QuestionSchema.index({ authorId: 1 });
QuestionSchema.index({ categoryId: 1 });
QuestionSchema.index({ tags: 1 });

module.exports = mongoose.model('Question', QuestionSchema);
EOF

# Modèle de réponse (TODO-CONTENT2)
cat > backend/content-service/src/models/answer.model.js << 'EOF'
const mongoose = require('mongoose');
const Schema = mongoose.Schema;

// TODO-CONTENT2: Definir le schema de Answer
// Le schema doit contenir les champs suivants :
// - questionId : reference a la question (obligatoire)
// - content : contenu de la reponse (obligatoire)
// - authorId : ID de l'utilisateur qui a repondu (obligatoire)
// - authorName : nom d'utilisateur de l'auteur (obligatoire)
// - votes : tableau d'objets contenant userId et vote (+1 ou -1)
// - score : score total des votes (defaut: 0)
// - createdAt : date de creation (auto)
// - updatedAt : date de mise a jour (auto)

const AnswerSchema = new Schema(
  {
    // A implementer
  },
  {
    timestamps: true
  }
);

// Indexes
AnswerSchema.index({ questionId: 1 });
AnswerSchema.index({ authorId: 1 });
AnswerSchema.index({ score: -1 });

module.exports = mongoose.model('Answer', AnswerSchema);
EOF

# Modèle de catégorie
cat > backend/content-service/src/models/category.model.js << 'EOF'
const mongoose = require('mongoose');
const Schema = mongoose.Schema;

const CategorySchema = new Schema(
  {
    name: {
      type: String,
      required: true,
      unique: true,
      trim: true
    },
    description: {
      type: String,
      required: true,
      trim: true
    }
  },
  {
    timestamps: true
  }
);

module.exports = mongoose.model('Category', CategorySchema);
EOF

# Service utilisateur pour vérifier les tokens JWT
cat > backend/content-service/src/services/user.service.js << 'EOF'
const jwt = require('jsonwebtoken');
const fetch = require('node-fetch');

const JWT_SECRET = process.env.JWT_SECRET || 'your_jwt_secret_key_here';
const USER_SERVICE_URL = process.env.USER_SERVICE_URL || 'http://localhost:8080';

exports.verifyToken = (req) => {
  try {
    // Récupération du token depuis les headers
    const authHeader = req.headers.authorization;
    if (!authHeader || !authHeader.startsWith('Bearer ')) {
      return null;
    }

    const token = authHeader.split(' ')[1];
    
    // Vérification du token JWT
    const decodedToken = jwt.verify(token, JWT_SECRET);
    
    return {
      userId: decodedToken.sub,
      username: decodedToken.sub,
      roles: decodedToken.roles
    };
  } catch (error) {
    console.error('Erreur de vérification du token:', error);
    return null;
  }
};

exports.getUserDetails = async (userId) => {
  try {
    const response = await fetch(`${USER_SERVICE_URL}/api/users/${userId}`);
    if (!response.ok) {
      throw new Error('Impossible de récupérer les détails de l'utilisateur');
    }
    return await response.json();
  } catch (error) {
    console.error('Erreur lors de la récupération des détails de l'utilisateur:', error);
    return null;
  }
};
EOF

# Contrôleur pour les questions (TODO-CONTENT3 et TODO-CONTENT4)
cat > backend/content-service/src/controllers/question.controller.js << 'EOF'
const Question = require('../models/question.model');
const Answer = require('../models/answer.model');
const userService = require('../services/user.service');

// TODO-CONTENT3: Implementer la fonction de creation de question
// Cette fonction doit :
// 1. Extraire les donnees de la requete (title, content, categoryId, tags)
// 2. Verifier que l'utilisateur existe via userService.verifyToken
// 3. Creer la question en base de donnees
// 4. Retourner la question creee avec un statut 201
exports.createQuestion = async (req, res) => {
  try {
    // A implementer
  } catch (error) {
    console.error('Error creating question:', error);
    res.status(500).json({ error: 'Failed to create question' });
  }
};

// TODO-CONTENT4: Implementer la fonction de recuperation des questions par categorie
// Cette fonction doit :
// 1. Extraire l'ID de categorie des parametres de route
// 2. Recuperer les questions filtrees par categorie
// 3. Trier par date de creation (plus recentes d'abord)
// 4. Paginer les resultats (utiliser req.query.page et req.query.limit)
exports.getQuestionsByCategory = async (req, res) => {
  try {
    // A implementer
  } catch (error) {
    console.error('Error fetching questions by category:', error);
    res.status(500).json({ error: 'Failed to fetch questions' });
  }
};

// Fonction pour récupérer une question par ID
exports.getQuestionById = async (req, res) => {
  try {
    const questionId = req.params.questionId;
    
    // Récupérer la question
    const question = await Question.findById(questionId);
    if (!question) {
      return res.status(404).json({ error: 'Question not found' });
    }
    
    // Incrémenter le nombre de vues
    question.viewCount += 1;
    await question.save();
    
    // Récupérer les réponses associées
    const answers = await Answer.find({ questionId }).sort({ score: -1 });
    
    res.status(200).json({
      question,
      answers
    });
  } catch (error) {
    console.error('Error fetching question:', error);
    res.status(500).json({ error: 'Failed to fetch question' });
  }
};

// Fonction pour rechercher des questions
exports.searchQuestions = async (req, res) => {
  try {
    const { query } = req.query;
    const page = parseInt(req.query.page) || 1;
    const limit = parseInt(req.query.limit) || 10;
    const skip = (page - 1) * limit;
    
    if (!query) {
      return res.status(400).json({ error: 'Search query is required' });
    }
    
    const questions = await Question.find(
      { $text: { $search: query } },
      { score: { $meta: 'textScore' } }
    )
      .sort({ score: { $meta: 'textScore' } })
      .skip(skip)
      .limit(limit);
    
    const totalQuestions = await Question.countDocuments({ $text: { $search: query } });
    
    res.status(200).json({
      questions,
      pagination: {
        currentPage: page,
        totalPages: Math.ceil(totalQuestions / limit),
        totalItems: totalQuestions,
        hasMore: skip + questions.length < totalQuestions
      }
    });
  } catch (error) {
    console.error('Error searching questions:', error);
    res.status(500).json({ error: 'Failed to search questions' });
  }
};

// Fonction pour mettre à jour une question
exports.updateQuestion = async (req, res) => {
  try {
    const { questionId } = req.params;
    const { title, content, tags } = req.body;
    
    // Vérifier l'authentification
    const decodedToken = userService.verifyToken(req);
    if (!decodedToken) {
      return res.status(401).json({ error: 'Unauthorized' });
    }
    
    // Récupérer la question
    const question = await Question.findById(questionId);
    if (!question) {
      return res.status(404).json({ error: 'Question not found' });
    }
    
    // Vérifier que l'utilisateur est l'auteur
    if (question.authorId !== decodedToken.userId) {
      return res.status(403).json({ error: 'Not authorized to update this question' });
    }
    
    // Mettre à jour la question
    question.title = title || question.title;
    question.content = content || question.content;
    question.tags = tags || question.tags;
    
    const updatedQuestion = await question.save();
    
    res.status(200).json(updatedQuestion);
  } catch (error) {
    console.error('Error updating question:', error);
    res.status(500).json({ error: 'Failed to update question' });
  }
};

// Fonction pour supprimer une question
exports.deleteQuestion = async (req, res) => {
  try {
    const { questionId } = req.params;
    
    // Vérifier l'authentification
    const decodedToken = userService.verifyToken(req);
    if (!decodedToken) {
      return res.status(401).json({ error: 'Unauthorized' });
    }
    
    // Récupérer la question
    const question = await Question.findById(questionId);
    if (!question) {
      return res.status(404).json({ error: 'Question not found' });
    }
    
    // Vérifier que l'utilisateur est l'auteur ou un admin
    if (question.authorId !== decodedToken.userId && !decodedToken.roles.includes('ROLE_ADMIN')) {
      return res.status(403).json({ error: 'Not authorized to delete this question' });
    }
    
    // Supprimer la question
    await Question.findByIdAndDelete(questionId);
    
    // Supprimer toutes les réponses associées
    await Answer.deleteMany({ questionId });
    
    res.status(200).json({ message: 'Question deleted successfully' });
  } catch (error) {
    console.error('Error deleting question:', error);
    res.status(500).json({ error: 'Failed to delete question' });
  }
};
EOF

# Contrôleur pour les réponses (TODO-CONTENT5 et TODO-CONTENT6)
cat > backend/content-service/src/controllers/answer.controller.js << 'EOF'
const Answer = require('../models/answer.model');
const Question = require('../models/question.model');
const userService = require('../services/user.service');

// TODO-CONTENT5: Implementer la fonction de creation de reponse
// Cette fonction doit :
// 1. Extraire les donnees de la requete (content) et l'ID de question des parametres
// 2. Verifier que l'utilisateur existe via userService.verifyToken
// 3. Verifier que la question existe
// 4. Creer la reponse en base de donnees
// 5. Retourner la reponse creee avec un statut 201
exports.createAnswer = async (req, res) => {
  try {
    // A implementer
  } catch (error) {
    console.error('Error creating answer:', error);
    res.status(500).json({ error: 'Failed to create answer' });
  }
};

// TODO-CONTENT6: Implementer la fonction de vote pour une reponse
// Cette fonction doit :
// 1. Extraire l'ID de reponse des parametres et le vote du corps (1 ou -1)
// 2. Verifier que l'utilisateur existe via userService.verifyToken
// 3. Verifier si l'utilisateur a deja vote pour cette reponse
// 4. Mettre a jour le tableau de votes et recalculer le score
// 5. Retourner la reponse mise a jour
exports.voteAnswer = async (req, res) => {
  try {
    // A implementer
  } catch (error) {
    console.error('Error voting for answer:', error);
    res.status(500).json({ error: 'Failed to vote for answer' });
  }
};

// Fonction pour récupérer les réponses d'une question
exports.getAnswersByQuestion = async (req, res) => {
  try {
    const { questionId } = req.params;
    
    // Vérifier que la question existe
    const questionExists = await Question.exists({ _id: questionId });
    if (!questionExists) {
      return res.status(404).json({ error: 'Question not found' });
    }
    
    // Récupérer les réponses triées par score
    const answers = await Answer.find({ questionId }).sort({ score: -1 });
    
    res.status(200).json(answers);
  } catch (error) {
    console.error('Error fetching answers:', error);
    res.status(500).json({ error: 'Failed to fetch answers' });
  }
};

// Fonction pour supprimer une réponse
exports.deleteAnswer = async (req, res) => {
  try {
    const { answerId } = req.params;
    
    // Vérifier l'authentification
    const decodedToken = userService.verifyToken(req);
    if (!decodedToken) {
      return res.status(401).json({ error: 'Unauthorized' });
    }
    
    // Récupérer la réponse
    const answer = await Answer.findById(answerId);
    if (!answer) {
      return res.status(404).json({ error: 'Answer not found' });
    }
    
    // Vérifier que l'utilisateur est l'auteur ou un admin
    if (answer.authorId !== decodedToken.userId && !decodedToken.roles.includes('ROLE_ADMIN')) {
      return res.status(403).json({ error: 'Not authorized to delete this answer' });
    }
    
    // Supprimer la réponse
    await Answer.findByIdAndDelete(answerId);
    
    res.status(200).json({ message: 'Answer deleted successfully' });
  } catch (error) {
    console.error('Error deleting answer:', error);
    res.status(500).json({ error: 'Failed to delete answer' });
  }
};
EOF

# Contrôleur pour les catégories
cat > backend/content-service/src/controllers/category.controller.js << 'EOF'
const Category = require('../models/category.model');
const userService = require('../services/user.service');

// Récupérer toutes les catégories
exports.getAllCategories = async (req, res) => {
  try {
    const categories = await Category.find().sort({ name: 1 });
    res.status(200).json(categories);
  } catch (error) {
    console.error('Error fetching categories:', error);
    res.status(500).json({ error: 'Failed to fetch categories' });
  }
};

// Créer une nouvelle catégorie
exports.createCategory = async (req, res) => {
  try {
    // Vérifier l'authentification
    const decodedToken = userService.verifyToken(req);
    if (!decodedToken) {
      return res.status(401).json({ error: 'Unauthorized' });
    }
    
    // Vérifier si l'utilisateur est admin
    if (!decodedToken.roles.includes('ROLE_ADMIN')) {
      return res.status(403).json({ error: 'Not authorized to create categories' });
    }
    
    const { name, description } = req.body;
    
    // Vérifier que le nom est unique
    const existingCategory = await Category.findOne({ name });
    if (existingCategory) {
      return res.status(400).json({ error: 'Category with this name already exists' });
    }
    
    // Créer la catégorie
    const category = new Category({
      name,
      description
    });
    
    const savedCategory = await category.save();
    
    res.status(201).json(savedCategory);
  } catch (error) {
    console.error('Error creating category:', error);
    res.status(500).json({ error: 'Failed to create category' });
  }
};

// Récupérer une catégorie par ID
exports.getCategoryById = async (req, res) => {
  try {
    const { categoryId } = req.params;
    
    const category = await Category.findById(categoryId);
    if (!category) {
      return res.status(404).json({ error: 'Category not found' });
    }
    
    res.status(200).json(category);
  } catch (error) {
    console.error('Error fetching category:', error);
    res.status(500).json({ error: 'Failed to fetch category' });
  }
};

// Mettre à jour une catégorie
exports.updateCategory = async (req, res) => {
  try {
    // Vérifier l'authentification
    const decodedToken = userService.verifyToken(req);
    if (!decodedToken) {
      return res.status(401).json({ error: 'Unauthorized' });
    }
    
    // Vérifier si l'utilisateur est admin
    if (!decodedToken.roles.includes('ROLE_ADMIN')) {
      return res.status(403).json({ error: 'Not authorized to update categories' });
    }
    
    const { categoryId } = req.params;
    const { name, description } = req.body;
    
    // Vérifier que la catégorie existe
    const category = await Category.findById(categoryId);
    if (!category) {
      return res.status(404).json({ error: 'Category not found' });
    }
    
    // Vérifier que le nouveau nom est unique (si changé)
    if (name && name !== category.name) {
      const existingCategory = await Category.findOne({ name });
      if (existingCategory) {
        return res.status(400).json({ error: 'Category with this name already exists' });
      }
    }
    
    // Mettre à jour
    category.name = name || category.name;
    category.description = description || category.description;
    
    const updatedCategory = await category.save();
    
    res.status(200).json(updatedCategory);
  } catch (error) {
    console.error('Error updating category:', error);
    res.status(500).json({ error: 'Failed to update category' });
  }
};

// Supprimer une catégorie
exports.deleteCategory = async (req, res) => {
  try {
    // Vérifier l'authentification
    const decodedToken = userService.verifyToken(req);
    if (!decodedToken) {
      return res.status(401).json({ error: 'Unauthorized' });
    }
    
    // Vérifier si l'utilisateur est admin
    if (!decodedToken.roles.includes('ROLE_ADMIN')) {
      return res.status(403).json({ error: 'Not authorized to delete categories' });
    }
    
    const { categoryId } = req.params;
    
    const result = await Category.findByIdAndDelete(categoryId);
    if (!result) {
      return res.status(404).json({ error: 'Category not found' });
    }
    
    res.status(200).json({ message: 'Category deleted successfully' });
  } catch (error) {
    console.error('Error deleting category:', error);
    res.status(500).json({ error: 'Failed to delete category' });
  }
};
EOF

# Routes pour les catégories
cat > backend/content-service/src/routes/category.routes.js << 'EOF'
const express = require('express');
const categoryController = require('../controllers/category.controller');
const router = express.Router();

// Routes pour les catégories
router.get('/', categoryController.getAllCategories);
router.post('/', categoryController.createCategory);
router.get('/:categoryId', categoryController.getCategoryById);
router.put('/:categoryId', categoryController.updateCategory);
router.delete('/:categoryId', categoryController.deleteCategory);

// Route pour récupérer les questions d'une catégorie
router.get('/:categoryId/questions', require('../controllers/question.controller').getQuestionsByCategory);

module.exports = router;
EOF

# Routes pour les questions
cat > backend/content-service/src/routes/question.routes.js << 'EOF'
const express = require('express');
const questionController = require('../controllers/question.controller');
const router = express.Router();

// Routes pour les questions
router.post('/', questionController.createQuestion);
router.get('/:questionId', questionController.getQuestionById);
router.put('/:questionId', questionController.updateQuestion);
router.delete('/:questionId', questionController.deleteQuestion);
router.get('/search', questionController.searchQuestions);

// Route pour créer une réponse à une question
router.post('/:questionId/answers', require('../controllers/answer.controller').createAnswer);

// Route pour récupérer les réponses d'une question
router.get('/:questionId/answers', require('../controllers/answer.controller').getAnswersByQuestion);

module.exports = router;
EOF

# Routes pour les réponses
cat > backend/content-service/src/routes/answer.routes.js << 'EOF'
const express = require('express');
const answerController = require('../controllers/answer.controller');
const router = express.Router();

// Routes pour les réponses
router.post('/:answerId/vote', answerController.voteAnswer);
router.delete('/:answerId', answerController.deleteAnswer);

module.exports = router;
EOF

echo "=== Service Content configuré avec succès ==="

echo "=== Configuration de l'application mobile Flutter ==="

# Création du fichier pubspec.yaml
cat > mobile/pubspec.yaml << 'EOF'
name: quizacademy
description: A Q&A platform for academic knowledge sharing.

publish_to: 'none'
version: 1.0.0+1

environment:
  sdk: ">=2.17.0 <3.0.0"

dependencies:
  flutter:
    sdk: flutter
  http: ^0.13.5
  provider: ^6.0.3
  shared_preferences: ^2.0.15
  intl: ^0.17.0
  flutter_markdown: ^0.6.13
  cupertino_icons: ^1.0.5

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^2.0.1

flutter:
  uses-material-design: true
  assets:
    - assets/images/
EOF

# Fichier de configuration pour les API
cat > mobile/lib/config/api_config.dart << 'EOF'
class ApiConfig {
  static const String baseUrl = 'http://10.0.2.2:8080/api'; // Pour l'émulateur Android
  static const String contentServiceUrl = 'http://10.0.2.2:3000/api'; // Service Content
}
EOF

# Création du modèle User
cat > mobile/lib/models/user.dart << 'EOF'
class User {
  final String? id;
  final String username;
  final String email;
  final String? profilePicture;
  final List<String> roles;
  final DateTime createdAt;

  User({
    this.id,
    required this.username,
    required this.email,
    this.profilePicture,
    required this.roles,
    required this.createdAt,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id']?.toString(),
      username: json['username'],
      email: json['email'],
      profilePicture: json['profilePicture'],
      roles: List<String>.from(json['roles'] ?? []),
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'profilePicture': profilePicture,
      'roles': roles,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
EOF

# Création du modèle Question
cat > mobile/lib/models/question.dart << 'EOF'
class Question {
  final String id;
  final String title;
  final String content;
  final String authorId;
  final String authorName;
  final String categoryId;
  final List<String> tags;
  final int viewCount;
  final DateTime createdAt;
  final DateTime updatedAt;

  Question({
    required this.id,
    required this.title,
    required this.content,
    required this.authorId,
    required this.authorName,
    required this.categoryId,
    required this.tags,
    required this.viewCount,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Question.fromJson(Map<String, dynamic> json) {
    return Question(
      id: json['_id'] ?? json['id'],
      title: json['title'],
      content: json['content'],
      authorId: json['authorId'],
      authorName: json['authorName'],
      categoryId: json['categoryId'],
      tags: List<String>.from(json['tags'] ?? []),
      viewCount: json['viewCount'] ?? 0,
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
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}
EOF

# Création du modèle Answer
cat > mobile/lib/models/answer.dart << 'EOF'
class Answer {
  final String id;
  final String questionId;
  final String content;
  final String authorId;
  final String authorName;
  final List<Vote> votes;
  final int score;
  final DateTime createdAt;
  final DateTime updatedAt;

  Answer({
    required this.id,
    required this.questionId,
    required this.content,
    required this.authorId,
    required this.authorName,
    required this.votes,
    required this.score,
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
      questionId: json['questionId'],
      content: json['content'],
      authorId: json['authorId'],
      authorName: json['authorName'],
      votes: votesList,
      score: json['score'] ?? 0,
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
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
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
      userId: json['userId'],
      vote: json['vote'],
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

# Création du modèle Category
cat > mobile/lib/models/category.dart << 'EOF'
class Category {
  final String id;
  final String name;
  final String description;
  final DateTime createdAt;
  final DateTime updatedAt;

  Category({
    required this.id,
    required this.name,
    required this.description,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['_id'] ?? json['id'],
      name: json['name'],
      description: json['description'],
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
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}
EOF

# Création du service d'authentification avec TODO-FL1 et TODO-FL2
cat > mobile/lib/services/auth_service.dart << 'EOF'
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../config/api_config.dart';
import '../models/user.dart';

class AuthService {
  final String baseUrl = '${ApiConfig.baseUrl}/auth';

  // TODO-FL1: Implementer la methode d'inscription
  // Cette methode doit :
  // - Faire une requete POST a /auth/register avec les donnees utilisateur
  // - Gerer les reponses de succes et d'erreur
  // - Retourner l'utilisateur cree en cas de succes
  Future<User> register(String username, String email, String password) async {
    // A implementer
    return User(
      username: '',
      email: '',
      roles: [],
      createdAt: DateTime.now(),
    );
  }

  // TODO-FL2: Implementer la methode de connexion
  // Cette methode doit :
  // - Faire une requete POST a /auth/login avec username et password
  // - Sauvegarder le token JWT recu dans les SharedPreferences
  // - Retourner l'utilisateur connecte
  Future<User> login(String username, String password) async {
    // A implementer
    return User(
      username: '',
      email: '',
      roles: [],
      createdAt: DateTime.now(),
    );
  }

  // Récupérer le token JWT depuis les SharedPreferences
  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  // Vérifier si l'utilisateur est connecté
  Future<bool> isLoggedIn() async {
    final token = await getToken();
    return token != null;
  }

  // Récupérer l'utilisateur connecté
  Future<User?> getCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userJson = prefs.getString('current_user');
    
    if (userJson != null) {
      return User.fromJson(json.decode(userJson));
    }
    
    return null;
  }

  // Déconnexion
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
    await prefs.remove('current_user');
  }
}
EOF

# Création du service de questions avec TODO-FL3 et TODO-FL4
cat > mobile/lib/services/question_service.dart << 'EOF'
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../models/question.dart';
import '../models/category.dart';
import 'auth_service.dart';

class QuestionService {
  final String baseUrl = '${ApiConfig.contentServiceUrl}';
  final AuthService authService = AuthService();

  // TODO-FL3: Implementer la methode pour recuperer les questions par categorie
  // Cette methode doit :
  // - Faire une requete GET a /categories/{categoryId}/questions
  // - Gerer la pagination (parametres page et limit)
  // - Parser la reponse en liste de Question
  Future<Map<String, dynamic>> getQuestionsByCategory(String categoryId, {int page = 1, int limit = 10}) async {
    // A implementer
    return {
      'questions': <Question>[],
      'pagination': {
        'currentPage': 1,
        'totalPages': 1,
        'totalItems': 0,
        'hasMore': false
      }
    };
  }

  // TODO-FL4: Implementer la methode pour creer une question
  // Cette methode doit :
  // - Recuperer le token JWT avec authService.getToken()
  // - Faire une requete POST a /questions avec les donnees et le token
  // - Retourner la question creee
  Future<Question> createQuestion(String title, String content, String categoryId, List<String> tags) async {
    // A implementer
    return Question(
      id: '',
      title: '',
      content: '',
      authorId: '',
      authorName: '',
      categoryId: '',
      tags: [],
      viewCount: 0,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  // Récupérer une question par son ID
  Future<Map<String, dynamic>> getQuestionById(String questionId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/questions/$questionId'),
    );

    if (response.statusCode == 200) {
      final responseData = json.decode(response.body);
      
      final question = Question.fromJson(responseData['question']);
      final answers = (responseData['answers'] as List)
          .map((answerJson) => Answer.fromJson(answerJson))
          .toList();
      
      return {
        'question': question,
        'answers': answers,
      };
    } else {
      final errorData = json.decode(response.body);
      throw Exception(errorData['error'] ?? 'Failed to fetch question');
    }
  }

  // Rechercher des questions
  Future<Map<String, dynamic>> searchQuestions(String query, {int page = 1, int limit = 10}) async {
    final response = await http.get(
      Uri.parse('$baseUrl/questions/search?query=$query&page=$page&limit=$limit'),
    );

    if (response.statusCode == 200) {
      final responseData = json.decode(response.body);
      
      final List<Question> questions = (responseData['questions'] as List)
          .map((questionJson) => Question.fromJson(questionJson))
          .toList();
      
      return {
        'questions': questions,
        'pagination': responseData['pagination'],
      };
    } else {
      final errorData = json.decode(response.body);
      throw Exception(errorData['error'] ?? 'Failed to search questions');
    }
  }
}
EOF

# Création du service de réponses
cat > mobile/lib/services/answer_service.dart << 'EOF'
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../models/answer.dart';
import 'auth_service.dart';

class AnswerService {
  final String baseUrl = '${ApiConfig.contentServiceUrl}';
  final AuthService authService = AuthService();

  // Créer une réponse
  Future<Answer> createAnswer(String questionId, String content) async {
    final token = await authService.getToken();
    if (token == null) {
      throw Exception('User not authenticated');
    }
    
    final response = await http.post(
      Uri.parse('$baseUrl/questions/$questionId/answers'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: json.encode({
        'content': content,
      }),
    );

    if (response.statusCode == 201) {
      final responseData = json.decode(response.body);
      return Answer.fromJson(responseData);
    } else {
      final errorData = json.decode(response.body);
      throw Exception(errorData['error'] ?? 'Failed to create answer');
    }
  }

  // Voter pour une réponse
  Future<Answer> voteAnswer(String answerId, int vote) async {
    final token = await authService.getToken();
    if (token == null) {
      throw Exception('User not authenticated');
    }
    
    final response = await http.post(
      Uri.parse('$baseUrl/answers/$answerId/vote'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: json.encode({
        'vote': vote,
      }),
    );

    if (response.statusCode == 200) {
      final responseData = json.decode(response.body);
      return Answer.fromJson(responseData);
    } else {
      final errorData = json.decode(response.body);
      throw Exception(errorData['error'] ?? 'Failed to vote for answer');
    }
  }

  // Supprimer une réponse
  Future<void> deleteAnswer(String answerId) async {
    final token = await authService.getToken();
    if (token == null) {
      throw Exception('User not authenticated');
    }
    
    final response = await http.delete(
      Uri.parse('$baseUrl/answers/$answerId'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode != 200) {
      final errorData = json.decode(response.body);
      throw Exception(errorData['error'] ?? 'Failed to delete answer');
    }
  }
}
EOF

# Création du service de catégories
cat > mobile/lib/services/category_service.dart << 'EOF'
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../models/category.dart';
import 'auth_service.dart';

class CategoryService {
  final String baseUrl = '${ApiConfig.contentServiceUrl}/categories';
  final AuthService authService = AuthService();

  // Récupérer toutes les catégories
  Future<List<Category>> getAllCategories() async {
    final response = await http.get(Uri.parse(baseUrl));

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => Category.fromJson(json)).toList();
    } else {
      final errorData = json.decode(response.body);
      throw Exception(errorData['error'] ?? 'Failed to fetch categories');
    }
  }

  // Récupérer une catégorie par ID
  Future<Category> getCategoryById(String categoryId) async {
    final response = await http.get(Uri.parse('$baseUrl/$categoryId'));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return Category.fromJson(data);
    } else {
      final errorData = json.decode(response.body);
      throw Exception(errorData['error'] ?? 'Failed to fetch category');
    }
  }

  // Créer une catégorie (admin uniquement)
  Future<Category> createCategory(String name, String description) async {
    final token = await authService.getToken();
    if (token == null) {
      throw Exception('User not authenticated');
    }
    
    final response = await http.post(
      Uri.parse(baseUrl),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: json.encode({
        'name': name,
        'description': description,
      }),
    );

    if (response.statusCode == 201) {
      final data = json.decode(response.body);
      return Category.fromJson(data);
    } else {
      final errorData = json.decode(response.body);
      throw Exception(errorData['error'] ?? 'Failed to create category');
    }
  }
}
EOF

# Création du Provider pour l'authentification
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
    _loadCurrentUser();
  }

  Future<void> _loadCurrentUser() async {
    _isLoading = true;
    notifyListeners();

    try {
      final user = await _authService.getCurrentUser();
      _currentUser = user;
      _error = null;
    } catch (e) {
      _error = e.toString();
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
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
EOF

# Création du Provider pour les catégories
cat > mobile/lib/providers/category_provider.dart << 'EOF'
import 'package:flutter/foundation.dart';
import '../models/category.dart';
import '../services/category_service.dart';

class CategoryProvider with ChangeNotifier {
  List<Category> _categories = [];
  bool _isLoading = false;
  String? _error;
  final CategoryService _categoryService = CategoryService();

  List<Category> get categories => _categories;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchCategories() async {
    if (_categories.isNotEmpty) return;

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

  Future<Category?> getCategoryById(String categoryId) async {
    try {
      // Vérifier si la catégorie est déjà chargée
      final existingCategory = _categories.firstWhere(
        (c) => c.id == categoryId,
        orElse: () => Category(
          id: '',
          name: '',
          description: '',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      );

      if (existingCategory.id.isNotEmpty) {
        return existingCategory;
      }

      // Sinon, la charger depuis l'API
      return await _categoryService.getCategoryById(categoryId);
    } catch (e) {
      _error = e.toString();
      return null;
    }
  }

  Future<bool> createCategory(String name, String description) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final category = await _categoryService.createCategory(name, description);
      _categories.add(category);
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
EOF

# Création du Provider pour les questions
cat > mobile/lib/providers/question_provider.dart << 'EOF'
import 'package:flutter/foundation.dart';
import '../models/question.dart';
import '../services/question_service.dart';

class QuestionProvider with ChangeNotifier {
  Map<String, List<Question>> _questionsByCategory = {};
  Map<String, bool> _hasMoreByCategory = {};
  bool _isLoading = false;
  String? _error;
  final QuestionService _questionService = QuestionService();

  bool get isLoading => _isLoading;
  String? get error => _error;

  List<Question> getQuestionsByCategory(String categoryId) {
    return _questionsByCategory[categoryId] ?? [];
  }

  bool hasMoreQuestions(String categoryId) {
    return _hasMoreByCategory[categoryId] ?? false;
  }

  Future<Map<String, dynamic>> fetchQuestionsByCategory(String categoryId, {int page = 1, bool refresh = false}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final result = await _questionService.getQuestionsByCategory(
        categoryId,
        page: page,
        limit: 10,
      );

      final List<Question> questions = result['questions'];
      final bool hasMore = result['pagination']['hasMore'] ?? false;

      if (refresh) {
        _questionsByCategory[categoryId] = questions;
      } else {
        _questionsByCategory[categoryId] = [
          ...(_questionsByCategory[categoryId] ?? []),
          ...questions,
        ];
      }

      _hasMoreByCategory[categoryId] = hasMore;

      return {
        'questions': questions,
        'hasMore': hasMore,
      };
    } catch (e) {
      _error = e.toString();
      return {
        'questions': <Question>[],
        'hasMore': false,
      };
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<Question?> createQuestion(String title, String content, String categoryId, List<String> tags) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final question = await _questionService.createQuestion(
        title,
        content,
        categoryId,
        tags,
      );

      // Ajouter la nouvelle question à la liste de cette catégorie
      if (_questionsByCategory.containsKey(categoryId)) {
        _questionsByCategory[categoryId]!.insert(0, question);
      } else {
        _questionsByCategory[categoryId] = [question];
      }

      return question;
    } catch (e) {
      _error = e.toString();
      return null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<Map<String, dynamic>?> getQuestionDetails(String questionId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final result = await _questionService.getQuestionById(questionId);
      return result;
    } catch (e) {
      _error = e.toString();
      return null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
EOF

# Création de l'écran de connexion
cat > mobile/lib/screens/auth/login_screen.dart << 'EOF'
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
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

  void _login() async {
    if (_formKey.currentState!.validate()) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      
      final success = await authProvider.login(
        _usernameController.text,
        _passwordController.text,
      );
      
      if (success && mounted) {
        Navigator.pushReplacementNamed(context, '/home');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    
    return Scaffold(
      appBar: AppBar(
        title: Text('Connexion'),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(height: 40),
              Center(
                child: Text(
                  'QuizAcademy',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
              ),
              SizedBox(height: 40),
              if (authProvider.error != null)
                Padding(
                  padding: EdgeInsets.only(bottom: 16.0),
                  child: Text(
                    authProvider.error!,
                    style: TextStyle(color: Colors.red),
                  ),
                ),
              TextFormField(
                controller: _usernameController,
                decoration: InputDecoration(
                  labelText: 'Nom d\'utilisateur',
                  prefixIcon: Icon(Icons.person),
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez entrer votre nom d\'utilisateur';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _passwordController,
                obscureText: !_isPasswordVisible,
                decoration: InputDecoration(
                  labelText: 'Mot de passe',
                  prefixIcon: Icon(Icons.lock),
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
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez entrer votre mot de passe';
                  }
                  return null;
                },
              ),
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
                  Text('Se souvenir de moi'),
                  Spacer(),
                  TextButton(
                    onPressed: () {
                      // Mot de passe oublié
                    },
                    child: Text('Mot de passe oublié ?'),
                  ),
                ],
              ),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: authProvider.isLoading ? null : _login,
                child: authProvider.isLoading
                    ? CircularProgressIndicator(color: Colors.white)
                    : Text('Se connecter'),
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 16.0),
                ),
              ),
              SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Vous n\'avez pas de compte ?'),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => RegisterScreen()),
                      );
                    },
                    child: Text('S\'inscrire'),
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

# Création de l'écran d'inscription avec TODO-FL5
cat > mobile/lib/screens/auth/register_screen.dart << 'EOF'
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import 'login_screen.dart';

class RegisterScreen extends StatefulWidget {
  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  // TODO-FL5: Implementer la methode d'inscription
  // Cette methode doit :
  // - Valider le formulaire (_formKey.currentState!.validate())
  // - Verifier que les mots de passe correspondent
  // - Appeler authProvider.register avec les donnees du formulaire
  // - Gerer l'etat de chargement et les erreurs
  // - Naviguer vers l'ecran principal apres inscription reussie
  void _register() async {
    // A implementer
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Inscription'),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (_errorMessage != null)
                Padding(
                  padding: EdgeInsets.only(bottom: 16.0),
                  child: Text(_errorMessage!,
                    style: TextStyle(color: Colors.red),
                  ),
                ),
              TextFormField(
                controller: _usernameController,
                decoration: InputDecoration(
                  labelText: 'Nom d\'utilisateur',
                  prefixIcon: Icon(Icons.person),
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez entrer un nom d\'utilisateur';
                  }
                  if (value.length < 3) {
                    return 'Le nom d\'utilisateur doit contenir au moins 3 caractères';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _emailController,
                decoration: InputDecoration(
                  labelText: 'Email',
                  prefixIcon: Icon(Icons.email),
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez entrer un email';
                  }
                  if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                    return 'Veuillez entrer un email valide';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'Mot de passe',
                  prefixIcon: Icon(Icons.lock),
                  border: OutlineInputBorder(),
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
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _confirmPasswordController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'Confirmer le mot de passe',
                  prefixIcon: Icon(Icons.lock_outline),
                  border: OutlineInputBorder(),
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
              ),
              SizedBox(height: 24),
              ElevatedButton(
                onPressed: _isLoading ? null : _register,
                child: _isLoading
                    ? CircularProgressIndicator(color: Colors.white)
                    : Text('S\'inscrire'),
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 16.0),
                ),
              ),
              SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Vous avez déjà un compte ?'),
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: Text('Se connecter'),
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

# Création de l'écran de liste des questions avec TODO-FL6 et TODO-FL7
cat > mobile/lib/screens/questions/question_list_screen.dart << 'EOF'
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/category.dart';
import '../../models/question.dart';
import '../../providers/category_provider.dart';
import '../../providers/question_provider.dart';
import '../../widgets/question_card.dart';
import 'question_detail_screen.dart';
import 'create_question_screen.dart';

class QuestionListScreen extends StatefulWidget {
  @override
  _QuestionListScreenState createState() => _QuestionListScreenState();
}

class _QuestionListScreenState extends State<QuestionListScreen> {
  Category? _selectedCategory;
  bool _isLoading = false;
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

  // TODO-FL6: Implementer la methode pour charger les questions
  // Cette methode doit :
  // - Verifier qu'une categorie est selectionnee
  // - Appeler questionProvider.fetchQuestionsByCategory
  // - Gerer l'etat de chargement et les erreurs
  // - Mettre a jour _hasMore selon la reponse
  Future<void> _loadQuestions({bool refresh = false}) async {
    // A implementer
  }

  @override
  Widget build(BuildContext context) {
    final categoryProvider = Provider.of<CategoryProvider>(context);
    final questionProvider = Provider.of<QuestionProvider>(context);
    
    return Scaffold(
      appBar: AppBar(
        title: Text('Questions'),
        actions: [
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () => Navigator.pushNamed(context, '/search'),
          ),
        ],
      ),
      body: _isLoading && _selectedCategory == null
          ? Center(child: CircularProgressIndicator())
          : Column(
              children: [
                _buildCategorySelector(categoryProvider),
                Expanded(
                  child: _selectedCategory == null
                      ? Center(child: Text('Sélectionnez une catégorie'))
                      : _buildQuestionList(questionProvider),
                ),
              ],
            ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () {
          if (_selectedCategory != null) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => CreateQuestionScreen(
                  categoryId: _selectedCategory!.id,
                ),
              ),
            ).then((_) => _loadQuestions(refresh: true));
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Sélectionnez d\'abord une catégorie')),
            );
          }
        },
      ),
    );
  }

  // TODO-FL7: Implementer le widget de selection de categorie
  // Ce widget doit :
  // - Afficher un DropdownButton avec les categories disponibles
  // - Permettre de selectionner une categorie
  // - Appeler _loadQuestions quand la categorie change
  Widget _buildCategorySelector(CategoryProvider categoryProvider) {
    // A implementer
    return Container();
  }

  Widget _buildQuestionList(QuestionProvider questionProvider) {
    if (_selectedCategory == null) {
      return Center(child: Text('Sélectionnez une catégorie'));
    }

    final questions = questionProvider.getQuestionsByCategory(_selectedCategory!.id);
    
    if (questions.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Aucune question dans cette catégorie.'),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => _loadQuestions(refresh: true),
              child: Text('Rafraîchir'),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => _loadQuestions(refresh: true),
      child: ListView.builder(
        itemCount: questions.length + (_hasMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == questions.length) {
            return _buildLoadMoreButton();
          }
          
          final question = questions[index];
          return QuestionCard(
            question: question,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => QuestionDetailScreen(
                    questionId: question.id,
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildLoadMoreButton() {
    return _isLoading
        ? Center(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: CircularProgressIndicator(),
            ),
          )
        : Container(
            padding: EdgeInsets.all(16.0),
            alignment: Alignment.center,
            child: ElevatedButton(
              onPressed: () => _loadQuestions(refresh: false),
              child: Text('Charger plus'),
            ),
          );
  }
}
EOF

# Création du fichier main.dart
cat > mobile/lib/main.dart << 'EOF'
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/auth_provider.dart';
import 'providers/category_provider.dart';
import 'providers/question_provider.dart';
import 'screens/auth/login_screen.dart';
import 'screens/questions/question_list_screen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (ctx) => AuthProvider()),
        ChangeNotifierProvider(create: (ctx) => CategoryProvider()),
        ChangeNotifierProvider(create: (ctx) => QuestionProvider()),
      ],
      child: Consumer<AuthProvider>(
        builder: (ctx, auth, _) => MaterialApp(
          title: 'QuizAcademy',
          theme: ThemeData(
            primarySwatch: Colors.blue,
            visualDensity: VisualDensity.adaptivePlatformDensity,
          ),
          home: auth.isLoading
              ? SplashScreen()
              : auth.isLoggedIn
                  ? QuestionListScreen()
                  : LoginScreen(),
          routes: {
            '/home': (ctx) => QuestionListScreen(),
            '/login': (ctx) => LoginScreen(),
          },
        ),
      ),
    );
  }
}

class SplashScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'QuizAcademy',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).primaryColor,
              ),
            ),
            SizedBox(height: 24),
            CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }
}
EOF

# Création du widget QuestionCard
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
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                question.title,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 8),
              Text(
                question.content.length > 100
                    ? '${question.content.substring(0, 100)}...'
                    : question.content,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.black87,
                ),
              ),
              SizedBox(height: 16),
              Row(
                children: [
                  Icon(Icons.person, size: 16, color: Colors.grey),
                  SizedBox(width: 4),
                  Text(
                    question.authorName,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                  ),
                  Spacer(),
                  Icon(Icons.visibility, size: 16, color: Colors.grey),
                  SizedBox(width: 4),
                  Text(
                    '${question.viewCount}',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                  ),
                  SizedBox(width: 8),
                  Icon(Icons.access_time, size: 16, color: Colors.grey),
                  SizedBox(width: 4),
                  Text(
                    DateFormat('dd/MM/yyyy').format(question.createdAt),
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: question.tags.map((tag) => Chip(
                  label: Text(
                    tag,
                    style: TextStyle(fontSize: 10),
                  ),
                  backgroundColor: Colors.blue.shade100,
                  padding: EdgeInsets.all(0),
                  labelPadding: EdgeInsets.symmetric(horizontal: 8),
                )).toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
EOF

echo "=== Application mobile Flutter configurée avec succès ==="

# Création du fichier docker-compose.yml pour orchestrer les services
cat > backend/docker-compose.yml << 'EOF'
version: '3'

services:
  user-service:
    build: ./user-service
    ports:
      - "8080:8080"
    environment:
      - SPRING_DATASOURCE_URL=jdbc:h2:mem:userdb
      - SPRING_DATASOURCE_USERNAME=sa
      - SPRING_DATASOURCE_PASSWORD=password
      - JWT_SECRET=your_jwt_secret_key_here
    networks:
      - quizacademy-network
    restart: always

  content-service:
    build: ./content-service
    ports:
      - "3000:3000"
    environment:
      - NODE_ENV=production
      - MONGODB_URI=mongodb://mongodb:27017/quizacademy
      - USER_SERVICE_URL=http://user-service:8080
      - JWT_SECRET=your_jwt_secret_key_here
    depends_on:
      - user-service
      - mongodb
    networks:
      - quizacademy-network
    restart: always

  mongodb:
    image: mongo:latest
    ports:
      - "27017:27017"
    volumes:
      - mongodb_data:/data/db
    networks:
      - quizacademy-network

networks:
  quizacademy-network:
    driver: bridge

volumes:
  mongodb_data:
EOF

# QuizAcademy 🎓

> **Plateforme de partage de connaissances académiques avec architecture microservices**

QuizAcademy est une application mobile de type questions/réponses développée pour l'apprentissage des architectures modernes. Ce projet intègre Flutter pour le frontend mobile, Java/Spring Boot et Node.js/Express pour les services backend, le tout orchestré avec Docker.

## 🏗️ Architecture

### 📊 Vue d'ensemble

```
┌─────────────────┐    ┌──────────────────┐    ┌─────────────────┐
│   Flutter App   │───▶│   User Service   │    │ Content Service │
│     (Mobile)    │    │ (Java/Spring)    │    │  (Node.js/JS)   │
└─────────────────┘    └──────────────────┘    └─────────────────┘
                              │                        │
                              ▼                        ▼
                       ┌─────────────┐          ┌─────────────┐
                       │  H2 Database │          │  MongoDB    │
                       │  (In-Memory) │          │ (Persistent) │
                       └─────────────┘          └─────────────┘
```

### 🧩 Composants

| Service             | Technologie      | Port  | Responsabilités                        |
| ------------------- | ---------------- | ----- | -------------------------------------- |
| **User Service**    | Java/Spring Boot | 8080  | Authentification, gestion utilisateurs |
| **Content Service** | Node.js/Express  | 3000  | Questions, réponses, votes             |
| **Mobile App**      | Flutter/Dart     | -     | Interface utilisateur mobile           |
| **Database**        | H2 + MongoDB     | 27017 | Persistence des données                |

## 🚀 Installation et Configuration

### 📋 Prérequis

- ✅ **Docker & Docker Compose** (v20.0+)
- ✅ **Flutter SDK** (v3.0+)
- ✅ **Git** pour le clonage
- ✅ **JDK 17+** (pour développement local Java)
- ✅ **Node.js 18+** (pour développement local Node.js)
- ✅ **Un émulateur Android/iOS** ou appareil physique

> **💡 Tip** : Vérifiez vos installations avec `docker --version`, `flutter doctor`, et `git --version`

### 📥 Installation Complète

```bash
# 1️⃣ Cloner le projet starter
git clone https://github.com/elbachir67/quizacademy-starter.git
cd quizacademy-starter

# 2️⃣ Rendre le script exécutable et lancer l'installation
chmod +x create_project.sh
./create_project.sh

# ⏳ Le script va automatiquement :
# - Créer toute la structure du projet
# - Configurer les services backend (Java + Node.js)
# - Configurer l'application mobile Flutter
# - Créer la documentation et les scripts de test
# - Préparer l'environnement Docker

# 3️⃣ Démarrer les services backend
cd backend
docker-compose up --build -d

# 4️⃣ Vérifier que tout fonctionne
docker-compose ps
# Tous les services doivent être "Up"

# 5️⃣ Tester automatiquement les services
cd ../scripts
chmod +x test_services.sh
./test_services.sh

# 6️⃣ Configurer l'app mobile
cd ../mobile
flutter pub get

# 7️⃣ Lancer l'application
flutter run
```

### ⚡ Installation Express

```bash
git clone https://github.com/elbachir67/quizacademy-starter.git && cd quizacademy-starter && chmod +x create_project.sh && ./create_project.sh
```

### 📁 Structure Créée par le Script

Après exécution du script `create_project.sh`, voici la structure générée :

```
quizacademy-starter/
├── 🔧 backend/
│   ├── 📁 user-service/          # Service Java/Spring Boot
│   │   ├── src/main/java/        # Code source Java
│   │   ├── Dockerfile             # Image Docker
│   │   └── build.gradle           # Configuration Gradle
│   ├── 📁 content-service/        # Service Node.js/Express
│   │   ├── src/                   # Code source JavaScript
│   │   ├── Dockerfile             # Image Docker
│   │   └── package.json           # Dépendances npm
│   └── docker-compose.yml         # Orchestration services
├── 📱 mobile/                     # Application Flutter
│   ├── lib/                       # Code source Dart
│   ├── assets/                    # Ressources (images, etc.)
│   └── pubspec.yaml               # Dépendances Flutter
├── 📚 docs/                       # Documentation technique
├── 🔧 scripts/                    # Scripts utilitaires
├── 📄 create_project.sh          # Script d'installation
└── 📄 README.md                   # Ce fichier
```

## 📱 Utilisation

### 🌐 URLs des Services

Après installation et démarrage des services :

| Service         | URL                              | Description      |
| --------------- | -------------------------------- | ---------------- |
| User Service    | http://localhost:8080            | API utilisateurs |
| Content Service | http://localhost:3000            | API contenu      |
| MongoDB         | http://localhost:27017           | Base de données  |
| H2 Console      | http://localhost:8080/h2-console | Interface H2     |

### 🔑 Endpoints Principaux

#### 👥 Service Utilisateurs (Port 8080)

```http
POST /api/auth/register    # Inscription
POST /api/auth/login       # Connexion
GET  /api/auth/health      # Santé du service
```

#### 📝 Service Content (Port 3000)

```http
GET  /api/categories              # Lister les catégories
POST /api/questions               # Créer une question
GET  /api/categories/{id}/questions # Questions par catégorie
POST /api/questions/{id}/answers  # Créer une réponse
POST /api/answers/{id}/vote       # Voter pour une réponse
GET  /api/questions/search        # Rechercher des questions
```

### 📱 Application Mobile

1. **Configuration** : Les URLs sont préconfigurées dans `mobile/lib/config/api_config.dart`
2. **Émulateur Android** : URLs par défaut (`10.0.2.2`)
3. **Appareil physique** : Modifier les URLs avec l'IP de votre machine
4. **Lancement** : `flutter run` dans le dossier `mobile/`

## 🧪 Tests

### 🔍 Tests Automatiques

Après installation complète du projet :

```bash
# Test complet des services (script généré automatiquement)
./scripts/test_services.sh

# Résultats attendus :
# ✅ Health Checks
# ✅ Inscription utilisateur
# ✅ Connexion utilisateur
# ✅ Récupération des catégories
# ✅ Création d'une question
# ✅ Création d'une réponse
# ✅ Système de votes
# ✅ Recherche de questions
```

### 🧰 Tests Manuels avec Postman

<details>
<summary>📋 Collection Postman (cliquez pour développer)</summary>

#### 1. Inscription d'un utilisateur

```json
POST http://localhost:8080/api/auth/register
Content-Type: application/json

{
  "username": "testuser",
  "email": "test@example.com",
  "password": "password123"
}
```

#### 2. Connexion

```json
POST http://localhost:8080/api/auth/login
Content-Type: application/json

{
  "username": "testuser",
  "password": "password123"
}
```

#### 3. Créer une question

```json
POST http://localhost:3000/api/questions
Authorization: Bearer {{token}}
Content-Type: application/json

{
  "title": "Comment fonctionne Docker ?",
  "content": "Je débute avec Docker et j'aimerais comprendre les concepts de base.",
  "categoryId": "{{categoryId}}",
  "tags": ["docker", "devops", "conteneurs"]
}
```

#### 4. Voter pour une réponse

```json
POST http://localhost:3000/api/answers/{{answerId}}/vote
Authorization: Bearer {{token}}
Content-Type: application/json

{
  "vote": 1
}
```

</details>

## 🛠️ Développement

### ⚙️ Commandes de Développement

Une fois le projet installé avec le script :

```bash
# 🐳 Backend (Docker)
cd backend
docker-compose up --build         # Build et démarrer
docker-compose down               # Arrêter
docker-compose logs -f service    # Logs d'un service
docker-compose restart service    # Redémarrer un service

# 📱 Mobile (Flutter)
cd mobile
flutter clean                     # Nettoyer le cache
flutter pub get                   # Installer dépendances
flutter run --debug              # Mode développement
flutter build apk                # Build Android
flutter build ios                # Build iOS

# 🧪 Tests
flutter test                      # Tests unitaires Flutter
./scripts/test_services.sh       # Tests services backend
```

### 🔧 Configuration Avancée

<details>
<summary>🎛️ Variables d'environnement (cliquez pour développer)</summary>

Le script d'installation configure automatiquement ces variables, mais vous pouvez les modifier :

#### Service Utilisateurs (backend/user-service/.env)

```bash
JWT_SECRET=your_super_secure_jwt_secret_key_here
SPRING_PROFILES_ACTIVE=dev
LOGGING_LEVEL_ROOT=INFO
```

#### Service Content (backend/content-service/.env)

```bash
NODE_ENV=development
MONGODB_URI=mongodb://mongodb:27017/quizacademy
USER_SERVICE_URL=http://user-service:8080
JWT_SECRET=your_super_secure_jwt_secret_key_here
```

#### Application Flutter (mobile/lib/config/api_config.dart)

```dart
class ApiConfig {
  // Émulateur Android
  static const String userServiceBaseUrl = 'http://10.0.2.2:8080/api';
  static const String contentServiceBaseUrl = 'http://10.0.2.2:3000/api';

  // Appareil physique (remplacez par votre IP)
  // static const String userServiceBaseUrl = 'http://192.168.1.100:8080/api';
}
```

</details>

## 🐛 Dépannage

### ❓ Problèmes Courants

<details>
<summary>🚨 Les services ne démarrent pas</summary>

**Symptômes** : Erreurs Docker, ports occupés
**Solutions** :

```bash
# Vérifier les ports utilisés
netstat -an | grep "8080\|3000\|27017"

# Libérer les ports si nécessaire
sudo lsof -ti:8080 | xargs kill -9
sudo lsof -ti:3000 | xargs kill -9

# Redémarrer Docker
sudo systemctl restart docker
```

</details>

<details>
<summary>📱 L'app mobile ne se connecte pas</summary>

**Symptômes** : Erreurs de connexion, timeouts
**Solutions** :

```bash
# Vérifier les URLs dans api_config.dart
# Pour émulateur Android : 10.0.2.2
# Pour iOS Simulator : localhost
# Pour appareil physique : IP de votre machine

# Tester la connectivité
curl http://localhost:8080/api/auth/health
curl http://localhost:3000/health
```

</details>

<details>
<summary>🗄️ Problèmes de base de données</summary>

**Symptômes** : Erreurs MongoDB, données vides
**Solutions** :

```bash
# Redémarrer MongoDB
docker-compose restart mongodb

# Vérifier les logs
docker-compose logs mongodb

# Réinitialiser les données
docker-compose down -v
docker-compose up -d
```

</details>

### 📊 Monitoring et Logs

```bash
# 🔍 Voir tous les logs
docker-compose logs -f

# 📋 Logs par service
docker-compose logs -f user-service
docker-compose logs -f content-service
docker-compose logs -f mongodb

# 💻 Accéder aux conteneurs
docker-compose exec user-service bash
docker-compose exec content-service sh
docker-compose exec mongodb mongosh

# 📈 État des services
docker-compose ps
docker stats
```

## ✨ Fonctionnalités

### ✅ Implémentées

- ✅ **Authentification complète** (inscription, connexion, JWT)
- ✅ **Gestion des utilisateurs** (profils, rôles)
- ✅ **Système de catégories** (mathématiques, informatique, physique, chimie)
- ✅ **Questions et réponses** (CRUD complet)
- ✅ **Système de votes** (upvote/downvote avec scores)
- ✅ **Recherche avancée** (full-text search)
- ✅ **Pagination** (optimisée pour mobile)
- ✅ **Interface mobile** (responsive, Material Design)
- ✅ **Déploiement Docker** (orchestration complète)
- ✅ **Tests automatiques** (validation end-to-end)

### 🔄 Roadmap

- 🔄 **Notifications push** (Firebase Cloud Messaging)
- 🔄 **Mode hors ligne** (synchronisation automatique)
- 🔄 **Gamification** (badges, points, classements)
- 🔄 **Modération** (signalement, validation)
- 🔄 **Analytics** (tableaux de bord, statistiques)
- 🔄 **API REST complète** (documentation OpenAPI/Swagger)

## 📈 Performance

### 🎯 Métriques Actuelles

| Métrique               | Valeur  | Description                   |
| ---------------------- | ------- | ----------------------------- |
| **Temps de démarrage** | < 30s   | Services backend complets     |
| **Réponse API**        | < 200ms | Endpoints principaux          |
| **Taille APK**         | ~15MB   | Application Flutter optimisée |
| **RAM utilisée**       | ~512MB  | Ensemble des services         |

### 🚀 Optimisations

- **Mise en cache** : Catégories, réponses fréquentes
- **Pagination** : Chargement progressif (10 items/page)
- **Compression** : Gzip activé sur les APIs
- **Index DB** : Recherche optimisée avec MongoDB
- **Lazy loading** : Images et contenu à la demande

## ⚠️ Important

Ce dépôt contient uniquement :

- 📄 **README.md** - Ce guide d'installation et d'utilisation
- 🔧 **create_project.sh** - Script d'installation automatique

Le script `create_project.sh` va **automatiquement créer** toute la structure du projet avec :

- ✅ Services backend complets (Java/Spring Boot + Node.js/Express)
- ✅ Application mobile Flutter fonctionnelle
- ✅ Configuration Docker avec orchestration
- ✅ Documentation technique détaillée
- ✅ Scripts de test et utilitaires
- ✅ Exemples et données de démonstration

**Première étape obligatoire** : Exécuter le script d'installation !

```bash
git clone https://github.com/elbachir67/quizacademy-starter.git
cd quizacademy-starter
chmod +x create_project.sh
./create_project.sh
```

## 🤝 Contribution

1. **Fork** le projet sur GitHub
2. **Clone** votre fork : `git clone https://github.com/votre-username/quizacademy-starter.git`
3. **Créer une branche** : `git checkout -b feature/ma-super-feature`
4. **Développer** en suivant les conventions du projet
5. **Tester** : `./scripts/test_services.sh` + `flutter test`
6. **Commit** : `git commit -m "feat: ajout de ma super feature"`
7. **Push** : `git push origin feature/ma-super-feature`
8. **Pull Request** avec description détaillée

### 📝 Conventions de Code

- **Java** : Google Java Style Guide
- **JavaScript** : ESLint + Prettier
- **Dart/Flutter** : Effective Dart Style Guide
- **Git** : Conventional Commits

### 🧪 Tests Requis

```bash
# Backend
./gradlew test                    # Tests Java
npm test                         # Tests JavaScript

# Frontend
flutter test                     # Tests Dart
flutter drive --target=test_driver/app.dart  # Tests E2E

# Intégration
./scripts/test_services.sh       # Tests API
```

## 📚 Documentation

### 📖 Guides Disponibles

Après installation du projet :

- 📄 **[Guide Technique](docs/TECHNICAL_GUIDE.md)** - Architecture détaillée
- 🎓 **[Guide Pédagogique](projet.pdf)** - Énoncé complet du projet
- 🚀 **[Guide Déploiement](docs/DEPLOYMENT.md)** - Production et scaling
- 🔧 **[Guide API](docs/API_REFERENCE.md)** - Documentation des endpoints

### 🎯 Ressources d'Apprentissage

- **Microservices** : [Martin Fowler's Microservices](https://martinfowler.com/articles/microservices.html)
- **Spring Boot** : [Documentation officielle](https://spring.io/projects/spring-boot)
- **Flutter** : [Documentation Flutter](https://docs.flutter.dev/)
- **Docker** : [Docker Compose Guide](https://docs.docker.com/compose/)

## 📄 Licence

Ce projet est sous licence **MIT**. Voir le fichier [LICENSE](LICENSE) pour plus de détails.

```
MIT License

Copyright (c) 2025 QuizAcademy Team

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.
```

## 👥 Équipe

### 🎓 Encadrement Académique

- **Dr. El Hadji Bassirou TOURE** - _Encadrant du projet_
  - 📧 Email : [elbachir67@ucad.edu.sn](mailto:elbachir67@ucad.edu.sn)
  - 🏛️ Département de Mathématiques et Informatique
  - 🎓 Faculté des Sciences et Techniques - UCAD

### 👨‍💻 Développement

- **Étudiants M2 Informatique** - _Développement et implémentation_
- **Communauté Open Source** - _Contributions et améliorations_

## 📞 Support

### 🆘 Besoin d'aide ?

1. **📖 Documentation** : Consultez d'abord le dossier `docs/`
2. **🐛 Bug Reports** : [Créer une issue GitHub](https://github.com/elbachir67/quizacademy-starter/issues)
3. **💬 Discussions** : [GitHub Discussions](https://github.com/elbachir67/quizacademy-starter/discussions)
4. **📧 Contact direct** : Pour questions académiques

### 🏷️ Template d'Issue

```markdown
**Type** : Bug | Feature | Question

**Description**
Description claire du problème ou de la demande

**Étapes pour reproduire** (pour bugs)

1. Aller à '...'
2. Cliquer sur '....'
3. Voir l'erreur

**Environnement**

- OS: [ex: Windows 10, macOS Big Sur, Ubuntu 20.04]
- Docker version: [ex: 20.10.8]
- Flutter version: [ex: 3.0.5]

**Captures d'écran**
Si applicable, ajouter des captures d'écran
```

---

<div align="center">

**QuizAcademy** - _Partager les connaissances, apprendre ensemble_ ! 🎓

[![GitHub stars](https://img.shields.io/github/stars/elbachir67/quizacademy-starter.svg?style=social&label=Star)](https://github.com/elbachir67/quizacademy-starter)
[![GitHub forks](https://img.shields.io/github/forks/elbachir67/quizacademy-starter.svg?style=social&label=Fork)](https://github.com/elbachir67/quizacademy-starter/fork)
[![GitHub issues](https://img.shields.io/github/issues/elbachir67/quizacademy-starter.svg)](https://github.com/elbachir67/quizacademy-starter/issues)

_Fait avec ❤️ pour l'éducation et l'apprentissage des technologies modernes_

</div>

# QuizAcademy - Projet Intégré Flutter & Microservices

## 📋 Description du projet

QuizAcademy est une plateforme de partage de connaissances académiques inspirée par Quora. Elle permet aux étudiants et enseignants de poser des questions, partager leur expertise et répondre aux interrogations dans un format adapté au contexte universitaire.

Le projet est composé de trois composants principaux :

- **Frontend mobile** développé avec Flutter
- **Service Utilisateurs** développé avec Java/Spring Boot (Gradle)
- **Service Content** développé avec Node.js/Express

## 🏗️ Architecture

```
quizacademy/
├── backend/
│   ├── user-service/       # Service Utilisateurs (Java/Spring Boot/Gradle)
│   │   ├── src/            # Code source Java
│   │   ├── build.gradle    # Configuration Gradle
│   │   ├── settings.gradle # Configuration du projet Gradle
│   │   └── Dockerfile      # Configuration Docker
│   │
│   ├── content-service/    # Service Content (Node.js/Express)
│   │   ├── src/            # Code source JavaScript
│   │   ├── package.json    # Configuration des dépendances
│   │   └── Dockerfile      # Configuration Docker
│   │
│   └── docker-compose.yml  # Orchestration des services backend
│
└── mobile/                 # Application Flutter
    ├── lib/                # Code source Dart
    │   ├── models/         # Modèles de données
    │   ├── services/       # Services API
    │   ├── providers/      # Gestion d'état avec Provider
    │   ├── screens/        # Écrans de l'application
    │   └── widgets/        # Widgets réutilisables
    │
    ├── pubspec.yaml        # Configuration des dépendances Flutter
    └── assets/             # Ressources (images, fonts, etc.)
```

## 🛠️ Prérequis techniques

Pour développer et exécuter ce projet, vous aurez besoin d'installer :

- **Docker** et **Docker Compose** (pour l'orchestration des services)
- **JDK 17+** (pour le développement Java)
- **Gradle 7.6.1+** (pour la compilation du service Java)
- **Node.js 18+** (pour le développement du service Content)
- **Flutter SDK** (pour le développement mobile)
- **Git** (pour la gestion de version)
- **IDE recommandés** :
  - Android Studio ou VS Code pour Flutter
  - IntelliJ IDEA ou Eclipse pour Java
  - VS Code pour Node.js

## 📥 Installation et configuration

### 1. Cloner le dépôt et créer la structure du projet

```bash
# Cloner ce dépôt (ou télécharger le script d'initialisation)
git clone https://github.com/votre-nom/quizacademy-init.git
cd quizacademy-init

# Rendre le script exécutable et le lancer
chmod +x create_project.sh
./create_project.sh

# Naviguer vers le projet créé
cd quizacademy
```

### 2. Configuration du service Utilisateurs (Java/Spring Boot)

Le service est déjà configuré avec :

- Gradle comme système de build
- Spring Boot 2.7.0
- Spring Security avec JWT pour l'authentification
- Base de données H2 en mémoire (pour simplifier le développement)

Pour démarrer le service manuellement :

```bash
cd backend/user-service
./gradlew bootRun
```

### 3. Configuration du service Content (Node.js/Express)

Le service est configuré avec :

- Express.js comme framework web
- Mongoose pour l'interaction avec MongoDB
- JWT pour vérifier les tokens d'authentification

Pour démarrer le service manuellement :

```bash
cd backend/content-service
npm install
npm start
```

### 4. Configuration de l'application mobile Flutter

L'application est configurée avec :

- Provider pour la gestion d'état
- HTTP pour les appels API
- Shared Preferences pour le stockage local

Pour démarrer l'application manuellement :

```bash
cd mobile
flutter pub get
flutter run
```

## 🚀 Démarrage rapide avec Docker

Pour démarrer rapidement l'ensemble des services backend :

```bash
cd backend
docker-compose up -d
```

Vérifiez que les services sont bien démarrés :

```bash
docker-compose ps
```

Les API sont alors disponibles aux adresses :

- Service Utilisateurs : http://localhost:8080/api
- Service Content : http://localhost:3000/api

## 📝 Tâches à réaliser (TODOs)

Le projet contient plusieurs TODOs que vous devez compléter pour implémenter les différentes fonctionnalités.

### Backend : Service Utilisateurs (Java/Spring Boot)

#### TODO-USER1 : Compléter le modèle User

Dans le fichier `backend/user-service/src/main/java/com/quizacademy/userservice/model/User.java` :

- Ajouter les getters et setters pour tous les attributs
- Créer un constructeur par défaut qui initialise `createdAt` à la date et heure actuelles
- Créer un constructeur avec paramètres (username, email, password) qui initialise également `createdAt`

#### TODO-USER2 : Implémenter la méthode d'inscription

Dans le fichier `backend/user-service/src/main/java/com/quizacademy/userservice/service/AuthService.java` :

- Implémenter la méthode `register`
- Vérifier que l'utilisateur n'existe pas déjà
- Encoder le mot de passe avec passwordEncoder
- Assigner le rôle "ROLE_USER" par défaut
- Sauvegarder l'utilisateur et retourner l'objet créé

#### TODO-USER3 : Implémenter la méthode d'authentification

Dans le même fichier :

- Implémenter la méthode `login`
- Authentifier l'utilisateur avec authenticationManager
- Générer un token JWT avec jwtTokenProvider
- Retourner une Map contenant le token et les infos utilisateur

#### TODO-USER4 : Implémenter l'endpoint d'inscription

Dans le fichier `backend/user-service/src/main/java/com/quizacademy/userservice/controller/AuthController.java` :

- Implémenter la méthode `registerUser`
- Appeler authService.register avec l'utilisateur reçu
- Retourner un code 201 CREATED avec l'utilisateur créé (sans le mot de passe)
- Gérer les erreurs possibles (ex: email déjà utilisé)

#### TODO-USER5 : Implémenter l'endpoint de connexion

Dans le même fichier :

- Implémenter la méthode `login`
- Appeler authService.login avec username et password
- Retourner le token et les infos utilisateur avec un code 200 OK
- Gérer les erreurs d'authentification

### Backend : Service Content (Node.js/Express)

#### TODO-CONTENT1 : Définir le schéma de Question

Dans le fichier `backend/content-service/src/models/question.model.js` :

- Définir le schéma Mongoose avec les champs requis
- Ajouter les validations nécessaires

#### TODO-CONTENT2 : Définir le schéma de Answer

Dans le fichier `backend/content-service/src/models/answer.model.js` :

- Définir le schéma Mongoose avec les champs requis
- Ajouter les validations nécessaires

#### TODO-CONTENT3 : Implémenter la fonction de création de question

Dans le fichier `backend/content-service/src/controllers/question.controller.js` :

- Extraire les données de la requête
- Vérifier l'authentification avec userService.verifyToken
- Créer la question en base de données
- Retourner la question créée avec un statut 201

#### TODO-CONTENT4 : Implémenter la récupération des questions par catégorie

Dans le même fichier :

- Extraire l'ID de catégorie des paramètres de route
- Récupérer les questions filtrées par catégorie
- Gérer la pagination
- Retourner les questions avec les métadonnées de pagination

#### TODO-CONTENT5 : Implémenter la création de réponse

Dans le fichier `backend/content-service/src/controllers/answer.controller.js` :

- Extraire les données de la requête et l'ID de question des paramètres
- Vérifier l'authentification avec userService.verifyToken
- Vérifier que la question existe
- Créer la réponse en base de données
- Retourner la réponse créée avec un statut 201

#### TODO-CONTENT6 : Implémenter le système de vote

Dans le même fichier :

- Extraire l'ID de réponse des paramètres et le vote du corps
- Vérifier l'authentification
- Mettre à jour le tableau de votes et recalculer le score
- Retourner la réponse mise à jour

### Frontend : Application mobile Flutter

#### TODO-FL1 : Implémenter la méthode d'inscription

Dans le fichier `mobile/lib/services/auth_service.dart` :

- Implémenter la méthode `register`
- Faire une requête POST à /auth/register avec les données utilisateur
- Gérer les réponses de succès et d'erreur
- Retourner l'utilisateur créé en cas de succès

#### TODO-FL2 : Implémenter la méthode de connexion

Dans le même fichier :

- Implémenter la méthode `login`
- Faire une requête POST à /auth/login avec username et password
- Sauvegarder le token JWT reçu dans les SharedPreferences
- Retourner l'utilisateur connecté

#### TODO-FL3 : Implémenter la récupération des questions par catégorie

Dans le fichier `mobile/lib/services/question_service.dart` :

- Implémenter la méthode `getQuestionsByCategory`
- Faire une requête GET à /categories/{categoryId}/questions
- Gérer la pagination
- Parser la réponse en liste de Question

#### TODO-FL4 : Implémenter la création de question

Dans le même fichier :

- Implémenter la méthode `createQuestion`
- Récupérer le token JWT avec authService.getToken()
- Faire une requête POST à /questions avec les données et le token
- Retourner la question créée

#### TODO-FL5 : Implémenter la méthode d'inscription dans l'écran

Dans le fichier `mobile/lib/screens/auth/register_screen.dart` :

- Implémenter la méthode `_register`
- Valider le formulaire
- Vérifier que les mots de passe correspondent
- Appeler authProvider.register avec les données du formulaire
- Gérer l'état de chargement et les erreurs
- Naviguer vers l'écran principal après inscription réussie

#### TODO-FL6 : Implémenter le chargement des questions

Dans le fichier `mobile/lib/screens/questions/question_list_screen.dart` :

- Implémenter la méthode `_loadQuestions`
- Vérifier qu'une catégorie est sélectionnée
- Appeler questionProvider.fetchQuestionsByCategory
- Gérer l'état de chargement et les erreurs
- Mettre à jour \_hasMore selon la réponse

#### TODO-FL7 : Implémenter le sélecteur de catégorie

Dans le même fichier :

- Implémenter la méthode `_buildCategorySelector`
- Afficher un DropdownButton avec les catégories disponibles
- Permettre de sélectionner une catégorie
- Appeler \_loadQuestions quand la catégorie change

## 🧪 Test des services

### Test du service Utilisateurs

Une fois les TODOs complétés, testez le service avec Postman :

1. **Démarrer le service** avec Docker : `docker-compose up -d user-service`
2. **Créer un utilisateur** avec une requête POST à `http://localhost:8080/api/auth/register`
   ```json
   {
     "username": "user1",
     "email": "user1@example.com",
     "password": "password123"
   }
   ```
3. **Se connecter** avec une requête POST à `http://localhost:8080/api/auth/login`
   ```json
   {
     "username": "user1",
     "password": "password123"
   }
   ```
4. **Vérifier** que vous recevez un token JWT et les infos utilisateur

### Test du service Content

Testez le service Content après implémentation :

1. **Démarrer les services** avec Docker : `docker-compose up -d`
2. **Créer une catégorie** avec une requête POST à `http://localhost:3000/api/categories`
   ```json
   {
     "name": "Mathématiques",
     "description": "Questions sur les mathématiques"
   }
   ```
3. **Créer une question** avec une requête POST à `http://localhost:3000/api/questions`
   ```json
   {
     "title": "Comment résoudre une équation du second degré ?",
     "content": "Je n'arrive pas à appliquer la formule pour résoudre ax^2 + bx + c = 0. Pouvez-vous expliquer la démarche ?",
     "categoryId": "[ID_DE_LA_CATEGORIE]",
     "tags": ["équations", "algèbre"]
   }
   ```
4. **Récupérer les questions** avec une requête GET à `http://localhost:3000/api/categories/[ID_DE_LA_CATEGORIE]/questions`
5. **Ajouter une réponse** avec une requête POST à `http://localhost:3000/api/questions/[ID_DE_LA_QUESTION]/answers`
6. **Voter pour une réponse** avec une requête POST à `http://localhost:3000/api/answers/[ID_DE_LA_REPONSE]/vote`

## 📦 Déploiement avec Docker

Pour déployer l'application complète via Docker :

```bash
# Naviguer à la racine du projet
cd quizacademy

# Construire et démarrer les services
docker-compose up --build

# Pour exécuter en arrière-plan
docker-compose up -d --build
```

Pour publier les images sur Docker Hub :

```bash
# Se connecter à Docker Hub
docker login

# Taguer les images
docker tag quizacademy_user-service votrenom/quizacademy-user-service:v1
docker tag quizacademy_content-service votrenom/quizacademy-content-service:v1

# Publier les images
docker push votrenom/quizacademy-user-service:v1
docker push votrenom/quizacademy-content-service:v1
```

## 📝 Rapport technique

En plus de l'implémentation du code, vous devez rendre un rapport technique complet (10-15 pages) qui comprend :

1. **Introduction** - Présentation du projet et de ses objectifs
2. **Architecture** - Description détaillée de l'architecture mise en place
3. **Choix techniques** - Justification des technologies utilisées et des décisions de conception
4. **Implémentation** - Explication des fonctionnalités principales implémentées
5. **Difficultés rencontrées** - Problèmes techniques et solutions adoptées
6. **Résultats** - Captures d'écran de l'application et démonstrations
7. **Améliorations futures** - Pistes d'évolution et d'amélioration
8. **Conclusion** - Synthèse et enseignements tirés
9. **Références** - Sources et documentation utilisées

## 📚 Ressources utiles

- [Documentation Flutter](https://flutter.dev/docs)
- [Documentation Spring Boot](https://docs.spring.io/spring-boot/docs/current/reference/html/)
- [Documentation Gradle](https://docs.gradle.org/current/userguide/userguide.html)
- [Documentation Express.js](https://expressjs.com/fr/)
- [Documentation MongoDB et Mongoose](https://mongoosejs.com/docs/)
- [Documentation Docker Compose](https://docs.docker.com/compose/)
- [Documentation JWT](https://jwt.io/introduction/)

## 📧 Contact et support

Pour toute question ou problème concernant ce projet, veuillez contacter :

- **Dr. El Hadji Bassirou TOURE**
- Département de Mathématiques et Informatique
- Faculté des Sciences et Techniques
- Université Cheikh Anta Diop

---

Bon développement !

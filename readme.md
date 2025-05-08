# QuizAcademy - Projet Intégré Flutter & Microservices

Ce dépôt contient les scripts de génération et la documentation pour le projet QuizAcademy, une application de partage de connaissances académiques développée avec une architecture microservices et une interface mobile Flutter.

## Description du projet

QuizAcademy est une plateforme permettant aux étudiants et professeurs de poser des questions, partager des connaissances et répondre aux interrogations dans un format similaire à Quora, mais adapté au contexte universitaire.

Le projet est divisé en trois composants principaux :

- **Frontend mobile** développé avec Flutter
- **Service Utilisateurs** développé avec Java/Spring Boot
- **Service Content** développé avec Node.js/Express

## Prérequis

Pour réaliser ce projet, vous aurez besoin des outils suivants :

- **Docker** et **Docker Compose** (pour l'orchestration des services)
- **JDK 17+** (pour travailler sur le service Utilisateurs)
- **Node.js 18+** (pour travailler sur le service Content)
- **Flutter SDK** (pour le développement de l'application mobile)
- **Git** (pour la gestion du code source)
- Un IDE adapté à chaque technologie :
  - **Android Studio/VS Code** pour Flutter
  - **IntelliJ/Eclipse** pour Java
  - **VS Code** pour Node.js
- **Postman** (pour tester les APIs)

## Installation et démarrage

### 1. Générer le projet

Le dépôt contient deux fichiers principaux :

- `create_project.sh` : Script Bash pour générer la structure du projet
- `tp2_quizacademy.tex` : Document LaTeX avec les instructions détaillées du TP

Pour démarrer :

```bash
# Rendre le script exécutable
chmod +x create_project.sh

# Exécuter le script pour générer le projet
./create_project.sh
```

````

Ce script va créer un dossier `quizacademy` contenant toute la structure du projet avec les fichiers nécessaires.

### 2. Démarrer les services backend

```bash
# Accéder au répertoire backend
cd quizacademy/backend

# Construire et démarrer tous les services avec Docker Compose
docker-compose up -d

# Vérifier que les services sont bien démarrés
docker-compose ps
```

Le backend expose les APIs suivantes :

- Service Utilisateurs : http://localhost:8080/api
- Service Content : http://localhost:3000/api

### 3. Préparer et lancer l'application mobile Flutter

```bash
# Accéder au répertoire mobile
cd ../mobile

# Installer les dépendances
flutter pub get

# Lancer l'application sur un émulateur ou appareil connecté
flutter run
```

## Structure du projet généré

```
quizacademy/
├── backend/
│   ├── user-service/       # Service Utilisateurs (Java/Spring Boot)
│   ├── content-service/    # Service Content (Node.js/Express)
│   └── docker-compose.yml  # Orchestration des services backend
└── mobile/                 # Application Flutter
```

## TODOs à compléter

Le projet contient plusieurs TODOs que vous devez compléter pour mettre en œuvre les différentes fonctionnalités :

### Backend : Service Utilisateurs (Java/Spring Boot)

- **TODO-USER1** : Compléter le modèle User avec getters, setters et constructeurs
- **TODO-USER2** : Implémenter la méthode d'inscription
- **TODO-USER3** : Implémenter la méthode d'authentification
- **TODO-USER4** : Implémenter l'endpoint d'inscription
- **TODO-USER5** : Implémenter l'endpoint de connexion

### Backend : Service Content (Node.js/Express)

- **TODO-CONTENT1** : Définir le schéma de Question
- **TODO-CONTENT2** : Définir le schéma de Answer
- **TODO-CONTENT3** : Implémenter la fonction de création de question
- **TODO-CONTENT4** : Implémenter la fonction de récupération des questions par catégorie
- **TODO-CONTENT5** : Implémenter la fonction de création de réponse
- **TODO-CONTENT6** : Implémenter la fonction de vote pour une réponse

### Frontend : Application mobile Flutter

- **TODO-FL1** : Implémenter la méthode d'inscription
- **TODO-FL2** : Implémenter la méthode de connexion
- **TODO-FL3** : Implémenter la méthode pour récupérer les questions par catégorie
- **TODO-FL4** : Implémenter la méthode pour créer une question
- **TODO-FL5** : Implémenter la méthode d'inscription dans l'écran
- **TODO-FL6** : Implémenter la méthode pour charger les questions
- **TODO-FL7** : Implémenter le widget de sélection de catégorie

Les solutions pour chaque TODO sont fournies en commentaires dans les fichiers respectifs. Ces solutions sont destinées aux enseignants pour faciliter l'évaluation.

## Livrable attendu

À la fin du projet, vous devez fournir :

1. **Code source complet** intégrant tous les TODOs complétés
2. **Images Docker** publiées sur Docker Hub :
   - votrenom/quizacademy-user-service:v1
   - votrenom/quizacademy-content-service:v1
3. **Rapport technique** (10-15 pages) comprenant :
   - Architecture et choix techniques
   - Difficultés rencontrées et solutions
   - Améliorations possibles
   - Manuel d'utilisation simplifié
   - Captures d'écran de l'application

## Publication des images Docker

Pour publier vos images sur Docker Hub :

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

## Conseils pour la réalisation

1. Commencez par comprendre la structure globale du projet et les interactions entre les différents services.
2. Travaillez sur un service à la fois, dans l'ordre suivant :
   - Service Utilisateurs (backend)
   - Service Content (backend)
   - Application mobile Flutter
3. Testez chaque fonctionnalité de manière isolée avant de l'intégrer à l'ensemble.
4. Utilisez les outils de débogage de vos IDEs pour identifier et résoudre les problèmes.
5. Consultez la documentation officielle de chaque technologie en cas de besoin.

## Ressources utiles

- [Documentation Flutter](https://flutter.dev/docs)
- [Documentation Spring Boot](https://docs.spring.io/spring-boot/docs/current/reference/html/)
- [Documentation Express.js](https://expressjs.com/en/api.html)
- [Documentation Docker Compose](https://docs.docker.com/compose/)
- [Documentation RabbitMQ](https://www.rabbitmq.com/documentation.html)

---

Bon développement !

```

````

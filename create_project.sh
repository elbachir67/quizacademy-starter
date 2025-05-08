Je comprends que vous souhaitez que je continue avec le fichier .tex. Ensuite, je vais créer le script bash contenant tous les fichiers de démarrage pour le projet. Voici la suite du fichier .tex:

```tex
                    _errorMessage!,
                    style: TextStyle(color: Colors.red),
                  ),
                ),
              TextFormField(
                controller: _usernameController,
                decoration: InputDecoration(
                  labelText: 'Nom d\'utilisateur',
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
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez entrer un email';
                  }
                  if (!value.contains('@')) {
                    return 'Veuillez entrer un email valide';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _passwordController,
                decoration: InputDecoration(
                  labelText: 'Mot de passe',
                  border: OutlineInputBorder(),
                ),
                obscureText: true,
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
                decoration: InputDecoration(
                  labelText: 'Confirmer le mot de passe',
                  border: OutlineInputBorder(),
                ),
                obscureText: true,
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
              TextButton(
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => LoginScreen()),
                  );
                },
                child: Text('Déjà un compte ? Se connecter'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
\end{verbatim}
\end{codeboxtitle}

\begin{codeboxtitle}{lib/screens/questions/question_list_screen.dart - Ecran de liste des questions}
\begin{verbatim}
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
    
    if (categoryProvider.categories.isEmpty) {
      setState(() => _isLoading = true);
      
      try {
        await categoryProvider.fetchCategories();
        if (categoryProvider.categories.isNotEmpty) {
          _selectedCategory = categoryProvider.categories.first;
          _loadQuestions();
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur: Impossible de charger les catégories')),
        );
      } finally {
        setState(() => _isLoading = false);
      }
    } else {
      _selectedCategory = categoryProvider.categories.first;
      _loadQuestions();
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
            onPressed: () {
              Navigator.pushNamed(context, '/search');
            },
          ),
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : Column(
              children: [
                _buildCategorySelector(categoryProvider),
                Expanded(
                  child: questionProvider.questions.isEmpty
                      ? Center(child: Text('Aucune question dans cette catégorie'))
                      : RefreshIndicator(
                          onRefresh: () => _loadQuestions(refresh: true),
                          child: ListView.builder(
                            itemCount: questionProvider.questions.length + (_hasMore ? 1 : 0),
                            itemBuilder: (ctx, i) {
                              if (i == questionProvider.questions.length) {
                                return _buildLoadMoreButton();
                              }
                              
                              return QuestionCard(
                                question: questionProvider.questions[i],
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => QuestionDetailScreen(
                                        questionId: questionProvider.questions[i].id,
                                      ),
                                    ),
                                  );
                                },
                              );
                            },
                          ),
                        ),
                ),
              ],
            ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => CreateQuestionScreen(
                categories: categoryProvider.categories,
              ),
            ),
          ).then((_) => _loadQuestions(refresh: true));
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
  }

  Widget _buildLoadMoreButton() {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 16.0),
      child: Center(
        child: ElevatedButton(
          onPressed: _isLoading ? null : () => _loadQuestions(),
          child: _isLoading
              ? CircularProgressIndicator(color: Colors.white)
              : Text('Charger plus'),
        ),
      ),
    );
  }
}
\end{verbatim}
\end{codeboxtitle}

\begin{todobox}
\textbf{Exercice 3.1 : Implementation de la methode d'inscription (TODO-FL1)}

Completez la methode \texttt{register} dans \texttt{auth\_service.dart} pour :
\begin{itemize}
    \item Faire une requete POST a /auth/register avec les donnees utilisateur
    \item Gerer les reponses de succes et d'erreur
    \item Retourner l'utilisateur cree en cas de succes
\end{itemize}
\end{todobox}

\begin{codeboxtitle}{Solution pour lib/services/auth_service.dart (TODO-FL1)}
\begin{verbatim}
Future<User> register(String username, String email, String password) async {
  final response = await http.post(
    Uri.parse('$baseUrl/register'),
    headers: {'Content-Type': 'application/json'},
    body: json.encode({
      'username': username,
      'email': email,
      'password': password
    }),
  );

  if (response.statusCode == 201) {
    final responseData = json.decode(response.body);
    return User.fromJson(responseData);
  } else {
    final errorData = json.decode(response.body);
    throw Exception(errorData['error'] ?? 'Failed to register user');
  }
}
\end{verbatim}
\end{codeboxtitle}

\begin{todobox}
\textbf{Exercice 3.2 : Implementation de la methode de connexion (TODO-FL2)}

Completez la methode \texttt{login} dans \texttt{auth\_service.dart} pour :
\begin{itemize}
    \item Faire une requete POST a /auth/login avec username et password
    \item Sauvegarder le token JWT recu dans les SharedPreferences
    \item Retourner l'utilisateur connecte
\end{itemize}
\end{todobox}

\begin{codeboxtitle}{Solution pour lib/services/auth_service.dart (TODO-FL2)}
\begin{verbatim}
Future<User> login(String username, String password) async {
  final response = await http.post(
    Uri.parse('$baseUrl/login'),
    headers: {'Content-Type': 'application/json'},
    body: json.encode({
      'username': username,
      'password': password
    }),
  );

  if (response.statusCode == 200) {
    final responseData = json.decode(response.body);
    
    // Save token to SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', responseData['token']);
    
    // Return user object
    return User.fromJson(responseData['user']);
  } else {
    final errorData = json.decode(response.body);
    throw Exception(errorData['error'] ?? 'Failed to login');
  }
}
\end{verbatim}
\end{codeboxtitle}

\begin{todobox}
\textbf{Exercice 3.3 : Implementation de la methode pour recuperer les questions (TODO-FL3)}

Completez la methode \texttt{getQuestionsByCategory} dans \texttt{question\_service.dart} pour :
\begin{itemize}
    \item Faire une requete GET a /categories/\{categoryId\}/questions
    \item Gerer la pagination (parametres page et limit)
    \item Parser la reponse en liste de Question
\end{itemize}
\end{todobox}

\begin{codeboxtitle}{Solution pour lib/services/question_service.dart (TODO-FL3)}
\begin{verbatim}
Future<Map<String, dynamic>> getQuestionsByCategory(String categoryId, {int page = 1, int limit = 10}) async {
  final response = await http.get(
    Uri.parse('$baseUrl/categories/$categoryId/questions?page=$page&limit=$limit'),
  );

  if (response.statusCode == 200) {
    final responseData = json.decode(response.body);
    
    // Parse questions
    final List<Question> questions = (responseData['questions'] as List)
        .map((questionJson) => Question.fromJson(questionJson))
        .toList();
    
    // Return questions with pagination metadata
    return {
      'questions': questions,
      'pagination': responseData['pagination'],
    };
  } else {
    final errorData = json.decode(response.body);
    throw Exception(errorData['error'] ?? 'Failed to fetch questions');
  }
}
\end{verbatim}
\end{codeboxtitle}

\begin{todobox}
\textbf{Exercice 3.4 : Implementation de la methode de creation de question (TODO-FL4)}

Completez la methode \texttt{createQuestion} dans \texttt{question\_service.dart} pour :
\begin{itemize}
    \item Recuperer le token JWT avec authService.getToken()
    \item Faire une requete POST a /questions avec les donnees et le token
    \item Retourner la question creee
\end{itemize}
\end{todobox}

\begin{codeboxtitle}{Solution pour lib/services/question_service.dart (TODO-FL4)}
\begin{verbatim}
Future<Question> createQuestion(String title, String content, String categoryId, List<String> tags) async {
  // Get auth token
  final token = await authService.getToken();
  if (token == null) {
    throw Exception('User not authenticated');
  }
  
  final response = await http.post(
    Uri.parse('$baseUrl/questions'),
    headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    },
    body: json.encode({
      'title': title,
      'content': content,
      'categoryId': categoryId,
      'tags': tags,
    }),
  );

  if (response.statusCode == 201) {
    final responseData = json.decode(response.body);
    return Question.fromJson(responseData);
  } else {
    final errorData = json.decode(response.body);
    throw Exception(errorData['error'] ?? 'Failed to create question');
  }
}
\end{verbatim}
\end{codeboxtitle}

\begin{todobox}
\textbf{Exercice 3.5 : Implementation de la methode d'inscription (TODO-FL5)}

Completez la methode \texttt{\_register} dans \texttt{register\_screen.dart} pour :
\begin{itemize}
    \item Valider le formulaire (\_formKey.currentState!.validate())
    \item Verifier que les mots de passe correspondent
    \item Appeler authProvider.register avec les donnees du formulaire
    \item Gerer l'etat de chargement et les erreurs
    \item Naviguer vers l'ecran principal apres inscription reussie
\end{itemize}
\end{todobox}

\begin{codeboxtitle}{Solution pour lib/screens/auth/register_screen.dart (TODO-FL5)}
\begin{verbatim}
void _register() async {
  // Hide previous error messages
  setState(() {
    _errorMessage = null;
  });
  
  // Validate form
  if (!_formKey.currentState!.validate()) {
    return;
  }
  
  // Check passwords match
  if (_passwordController.text != _confirmPasswordController.text) {
    setState(() {
      _errorMessage = 'Les mots de passe ne correspondent pas';
    });
    return;
  }
  
  // Set loading state
  setState(() {
    _isLoading = true;
  });
  
  try {
    // Get the auth provider
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    
    // Attempt to register
    await authProvider.register(
      _usernameController.text,
      _emailController.text,
      _passwordController.text,
    );
    
    // Navigate to home page on success
    Navigator.pushReplacementNamed(context, '/home');
  } catch (e) {
    // Display error message
    setState(() {
      _errorMessage = e.toString();
    });
  } finally {
    // Reset loading state
    setState(() {
      _isLoading = false;
    });
  }
}
\end{verbatim}
\end{codeboxtitle}

\begin{todobox}
\textbf{Exercice 3.6 : Implementation du chargement des questions (TODO-FL6)}

Completez la methode \texttt{\_loadQuestions} dans \texttt{question\_list\_screen.dart} pour :
\begin{itemize}
    \item Verifier qu'une categorie est selectionnee
    \item Appeler questionProvider.fetchQuestionsByCategory
    \item Gerer l'etat de chargement et les erreurs
    \item Mettre a jour \_hasMore selon la reponse
\end{itemize}
\end{todobox}

\begin{codeboxtitle}{Solution pour lib/screens/questions/question_list_screen.dart (TODO-FL6)}
\begin{verbatim}
Future<void> _loadQuestions({bool refresh = false}) async {
  // Check if category is selected
  if (_selectedCategory == null) {
    return;
  }
  
  // Set loading state
  setState(() => _isLoading = true);
  
  try {
    // Reset page if refreshing
    if (refresh) {
      _currentPage = 1;
    }
    
    // Get the question provider
    final questionProvider = Provider.of<QuestionProvider>(context, listen: false);
    
    // Fetch questions for selected category
    final result = await questionProvider.fetchQuestionsByCategory(
      _selectedCategory!.id,
      page: _currentPage,
      refresh: refresh,
    );
    
    // Update pagination
    setState(() {
      _isLoading = false;
      _hasMore = result['hasMore'] ?? false;
      
      // Increment page for next fetch if there are more items
      if (_hasMore) {
        _currentPage++;
      }
    });
  } catch (e) {
    setState(() => _isLoading = false);
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Erreur: Impossible de charger les questions')),
    );
  }
}
\end{verbatim}
\end{codeboxtitle}

\begin{todobox}
\textbf{Exercice 3.7 : Implementation du selecteur de categorie (TODO-FL7)}

Completez la methode \texttt{\_buildCategorySelector} dans \texttt{question\_list\_screen.dart} pour :
\begin{itemize}
    \item Afficher un DropdownButton avec les categories disponibles
    \item Permettre de selectionner une categorie
    \item Appeler \_loadQuestions quand la categorie change
\end{itemize}
\end{todobox}

\begin{codeboxtitle}{Solution pour lib/screens/questions/question_list_screen.dart (TODO-FL7)}
\begin{verbatim}
Widget _buildCategorySelector(CategoryProvider categoryProvider) {
  if (categoryProvider.categories.isEmpty) {
    return SizedBox.shrink();
  }
  
  return Container(
    padding: EdgeInsets.all(16.0),
    color: Theme.of(context).colorScheme.surface,
    child: Row(
      children: [
        Text('Catégorie:', style: TextStyle(fontWeight: FontWeight.bold)),
        SizedBox(width: 16.0),
        Expanded(
          child: DropdownButton<Category>(
            isExpanded: true,
            value: _selectedCategory,
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
                  _currentPage = 1; // Reset pagination
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
\end{verbatim}
\end{codeboxtitle}

\section{Deploiement avec Docker}

\subsection{Configuration Docker pour les services backend}

\begin{codeboxtitle}{backend/user-service/Dockerfile - Dockerfile pour le service Java}
\begin{verbatim}
FROM maven:3.8-openjdk-17 as build
WORKDIR /app
COPY pom.xml .
COPY src ./src
RUN mvn package -DskipTests

FROM openjdk:17-jdk-slim
WORKDIR /app
COPY --from=build /app/target/*.jar app.jar
EXPOSE 8080
ENTRYPOINT ["java", "-jar", "app.jar"]
\end{verbatim}
\end{codeboxtitle}

\begin{codeboxtitle}{backend/content-service/Dockerfile - Dockerfile pour le service Node.js}
\begin{verbatim}
FROM node:18-alpine
WORKDIR /app
COPY package*.json ./
RUN npm install
COPY . .
EXPOSE 3000
CMD ["npm", "start"]
\end{verbatim}
\end{codeboxtitle}

\subsection{Configuration Docker Compose}

\begin{codeboxtitle}{docker-compose.yml - Orchestration des services}
\begin{verbatim}
version: '3'

services:
  user-service:
    build: ./backend/user-service
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
    build: ./backend/content-service
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
\end{verbatim}
\end{codeboxtitle}

\begin{todobox}
\textbf{Exercice 4.1 : Building et deploiement des images Docker}

Suivez ces etapes pour deployer l'application via Docker :

\begin{itemize}
    \item Naviguer a la racine du projet
    \item Construire et demarrer les services avec \texttt{docker-compose up --build}
    \item Verifier que tous les services demarrent correctement
    \item Tester l'application via les endpoints backend et l'application mobile
\end{itemize}

Assurez-vous de publier vos images sur Docker Hub :

\begin{verbatim}
# Se connecter a Docker Hub
docker login

# Taguer les images
docker tag quizacademy_user-service votrenom/quizacademy-user-service:v1
docker tag quizacademy_content-service votrenom/quizacademy-content-service:v1

# Publier les images
docker push votrenom/quizacademy-user-service:v1
docker push votrenom/quizacademy-content-service:v1
\end{verbatim}
\end{todobox}

\section{Rapport technique}

En plus de l'implementation du code, vous devez rendre un rapport technique complet (10-15 pages) qui comprend :

\begin{enumerate}
    \item \textbf{Introduction} - Presentation du projet et de ses objectifs
    \item \textbf{Architecture} - Description detaillee de l'architecture mise en place
    \item \textbf{Choix techniques} - Justification des technologies utilisees et des decisions de conception
    \item \textbf{Implementation} - Explication des fonctionnalites principales implementees
    \item \textbf{Difficultes rencontrees} - Problemes techniques et solutions adoptees
    \item \textbf{Resultats} - Captures d'ecran de l'application et demonstrations
    \item \textbf{Ameliorations futures} - Pistes d'evolution et d'amelioration
    \item \textbf{Conclusion} - Synthese et enseignements tires
    \item \textbf{References} - Sources et documentation utilisees
\end{enumerate}

Le rapport doit etre redige en français avec une mise en page professionnelle et des illustrations appropriees.

\section{Ressources complementaires et implementation pratique}

\subsection{Code source du projet}

Pour faciliter la realisation de ce projet, les codes sources de base de tous les composants sont disponibles sur GitHub :

\begin{warningbox}
\textbf{Important :} Avant de commencer le developpement, assurez-vous de cloner le depot GitHub ci-dessous et de vous familiariser avec sa structure. La comprehension du code existant est essentielle pour mener a bien les taches d'implementation.

Notez que le code du depot contient des sections marquees avec des identifiants \textbf{TODO} que vous devrez completer, correspondant aux exercices de ce document. Ces identifiants vous guideront pour localiser precisement les parties a modifier.
\end{warningbox}

\begin{codeboxtitle}{Code de depart complet}
\begin{verbatim}
https://github.com/elbachir67/quizacademy-starter.git
\end{verbatim}
\end{codeboxtitle}

Ce depot contient la structure de base de tous les composants. Pour l'installer et le configurer :

\begin{verbatim}
# Cloner le depot
git clone https://github.com/elbachir67/quizacademy-starter.git

# Acceder au repertoire
cd quizacademy-starter

# Explorer la structure du projet
ls -la

# Initialiser et demarrer les services backend
cd backend
docker-compose up -d

# Installer les dependances du frontend Flutter
cd ../mobile
flutter pub get
\end{verbatim}

\begin{pointcle}
Pour travailler efficacement sur ce projet :
\begin{itemize}
    \item Commencez par comprendre la structure globale du projet
    \item Travaillez sur un service a la fois, en suivant l'ordre logique : Backend (Utilisateurs → Content) → Frontend
    \item Testez chaque fonctionnalite de maniere isolee avant de l'integrer
    \item Utilisez les outils de debogage de Flutter pour identifier les problemes
    \item Consultez la documentation officielle de chaque technologie en cas de besoin
\end{itemize}
\end{pointcle}

\section{Conclusion}

\begin{benefitbox}
Ce projet vous a permis d'appliquer concretement les connaissances acquises en developpement mobile avec Flutter et en architecture logicielle a base de microservices. Vous avez concu et implemente une application complete avec :

\begin{itemize}
    \item Une architecture backend distribuee avec plusieurs microservices
    \item Une interface mobile responsive et intuitive
    \item Un deploiement via conteneurs Docker
    \item Une comprehension des enjeux de communication entre services
\end{itemize}

Ces competences sont tres recherchees sur le marche du travail et constituent une base solide pour votre future carriere de developpeur.
\end{benefitbox}

\begin{pointcle}
Points cles a retenir :

\begin{itemize}
    \item Le frontend mobile ne doit pas connaitre les details d'implementation du backend
    \item La communication entre microservices doit etre bien concue pour minimiser le couplage
    \item L'architecture a base de microservices offre flexibilite et scalabilite mais ajoute de la complexite
    \item La containerisation facilite le deploiement et garantit la coherence entre environnements
    \item Une bonne architecture est modulaire et permet de faire evoluer chaque composant independamment
\end{itemize}
\end{pointcle}

\begin{warningbox}
Dans un contexte professionnel, les projets de ce type necessiteraient egalement :
\begin{itemize}
    \item Des tests automatises (unitaires, integration, E2E)
    \item Des procedures CI/CD pour l'integration et le deploiement continus
    \item Des strategies de monitoring et d'observabilite
    \item Une documentation API plus complete (OpenAPI/Swagger)
    \item Des strategies de securite plus avancees
\end{itemize}
Gardez ces aspects a l'esprit pour vos projets futurs.
\end{warningbox}

\end{document}
```

Maintenant, je vais vous fournir le script bash contenant tous les fichiers de démarrage avec les TODOs et leurs solutions. Ce script créera automatiquement la structure du projet:

```bash
#!/bin/bash

# Script de création du projet QuizAcademy
# Ce script crée tous les fichiers nécessaires pour démarrer le projet
# avec des TODOs clairement identifiés que les étudiants devront compléter.

set -e

# Créer le répertoire du projet
mkdir -p quizacademy
cd quizacademy

# Créer le README principal
cat > README.md << 'EOF'
# QuizAcademy

Application de partage de connaissances académiques inspirée par Quora.

## Architecture

- **Frontend**: Application mobile Flutter
- **Backend**:
  - Service Utilisateurs (Java/Spring Boot)
  - Service Content (Node.js/Express)

## Démarrage rapide

### Prérequis

- Docker et Docker Compose
- Flutter SDK
- JDK 17+ (pour travailler sur le service Utilisateurs)
- Node.js 18+ (pour travailler sur le service Content)

### Lancer les services backend

```bash
cd backend
docker-compose up -d
```

### Lancer l'application mobile Flutter

```bash
cd mobile
flutter pub get
flutter run
```

## TODOs

Le projet contient plusieurs TODOs que vous devez compléter:

- Backend: TODOs USER1-5 et CONTENT1-6
- Frontend: TODOs FL1-7

Chaque TODO est clairement documenté dans le code.
EOF

# Créer la structure du projet
mkdir -p backend/user-service/src/main/{java/com/quizacademy/userservice/{controller,model,repository,service,security},resources}
mkdir -p backend/content-service/{src/{models,controllers,routes,services,utils},config}
mkdir -p mobile/{lib/{models,screens/{auth,questions,profile},services,providers,widgets,config},assets/images}

# Créer les fichiers Docker
mkdir -p backend/user-service/src/main/resources

# Docker Compose pour le backend
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

# Dockerfile pour le service Utilisateurs
cat > backend/user-service/Dockerfile << 'EOF'
FROM maven:3.8-openjdk-17 as build
WORKDIR /app
COPY pom.xml .
COPY src ./src
RUN mvn package -DskipTests

FROM openjdk:17-jdk-slim
WORKDIR /app
COPY --from=build /app/target/*.jar app.jar
EXPOSE 8080
ENTRYPOINT ["java", "-jar", "app.jar"]
EOF

# pom.xml pour le service Utilisateurs
cat > backend/user-service/pom.xml << 'EOF'
<?xml version="1.0" encoding="UTF-8"?>
<project xmlns="http://maven.apache.org/POM/4.0.0"
         xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
         xsi:schemaLocation="http://maven.apache.org/POM/4.0.0 http://maven.apache.org/xsd/maven-4.0.0.xsd">
    <modelVersion>4.0.0</modelVersion>

    <parent>
        <groupId>org.springframework.boot</groupId>
        <artifactId>spring-boot-starter-parent</artifactId>
        <version>2.7.0</version>
        <relativePath/>
    </parent>

    <groupId>com.quizacademy</groupId>
    <artifactId>user-service</artifactId>
    <version>1.0.0</version>

    <properties>
        <java.version>17</java.version>
    </properties>

    <dependencies>
        <dependency>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-starter-web</artifactId>
        </dependency>
        <dependency>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-starter-data-jpa</artifactId>
        </dependency>
        <dependency>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-starter-security</artifactId>
        </dependency>
        <dependency>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-starter-validation</artifactId>
        </dependency>
        <dependency>
            <groupId>com.h2database</groupId>
            <artifactId>h2</artifactId>
            <scope>runtime</scope>
        </dependency>
        <dependency>
            <groupId>io.jsonwebtoken</groupId>
            <artifactId>jjwt-api</artifactId>
            <version>0.11.5</version>
        </dependency>
        <dependency>
            <groupId>io.jsonwebtoken</groupId>
            <artifactId>jjwt-impl</artifactId>
            <version>0.11.5</version>
            <scope>runtime</scope>
        </dependency>
        <dependency>
            <groupId>io.jsonwebtoken</groupId>
            <artifactId>jjwt-jackson</artifactId>
            <version>0.11.5</version>
            <scope>runtime</scope>
        </dependency>
        <dependency>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-starter-test</artifactId>
            <scope>test</scope>
        </dependency>
    </dependencies>

    <build>
        <plugins>
            <plugin>
                <groupId>org.springframework.boot</groupId>
                <artifactId>spring-boot-maven-plugin</artifactId>
            </plugin>
        </plugins>
    </build>
</project>
EOF

# application.properties pour le service Utilisateurs
cat > backend/user-service/src/main/resources/application.properties << 'EOF'
server.port=8080

# Base de données H2
spring.datasource.url=jdbc:h2:mem:userdb
spring.datasource.driverClassName=org.h2.Driver
spring.datasource.username=sa
spring.datasource.password=password
spring.jpa.database-platform=org.hibernate.dialect.H2Dialect
spring.h2.console.enabled=true
spring.h2.console.path=/h2-console

# JPA/Hibernate
spring.jpa.hibernate.ddl-auto=update
spring.jpa.show-sql=true

# JWT
jwt.secret=your_jwt_secret_key_here
jwt.expiration=86400000
EOF

# Fichier principal de l'application Java
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

# Configuration de sécurité
cat > backend/user-service/src/main/java/com/quizacademy/userservice/security/SecurityConfig.java << 'EOF'
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
public class SecurityConfig {

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
            
        // Pour H2 Console
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
        configuration.setAllowedMethods(Arrays.asList("GET", "POST", "PUT", "DELETE", "OPTIONS"));
        configuration.setAllowedHeaders(Arrays.asList("authorization", "content-type", "x-auth-token"));
        UrlBasedCorsConfigurationSource source = new UrlBasedCorsConfigurationSource();
        source.registerCorsConfiguration("/**", configuration);
        return source;
    }
}
EOF

# Classe JwtTokenProvider
cat > backend/user-service/src/main/java/com/quizacademy/userservice/security/JwtTokenProvider.java << 'EOF'
package com.quizacademy.userservice.security;

import io.jsonwebtoken.Claims;
import io.jsonwebtoken.Jwts;
import io.jsonwebtoken.SignatureAlgorithm;
import io.jsonwebtoken.security.Keys;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Component;

import java.nio.charset.StandardCharsets;
import java.security.Key;
import java.util.Date;
import java.util.Set;

@Component
public class JwtTokenProvider {

    @Value("${jwt.secret}")
    private String jwtSecret;

    @Value("${jwt.expiration}")
    private int jwtExpiration;

    private Key getSigningKey() {
        byte[] keyBytes = jwtSecret.getBytes(StandardCharsets.UTF_8);
        return Keys.hmacShaKeyFor(keyBytes);
    }

    public String createToken(String username, Set<String> roles) {
        Claims claims = Jwts.claims().setSubject(username);
        claims.put("roles", roles);

        Date now = new Date();
        Date validity = new Date(now.getTime() + jwtExpiration);

        return Jwts.builder()
                .setClaims(claims)
                .setIssuedAt(now)
                .setExpiration(validity)
                .signWith(getSigningKey(), SignatureAlgorithm.HS256)
                .compact();
    }

    public String getUsername(String token) {
        return Jwts.parserBuilder()
                .setSigningKey(getSigningKey())
                .build()
                .parseClaimsJws(token)
                .getBody()
                .getSubject();
    }

    public boolean validateToken(String token) {
        try {
            Jwts.parserBuilder().setSigningKey(getSigningKey()).build().parseClaimsJws(token);
            return true;
        } catch (Exception e) {
            return false;
        }
    }
}
EOF

# Classe User
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
    
    // Solution pour TODO-USER1
    /*
    // Getters et setters
    public Long getId() {
        return id;
    }

    public void setId(Long id) {
        this.id = id;
    }

    public String getUsername() {
        return username;
    }

    public void setUsername(String username) {
        this.username = username;
    }

    public String getEmail() {
        return email;
    }

    public void setEmail(String email) {
        this.email = email;
    }

    public String getPassword() {
        return password;
    }

    public void setPassword(String password) {
        this.password = password;
    }

    public String getProfilePicture() {
        return profilePicture;
    }

    public void setProfilePicture(String profilePicture) {
        this.profilePicture = profilePicture;
    }

    public Set<String> getRoles() {
        return roles;
    }

    public void setRoles(Set<String> roles) {
        this.roles = roles;
    }

    public LocalDateTime getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(LocalDateTime createdAt) {
        this.createdAt = createdAt;
    }

    // Constructeurs
    public User() {
        this.createdAt = LocalDateTime.now();
    }

    public User(String username, String email, String password) {
        this.username = username;
        this.email = email;
        this.password = password;
        this.createdAt = LocalDateTime.now();
        this.roles = new HashSet<>();
        this.roles.add("ROLE_USER");
    }
    */
}
EOF

# Repository User
cat > backend/user-service/src/main/java/com/quizacademy/userservice/repository/UserRepository.java << 'EOF'
package com.quizacademy.userservice.repository;

import com.quizacademy.userservice.model.User;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface UserRepository extends JpaRepository<User, Long> {
    User findByUsername(String username);
    User findByEmail(String email);
    boolean existsByUsername(String username);
    boolean existsByEmail(String email);
}
EOF

# DTO LoginRequest
cat > backend/user-service/src/main/java/com/quizacademy/userservice/dto/LoginRequest.java << 'EOF'
package com.quizacademy.userservice.dto;

public class LoginRequest {
    private String username;
    private String password;

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

# Service d'authentification
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
import java.util.HashSet;
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
    
    // Solution pour TODO-USER2
    /*
    public User register(User user) {
        // Verify if user already exists
        if (userRepository.existsByUsername(user.getUsername())) {
            throw new RuntimeException("Username is already taken");
        }
        
        if (userRepository.existsByEmail(user.getEmail())) {
            throw new RuntimeException("Email is already in use");
        }
        
        // Encode password
        user.setPassword(passwordEncoder.encode(user.getPassword()));
        
        // Set default role
        user.setRoles(new HashSet<>(Collections.singletonList("ROLE_USER")));
        
        // Set creation date
        user.setCreatedAt(LocalDateTime.now());
        
        // Save user
        return userRepository.save(user);
    }
    */

    // TODO-USER3: Implementer la methode d'authentification
    // Cette methode doit :
    // - Authentifier l'utilisateur avec authenticationManager
    // - Generer un token JWT avec jwtTokenProvider
    // - Retourner une Map contenant le token et les infos utilisateur
    public Map<String, Object> login(String username, String password) {
        // A implementer
        return null;
    }
    
    // Solution pour TODO-USER3
    /*
    public Map<String, Object> login(String username, String password) {
        try {
            // Authenticate user
            authenticationManager.authenticate(new UsernamePasswordAuthenticationToken(username, password));
            
            // Find user
            User user = userRepository.findByUsername(username);
            if (user == null) {
                throw new RuntimeException("User not found");
            }
            
            // Generate token
            String token = jwtTokenProvider.createToken(username, user.getRoles());
            
            // Prepare response
            Map<String, Object> response = new HashMap<>();
            response.put("token", token);
            response.put("user", user);
            
            return response;
        } catch (AuthenticationException e) {
            throw new RuntimeException("Invalid username/password");
        }
    }
    */
}
EOF

# Contrôleur AuthController
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
    
    // Solution pour TODO-USER4
    /*
    @PostMapping("/register")
    public ResponseEntity<?> registerUser(@RequestBody User user) {
        try {
            User createdUser = authService.register(user);
            
            // Don't return password in response
            createdUser.setPassword(null);
            
            return new ResponseEntity<>(createdUser, HttpStatus.CREATED);
        } catch (Exception e) {
            return new ResponseEntity<>(Map.of("error", e.getMessage()), HttpStatus.BAD_REQUEST);
        }
    }
    */

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
    
    // Solution pour TODO-USER5
    /*
    @PostMapping("/login")
    public ResponseEntity<?> login(@RequestBody LoginRequest loginRequest) {
        try {
            Map<String, Object> result = authService.login(loginRequest.getUsername(), loginRequest.getPassword());
            
            // Remove password from user object
            User user = (User) result.get("user");
            user.setPassword(null);
            
            return ResponseEntity.ok(result);
        } catch (Exception e) {
            return new ResponseEntity<>(Map.of("error", e.getMessage()), HttpStatus.UNAUTHORIZED);
        }
    }
    */
}
EOF

# Contrôleur UserController
cat > backend/user-service/src/main/java/com/quizacademy/userservice/controller/UserController.java << 'EOF'
package com.quizacademy.userservice.controller;

import com.quizacademy.userservice.model.User;
import com.quizacademy.userservice.repository.UserRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/users")
@CrossOrigin(origins = "*")
public class UserController {

    private final UserRepository userRepository;

    @Autowired
    public UserController(UserRepository userRepository) {
        this.userRepository = userRepository;
    }

    @GetMapping("/{id}")
    public ResponseEntity<?> getUserById(@PathVariable Long id) {
        return userRepository.findById(id)
                .map(user -> {
                    user.setPassword(null); // Ne pas retourner le mot de passe
                    return ResponseEntity.ok(user);
                })
                .orElse(ResponseEntity.notFound().build());
    }
}
EOF

# Dockerfile pour le service Content
cat > backend/content-service/Dockerfile << 'EOF'
FROM node:18-alpine
WORKDIR /app
COPY package*.json ./
RUN npm install
COPY . .
EXPOSE 3000
CMD ["npm", "start"]
EOF

# package.json pour le service Content
cat > backend/content-service/package.json << 'EOF'
{
  "name": "content-service",
  "version": "1.0.0",
  "description": "Content service for QuizAcademy",
  "main": "src/index.js",
  "scripts": {
    "start": "node src/index.js",
    "dev": "nodemon src/index.js",
    "test": "echo \"Error: no test specified\" && exit 1"
  },
  "dependencies": {
    "axios": "^1.1.3",
    "cors": "^2.8.5",
    "dotenv": "^16.0.3",
    "express": "^4.18.2",
    "jsonwebtoken": "^9.0.0",
    "mongoose": "^6.7.0",
    "morgan": "^1.10.0"
  },
  "devDependencies": {
    "nodemon": "^2.0.20"
  }
}
EOF

# Classe de modèle Question
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

// Solution pour TODO-CONTENT1
/*
const QuestionSchema = new Schema(
  {
    title: {
      type: String,
      required: true,
      trim: true,
      minlength: 5,
      maxlength: 150
    },
    content: {
      type: String,
      required: true,
      trim: true,
      minlength: 10
    },
    authorId: {
      type: String,
      required: true
    },
    authorName: {
      type: String,
      required: true
    },
    categoryId: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'Category',
      required: true
    },
    tags: {
      type: [String],
      default: []
    },
    viewCount: {
      type: Number,
      default: 0
    }
  },
  {
    timestamps: true
  }
);
*/

// Indexes pour ameliorer les performances des requetes
QuestionSchema.index({ title: 'text', content: 'text' });
QuestionSchema.index({ authorId: 1 });
QuestionSchema.index({ categoryId: 1 });
QuestionSchema.index({ tags: 1 });

module.exports = mongoose.model('Question', QuestionSchema);
EOF

# Classe de modèle Answer
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

// Solution pour TODO-CONTENT2
/*
const AnswerSchema = new Schema(
  {
    questionId: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'Question',
      required: true
    },
    content: {
      type: String,
      required: true,
      trim: true,
      minlength: 5
    },
    authorId: {
      type: String,
      required: true
    },
    authorName: {
      type: String,
      required: true
    },
    votes: {
      type: [{
        userId: String,
        vote: { type: Number, enum: [1, -1] }
      }],
      default: []
    },
    score: {
      type: Number,
      default: 0
    }
  },
  {
    timestamps: true
  }
);
*/

// Indexes
AnswerSchema.index({ questionId: 1 });
AnswerSchema.index({ authorId: 1 });
AnswerSchema.index({ score: -1 });

module.exports = mongoose.model('Answer', AnswerSchema);
EOF

# Classe de modèle Category
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

# Service utilisateur pour vérifier les tokens
cat > backend/content-service/src/services/user.service.js << 'EOF'
const axios = require('axios');
const jwt = require('jsonwebtoken');

const USER_SERVICE_URL = process.env.USER_SERVICE_URL || 'http://localhost:8080';
const JWT_SECRET = process.env.JWT_SECRET || 'your_jwt_secret_key_here';

// Verify if a user exists in the user service
const checkUserExists = async (userId) => {
  try {
    const response = await axios.get(`${USER_SERVICE_URL}/api/users/${userId}`);
    return response.status === 200;
  } catch (error) {
    console.error(`Error checking user existence: ${error.message}`);
    return false;
  }
};

// Verify a JWT token
const verifyToken = (req) => {
  const authHeader = req.headers.authorization;
  if (!authHeader || !authHeader.startsWith('Bearer ')) {
    return null;
  }

  const token = authHeader.split(' ')[1];
  try {
    const decoded = jwt.verify(token, JWT_SECRET);
    return {
      userId: decoded.sub,
      username: decoded.sub,
      roles: decoded.roles || []
    };
  } catch (error) {
    console.error(`Error verifying token: ${error.message}`);
    return null;
  }
};

module.exports = {
  checkUserExists,
  verifyToken
};
EOF

# Contrôleur des questions
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

// Solution pour TODO-CONTENT3
/*
exports.createQuestion = async (req, res) => {
  try {
    // Extract data from request
    const { title, content, categoryId, tags } = req.body;
    
    // Verify authentication
    const decodedToken = userService.verifyToken(req);
    if (!decodedToken) {
      return res.status(401).json({ error: 'Unauthorized' });
    }
    
    // Create question
    const question = new Question({
      title,
      content,
      categoryId,
      tags: tags || [],
      authorId: decodedToken.userId,
      authorName: decodedToken.username
    });
    
    // Save to database
    const savedQuestion = await question.save();
    
    // Return with 201 Created status
    res.status(201).json(savedQuestion);
  } catch (error) {
    console.error('Error creating question:', error);
    res.status(500).json({ error: 'Failed to create question' });
  }
};
*/

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

// Solution pour TODO-CONTENT4
/*
exports.getQuestionsByCategory = async (req, res) => {
  try {
    // Extract category ID from route params
    const { categoryId } = req.params;
    
    // Extract pagination parameters
    const page = parseInt(req.query.page) || 1;
    const limit = parseInt(req.query.limit) || 10;
    const skip = (page - 1) * limit;
    
    // Query questions
    const questions = await Question.find({ categoryId })
      .sort({ createdAt: -1 })
      .skip(skip)
      .limit(limit);
      
    // Count total questions for pagination info
    const totalQuestions = await Question.countDocuments({ categoryId });
    
    // Return questions with pagination metadata
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
    console.error('Error fetching questions by category:', error);
    res.status(500).json({ error: 'Failed to fetch questions' });
  }
};
*/

// Get a single question by ID with its answers
exports.getQuestionById = async (req, res) => {
  try {
    const { id } = req.params;
    
    // Find question
    const question = await Question.findById(id);
    if (!question) {
      return res.status(404).json({ error: 'Question not found' });
    }
    
    // Increment view count
    question.viewCount += 1;
    await question.save();
    
    // Get answers for this question
    const answers = await Answer.find({ questionId: id }).sort({ score: -1 });
    
    res.status(200).json({
      question,
      answers
    });
  } catch (error) {
    console.error('Error retrieving question:', error);
    res.status(500).json({ error: 'Failed to retrieve question' });
  }
};

// Search questions
exports.searchQuestions = async (req, res) => {
  try {
    const { query } = req.query;
    
    if (!query || query.trim().length < 3) {
      return res.status(400).json({ error: 'Search query must be at least 3 characters' });
    }
    
    const questions = await Question.find(
      { $text: { $search: query } },
      { score: { $meta: 'textScore' } }
    )
    .sort({ score: { $meta: 'textScore' } })
    .limit(20);
    
    res.status(200).json(questions);
  } catch (error) {
    console.error('Error searching questions:', error);
    res.status(500).json({ error: 'Failed to search questions' });
  }
};
EOF

# Contrôleur des réponses
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

// Solution pour TODO-CONTENT5
/*
exports.createAnswer = async (req, res) => {
  try {
    // Extract data
    const { content } = req.body;
    const { questionId } = req.params;
    
    // Verify authentication
    const decodedToken = userService.verifyToken(req);
    if (!decodedToken) {
      return res.status(401).json({ error: 'Unauthorized' });
    }
    
    // Check if question exists
    const questionExists = await Question.exists({ _id: questionId });
    if (!questionExists) {
      return res.status(404).json({ error: 'Question not found' });
    }
    
    // Create answer
    const answer = new Answer({
      questionId,
      content,
      authorId: decodedToken.userId,
      authorName: decodedToken.username,
      votes: [],
      score: 0
    });
    
    // Save to database
    const savedAnswer = await answer.save();
    
    // Return created answer
    res.status(201).json(savedAnswer);
  } catch (error) {
    console.error('Error creating answer:', error);
    res.status(500).json({ error: 'Failed to create answer' });
  }
};
*/

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

// Solution pour TODO-CONTENT6
/*
exports.voteAnswer = async (req, res) => {
  try {
    // Extract data
    const { answerId } = req.params;
    const { vote } = req.body;
    
    // Validate vote value
    if (vote !== 1 && vote !== -1) {
      return res.status(400).json({ error: 'Vote must be 1 or -1' });
    }
    
    // Verify authentication
    const decodedToken = userService.verifyToken(req);
    if (!decodedToken) {
      return res.status(401).json({ error: 'Unauthorized' });
    }
    
    // Find answer
    const answer = await Answer.findById(answerId);
    if (!answer) {
      return res.status(404).json({ error: 'Answer not found' });
    }
    
    // Check if user has already voted
    const existingVoteIndex = answer.votes.findIndex(v => v.userId === decodedToken.userId);
    
    if (existingVoteIndex !== -1) {
      // Remove existing vote from score
      answer.score -= answer.votes[existingVoteIndex].vote;
      
      // Update or remove existing vote
      if (answer.votes[existingVoteIndex].vote === vote) {
        // If same vote value, remove the vote (toggle off)
        answer.votes.splice(existingVoteIndex, 1);
      } else {
        // If different vote value, update the vote
        answer.votes[existingVoteIndex].vote = vote;
        answer.score += vote;
      }
    } else {
      // Add new vote
      answer.votes.push({ userId: decodedToken.userId, vote });
      answer.score += vote;
    }
    
    // Save updated answer
    const updatedAnswer = await answer.save();
    
    // Return updated answer
    res.status(200).json(updatedAnswer);
  } catch (error) {
    console.error('Error voting for answer:', error);
    res.status(500).json({ error: 'Failed to vote for answer' });
  }
};
*/

// Get an answer by ID
exports.getAnswerById = async (req, res) => {
  try {
    const { id } = req.params;
    
    const answer = await Answer.findById(id);
    if (!answer) {
      return res.status(404).json({ error: 'Answer not found' });
    }
    
    res.status(200).json(answer);
  } catch (error) {
    console.error('Error retrieving answer:', error);
    res.status(500).json({ error: 'Failed to retrieve answer' });
  }
};
EOF

# Contrôleur des catégories
cat > backend/content-service/src/controllers/category.controller.js << 'EOF'
const Category = require('../models/category.model');
const userService = require('../services/user.service');

// Create a new category
exports.createCategory = async (req, res) => {
  try {
    // Verify authentication
    const decodedToken = userService.verifyToken(req);
    if (!decodedToken) {
      return res.status(401).json({ error: 'Unauthorized' });
    }
    
    const { name, description } = req.body;
    
    // Check if category already exists
    const existingCategory = await Category.findOne({ name });
    if (existingCategory) {
      return res.status(400).json({ error: 'Category with this name already exists' });
    }
    
    // Create category
    const category = new Category({
      name,
      description
    });
    
    // Save to database
    const savedCategory = await category.save();
    
    res.status(201).json(savedCategory);
  } catch (error) {
    console.error('Error creating category:', error);
    res.status(500).json({ error: 'Failed to create category' });
  }
};

// Get all categories
exports.getAllCategories = async (req, res) => {
  try {
    const categories = await Category.find().sort({ name: 1 });
    res.status(200).json(categories);
  } catch (error) {
    console.error('Error fetching categories:', error);
    res.status(500).json({ error: 'Failed to fetch categories' });
  }
};

// Get category by ID
exports.getCategoryById = async (req, res) => {
  try {
    const { id } = req.params;
    
    const category = await Category.findById(id);
    if (!category) {
      return res.status(404).json({ error: 'Category not found' });
    }
    
    res.status(200).json(category);
  } catch (error) {
    console.error('Error retrieving category:', error);
    res.status(500).json({ error: 'Failed to retrieve category' });
  }
};
EOF

# Routes pour les questions
cat > backend/content-service/src/routes/question.routes.js << 'EOF'
const express = require('express');
const router = express.Router();
const questionController = require('../controllers/question.controller');
const answerController = require('../controllers/answer.controller');

// Questions routes
router.post('/', questionController.createQuestion);
router.get('/search', questionController.searchQuestions);
router.get('/:id', questionController.getQuestionById);

// Answers routes
router.post('/:questionId/answers', answerController.createAnswer);

module.exports = router;
EOF

# Routes pour les réponses
cat > backend/content-service/src/routes/answer.routes.js << 'EOF'
const express = require('express');
const router = express.Router();
const answerController = require('../controllers/answer.controller');

router.get('/:id', answerController.getAnswerById);
router.post('/:answerId/vote', answerController.voteAnswer);

module.exports = router;
EOF

# Routes pour les catégories
cat > backend/content-service/src/routes/category.routes.js << 'EOF'
const express = require('express');
const router = express.Router();
const categoryController = require('../controllers/category.controller');
const questionController = require('../controllers/question.controller');

router.post('/', categoryController.createCategory);
router.get('/', categoryController.getAllCategories);
router.get('/:id', categoryController.getCategoryById);
router.get('/:categoryId/questions', questionController.getQuestionsByCategory);

module.exports = router;
EOF

# Fichier principal du service Content
cat > backend/content-service/src/index.js << 'EOF'
const express = require('express');
const cors = require('cors');
const mongoose = require('mongoose');
const morgan = require('morgan');
require('dotenv').config();

// Routes
const questionRoutes = require('./routes/question.routes');
const answerRoutes = require('./routes/answer.routes');
const categoryRoutes = require('./routes/category.routes');

// MongoDB connection
const MONGODB_URI = process.env.MONGODB_URI || 'mongodb://localhost:27017/quizacademy';
mongoose.connect(MONGODB_URI)
  .then(() => console.log('Connected to MongoDB'))
  .catch(err => console.error('Could not connect to MongoDB', err));

// Express app
const app = express();
const PORT = process.env.PORT || 3000;

// Middleware
app.use(cors());
app.use(express.json());
app.use(morgan('dev'));

// Routes
app.use('/api/questions', questionRoutes);
app.use('/api/answers', answerRoutes);
app.use('/api/categories', categoryRoutes);

// Home route
app.get('/', (req, res) => {
  res.json({
    message: 'QuizAcademy Content Service API',
    version: '1.0.0'
  });
});

// Start server
app.listen(PORT, () => {
  console.log(`Server running on port ${PORT}`);
});
EOF

# Configuration Flutter
mkdir -p mobile/lib/{models,screens/{auth,questions,profile},services,providers,widgets,config}

# pubspec.yaml
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

# Config API
mkdir -p mobile/lib/config
cat > mobile/lib/config/api_config.dart << 'EOF'
class ApiConfig {
  // En mode développement, on utilise localhost
  // En production, on utiliserait une URL réelle
  static const String baseUrl = "http://10.0.2.2:8080/api"; // Pour l'émulateur Android
  static const String contentServiceUrl = "http://10.0.2.2:3000/api"; // Service Content
}
EOF

# Modèle User
mkdir -p mobile/lib/models
cat > mobile/lib/models/user.dart << 'EOF'
class User {
  final String id;
  final String username;
  final String email;
  String? profilePicture;
  final List<String> roles;
  final DateTime createdAt;

  User({
    required this.id,
    required this.username,
    required this.email,
    this.profilePicture,
    required this.roles,
    required this.createdAt,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'].toString(),
      username: json['username'],
      email: json['email'],
      profilePicture: json['profilePicture'],
      roles: List<String>.from(json['roles'] ?? []),
      createdAt: DateTime.parse(json['createdAt']),
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

# Modèle Question
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
      id: json['_id'],
      title: json['title'],
      content: json['content'],
      authorId: json['authorId'],
      authorName: json['authorName'],
      categoryId: json['categoryId'],
      tags: List<String>.from(json['tags'] ?? []),
      viewCount: json['viewCount'] ?? 0,
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }
}
EOF

# Modèle Category
cat > mobile/lib/models/category.dart << 'EOF'
class Category {
  final String id;
  final String name;
  final String description;

  Category({
    required this.id,
    required this.name,
    required this.description,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['_id'],
      name: json['name'],
      description: json['description'],
    );
  }
}
EOF

# Service Auth
mkdir -p mobile/lib/services
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
    return Future.error('Not implemented');
  }
  
  // Solution pour TODO-FL1
  /*
  Future<User> register(String username, String email, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/register'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'username': username,
        'email': email,
        'password': password
      }),
    );

    if (response.statusCode == 201) {
      final responseData = json.decode(response.body);
      return User.fromJson(responseData);
    } else {
      final errorData = json.decode(response.body);
      throw Exception(errorData['error'] ?? 'Failed to register user');
    }
  }
  */

  // TODO-FL2: Implementer la methode de connexion
  // Cette methode doit :
  // - Faire une requete POST a /auth/login avec username et password
  // - Sauvegarder le token JWT recu dans les SharedPreferences
  // - Retourner l'utilisateur connecte
  Future<User> login(String username, String password) async {
    // A implementer
    return Future.error('Not implemented');
  }
  
  // Solution pour TODO-FL2
  /*
  Future<User> login(String username, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/login'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'username': username,
        'password': password
      }),
    );

    if (response.statusCode == 200) {
      final responseData = json.decode(response.body);
      
      // Save token to SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('auth_token', responseData['token']);
      
      // Return user object
      return User.fromJson(responseData['user']);
    } else {
      final errorData = json.decode(response.body);
      throw Exception(errorData['error'] ?? 'Failed to login');
    }
  }
  */

  // Méthode pour récupérer le token stocké
  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  // Méthode pour déconnecter l'utilisateur
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
  }

  // Méthode pour vérifier si l'utilisateur est connecté
  Future<bool> isLoggedIn() async {
    final token = await getToken();
    return token != null;
  }
}
EOF

# Service Question
cat > mobile/lib/services/question_service.dart << 'EOF'
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../models/question.dart';
import '../models/category.dart';
import 'auth_service.dart';

class QuestionService {
  final String baseUrl = ApiConfig.contentServiceUrl;
  final AuthService authService = AuthService();

  // TODO-FL3: Implementer la methode pour recuperer les questions par categorie
  // Cette methode doit :
  // - Faire une requete GET a /categories/{categoryId}/questions
  // - Gerer la pagination (parametres page et limit)
  // - Parser la reponse en liste de Question
  Future<Map<String, dynamic>> getQuestionsByCategory(String categoryId, {int page = 1, int limit = 10}) async {
    // A implementer
    return Future.error('Not implemented');
  }
  
  // Solution pour TODO-FL3
  /*
  Future<Map<String, dynamic>> getQuestionsByCategory(String categoryId, {int page = 1, int limit = 10}) async {
    final response = await http.get(
      Uri.parse('$baseUrl/categories/$categoryId/questions?page=$page&limit=$limit'),
    );

    if (response.statusCode == 200) {
      final responseData = json.decode(response.body);
      
      // Parse questions
      final List<Question> questions = (responseData['questions'] as List)
          .map((questionJson) => Question.fromJson(questionJson))
          .toList();
      
      // Return questions with pagination metadata
      return {
        'questions': questions,
        'pagination': responseData['pagination'],
      };
    } else {
      final errorData = json.decode(response.body);
      throw Exception(errorData['error'] ?? 'Failed to fetch questions');
    }
  }
  */

  // TODO-FL4: Implementer la methode pour creer une question
  // Cette methode doit :
  // - Recuperer le token JWT avec authService.getToken()
  // - Faire une requete POST a /questions avec les donnees et le token
  // - Retourner la question creee
  Future<Question> createQuestion(String title, String content, String categoryId, List<String> tags) async {
    // A implementer
    return Future.error('Not implemented');
  }
  
  // Solution pour TODO-FL4
  /*
  Future<Question> createQuestion(String title, String content, String categoryId, List<String> tags) async {
    // Get auth token
    final token = await authService.getToken();
    if (token == null) {
      throw Exception('User not authenticated');
    }
    
    final response = await http.post(
      Uri.parse('$baseUrl/questions'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: json.encode({
        'title': title,
        'content': content,
        'categoryId': categoryId,
        'tags': tags,
      }),
    );

    if (response.statusCode == 201) {
      final responseData = json.decode(response.body);
      return Question.fromJson(responseData);
    } else {
      final errorData = json.decode(response.body);
      throw Exception(errorData['error'] ?? 'Failed to create question');
    }
  }
  */

  // Méthode pour récupérer une question par son ID
  Future<Map<String, dynamic>> getQuestionWithAnswers(String questionId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/questions/$questionId'),
    );

    if (response.statusCode == 200) {
      final responseData = json.decode(response.body);
      return responseData;
    } else {
      throw Exception('Failed to fetch question details');
    }
  }

  // Méthode pour rechercher des questions
  Future<List<Question>> searchQuestions(String query) async {
    if (query.length < 3) {
      throw Exception('Search query must be at least 3 characters');
    }

    final response = await http.get(
      Uri.parse('$baseUrl/questions/search?query=${Uri.encodeComponent(query)}'),
    );

    if (response.statusCode == 200) {
      final List<dynamic> results = json.decode(response.body);
      return results.map((json) => Question.fromJson(json)).toList();
    } else {
      throw Exception('Failed to search questions');
    }
  }
}
EOF

# Service Category
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
      final List<dynamic> categoriesJson = json.decode(response.body);
      return categoriesJson.map((json) => Category.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load categories');
    }
  }

  // Récupérer une catégorie par son ID
  Future<Category> getCategoryById(String id) async {
    final response = await http.get(Uri.parse('$baseUrl/$id'));

    if (response.statusCode == 200) {
      return Category.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to load category');
    }
  }

  // Créer une nouvelle catégorie (réservé aux administrateurs)
  Future<Category> createCategory(String name, String description) async {
    // Récupérer le token d'authentification
    final token = await authService.getToken();
    if (token == null) {
      throw Exception('Not authenticated');
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
      return Category.fromJson(json.decode(response.body));
    } else {
      final error = json.decode(response.body);
      throw Exception(error['error'] ?? 'Failed to create category');
    }
  }
}
EOF

# Provider Auth
mkdir -p mobile/lib/providers
cat > mobile/lib/providers/auth_provider.dart << 'EOF'
import 'package:flutter/material.dart';
import '../models/user.dart';
import '../services/auth_service.dart';

class AuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService();
  User? _user;
  bool _isLoading = false;
  String? _error;

  User? get user => _user;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuthenticated => _user != null;

  // Méthode pour initialiser le provider au démarrage de l'application
  Future<void> initialize() async {
    _isLoading = true;
    notifyListeners();

    try {
      final isLoggedIn = await _authService.isLoggedIn();
      if (!isLoggedIn) {
        _user = null;
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Méthode pour s'inscrire
  Future<void> register(String username, String email, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _user = await _authService.register(username, email, password);
    } catch (e) {
      _error = e.toString();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Méthode pour se connecter
  Future<void> login(String username, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _user = await _authService.login(username, password);
    } catch (e) {
      _error = e.toString();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Méthode pour se déconnecter
  Future<void> logout() async {
    _isLoading = true;
    notifyListeners();

    try {
      await _authService.logout();
      _user = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
EOF

# Provider Question
cat > mobile/lib/providers/question_provider.dart << 'EOF'
import 'package:flutter/material.dart';
import '../models/question.dart';
import '../services/question_service.dart';

class QuestionProvider with ChangeNotifier {
  final QuestionService _questionService = QuestionService();
  List<Question> _questions = [];
  bool _isLoading = false;
  String? _error;
  bool _hasMore = true;

  List<Question> get questions => _questions;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get hasMore => _hasMore;

  // Méthode pour récupérer les questions par catégorie
  Future<Map<String, dynamic>> fetchQuestionsByCategory(String categoryId, {int page = 1, bool refresh = false}) async {
    if (refresh) {
      _questions = [];
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final result = await _questionService.getQuestionsByCategory(categoryId, page: page);
      
      final List<Question> newQuestions = result['questions'];
      final pagination = result['pagination'];
      
      if (refresh) {
        _questions = newQuestions;
      } else {
        _questions.addAll(newQuestions);
      }
      
      _hasMore = pagination['hasMore'] ?? false;
      
      notifyListeners();
      return {
        'hasMore': _hasMore,
      };
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Méthode pour créer une nouvelle question
  Future<Question> createQuestion(String title, String content, String categoryId, List<String> tags) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final question = await _questionService.createQuestion(title, content, categoryId, tags);
      _questions.insert(0, question); // Ajouter au début de la liste
      notifyListeners();
      return question;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Méthode pour rechercher des questions
  Future<List<Question>> searchQuestions(String query) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final results = await _questionService.searchQuestions(query);
      notifyListeners();
      return results;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
EOF

# Provider Category
cat > mobile/lib/providers/category_provider.dart << 'EOF'
import 'package:flutter/material.dart';
import '../models/category.dart';
import '../services/category_service.dart';

class CategoryProvider with ChangeNotifier {
  final CategoryService _categoryService = CategoryService();
  List<Category> _categories = [];
  bool _isLoading = false;
  String? _error;

  List<Category> get categories => _categories;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Méthode pour récupérer toutes les catégories
  Future<void> fetchCategories() async {
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

  // Méthode pour récupérer une catégorie par son ID
  Future<Category?> getCategoryById(String id) async {
    // Vérifier d'abord si la catégorie est dans la liste locale
    final localCategory = _categories.firstWhere(
      (category) => category.id == id,
      orElse: () => Category(id: '', name: '', description: ''),
    );

    if (localCategory.id.isNotEmpty) {
      return localCategory;
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final category = await _categoryService.getCategoryById(id);
      notifyListeners();
      return category;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Méthode pour créer une nouvelle catégorie (réservé aux administrateurs)
  Future<Category?> createCategory(String name, String description) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final category = await _categoryService.createCategory(name, description);
      _categories.add(category);
      notifyListeners();
      return category;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
EOF

# Écran d'inscription
mkdir -p mobile/lib/screens/auth
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
  
  // Solution pour TODO-FL5
  /*
  void _register() async {
    // Hide previous error messages
    setState(() {
      _errorMessage = null;
    });
    
    // Validate form
    if (!_formKey.currentState!.validate()) {
      return;
    }
    
    // Check passwords match
    if (_passwordController.text != _confirmPasswordController.text) {
      setState(() {
        _errorMessage = 'Les mots de passe ne correspondent pas';
      });
      return;
    }
    
    // Set loading state
    setState(() {
      _isLoading = true;
    });
    
    try {
      // Get the auth provider
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      
      // Attempt to register
      await authProvider.register(
        _usernameController.text,
        _emailController.text,
        _passwordController.text,
      );
      
      // Navigate to home page on success
      Navigator.pushReplacementNamed(context, '/home');
    } catch (e) {
      // Display error message
      setState(() {
        _errorMessage = e.toString();
      });
    } finally {
      // Reset loading state
      setState(() {
        _isLoading = false;
      });
    }
  }
  */

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
                  child: Text(
                    _errorMessage!,
                    style: TextStyle(color: Colors.red),
                  ),
                ),
              TextFormField(
                controller: _usernameController,
                decoration: InputDecoration(
                  labelText: 'Nom d\'utilisateur',
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
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez entrer un email';
                  }
                  if (!value.contains('@')) {
                    return 'Veuillez entrer un email valide';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _passwordController,
                decoration: InputDecoration(
                  labelText: 'Mot de passe',
                  border: OutlineInputBorder(),
                ),
                obscureText: true,
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
                decoration: InputDecoration(
                  labelText: 'Confirmer le mot de passe',
                  border: OutlineInputBorder(),
                ),
                obscureText: true,
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
              TextButton(
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => LoginScreen()),
                  );
                },
                child: Text('Déjà un compte ? Se connecter'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
EOF

# Écran de connexion
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
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _login() async {
    setState(() {
      _errorMessage = null;
    });

    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      await authProvider.login(
        _usernameController.text,
        _passwordController.text,
      );
      Navigator.pushReplacementNamed(context, '/home');
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
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
              if (_errorMessage != null)
                Padding(
                  padding: EdgeInsets.only(bottom: 16.0),
                  child: Text(
                    _errorMessage!,
                    style: TextStyle(color: Colors.red),
                  ),
                ),
              TextFormField(
                controller: _usernameController,
                decoration: InputDecoration(
                  labelText: 'Nom d\'utilisateur',
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
                decoration: InputDecoration(
                  labelText: 'Mot de passe',
                  border: OutlineInputBorder(),
                ),
                obscureText: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez entrer votre mot de passe';
                  }
                  return null;
                },
              ),
              SizedBox(height: 24),
              ElevatedButton(
                onPressed: _isLoading ? null : _login,
                child: _isLoading
                    ? CircularProgressIndicator(color: Colors.white)
                    : Text('Se connecter'),
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 16.0),
                ),
              ),
              SizedBox(height: 16),
              TextButton(
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => RegisterScreen()),
                  );
                },
                child: Text('Pas de compte ? S\'inscrire'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
EOF

# Écran de liste des questions
mkdir -p mobile/lib/screens/questions
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
    
    if (categoryProvider.categories.isEmpty) {
      setState(() => _isLoading = true);
      
      try {
        await categoryProvider.fetchCategories();
        if (categoryProvider.categories.isNotEmpty) {
          _selectedCategory = categoryProvider.categories.first;
          _loadQuestions();
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur: Impossible de charger les catégories')),
        );
      } finally {
        setState(() => _isLoading = false);
      }
    } else {
      _selectedCategory = categoryProvider.categories.first;
      _loadQuestions();
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
  
  // Solution pour TODO-FL6
  /*
  Future<void> _loadQuestions({bool refresh = false}) async {
    // Check if category is selected
    if (_selectedCategory == null) {
      return;
    }
    
    // Set loading state
    setState(() => _isLoading = true);
    
    try {
      // Reset page if refreshing
      if (refresh) {
        _currentPage = 1;
      }
      
      // Get the question provider
      final questionProvider = Provider.of<QuestionProvider>(context, listen: false);
      
      // Fetch questions for selected category
      final result = await questionProvider.fetchQuestionsByCategory(
        _selectedCategory!.id,
        page: _currentPage,
        refresh: refresh,
      );
      
      // Update pagination
      setState(() {
        _isLoading = false;
        _hasMore = result['hasMore'] ?? false;
        
        // Increment page for next fetch if there are more items
        if (_hasMore) {
          _currentPage++;
        }
      });
    } catch (e) {
      setState(() => _isLoading = false);
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur: Impossible de charger les questions')),
      );
    }
  }
  */

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
            onPressed: () {
              Navigator.pushNamed(context, '/search');
            },
          ),
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : Column(
              children: [
                _buildCategorySelector(categoryProvider),
                Expanded(
                  child: questionProvider.questions.isEmpty
                      ? Center(child: Text('Aucune question dans cette catégorie'))
                      : RefreshIndicator(
                          onRefresh: () => _loadQuestions(refresh: true),
                          child: ListView.builder(
                            itemCount: questionProvider.questions.length + (_hasMore ? 1 : 0),
                            itemBuilder: (ctx, i) {
                              if (i == questionProvider.questions.length) {
                                return _buildLoadMoreButton();
                              }
                              
                              return QuestionCard(
                                question: questionProvider.questions[i],
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => QuestionDetailScreen(
                                        questionId: questionProvider.questions[i].id,
                                      ),
                                    ),
                                  );
                                },
                              );
                            },
                          ),
                        ),
                ),
              ],
            ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => CreateQuestionScreen(
                categories: categoryProvider.categories,
              ),
            ),
          ).then((_) => _loadQuestions(refresh: true));
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
  
  // Solution pour TODO-FL7
  /*
  Widget _buildCategorySelector(CategoryProvider categoryProvider) {
    if (categoryProvider.categories.isEmpty) {
      return SizedBox.shrink();
    }
    
    return Container(
      padding: EdgeInsets.all(16.0),
      color: Theme.of(context).colorScheme.surface,
      child: Row(
        children: [
          Text('Catégorie:', style: TextStyle(fontWeight: FontWeight.bold)),
          SizedBox(width: 16.0),
          Expanded(
            child: DropdownButton<Category>(
              isExpanded: true,
              value: _selectedCategory,
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
                    _currentPage = 1; // Reset pagination
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
  */

  Widget _buildLoadMoreButton() {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 16.0),
      child: Center(
        child: ElevatedButton(
          onPressed: _isLoading ? null : () => _loadQuestions(),
          child: _isLoading
              ? CircularProgressIndicator(color: Colors.white)
              : Text('Charger plus'),
        ),
      ),
    );
  }
}
EOF

# Widget QuestionCard
mkdir -p mobile/lib/widgets
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
      margin: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                question.title,
                style: TextStyle(
                  fontSize: 18.0,
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              SizedBox(height: 8.0),
              Text(
                question.content,
                style: TextStyle(fontSize: 14.0),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
              SizedBox(height: 12.0),
              Row(
                children: question.tags.map((tag) => 
                  Padding(
                    padding: EdgeInsets.only(right: 8.0),
                    child: Chip(
                      label: Text(tag),
                      labelStyle: TextStyle(fontSize: 12.0),
                      padding: EdgeInsets.zero,
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                  )
                ).toList(),
              ),
              SizedBox(height: 12.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Par ${question.authorName}',
                    style: TextStyle(
                      fontSize: 12.0,
                      color: Colors.grey[700],
                    ),
                  ),
                  Text(
                    DateFormat('dd/MM/yyyy').format(question.createdAt),
                    style: TextStyle(
                      fontSize: 12.0,
                      color: Colors.grey[700],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 4.0),
              Row(
                children: [
                  Icon(Icons.visibility, size: 16.0, color: Colors.grey[600]),
                  SizedBox(width: 4.0),
                  Text(
                    '${question.viewCount} vues',
                    style: TextStyle(
                      fontSize: 12.0,
                      color: Colors.grey[600],
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

# Fichier principal de l'application Flutter
cat > mobile/lib/main.dart << 'EOF'
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/auth_provider.dart';
import 'providers/category_provider.dart';
import 'providers/question_provider.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/register_screen.dart';
import 'screens/questions/question_list_screen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => CategoryProvider()),
        ChangeNotifierProvider(create: (_) => QuestionProvider()),
      ],
      child: MaterialApp(
        title: 'QuizAcademy',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        initialRoute: '/login',
        routes: {
          '/login': (context) => LoginScreen(),
          '/register': (context) => RegisterScreen(),
          '/home': (context) => QuestionListScreen(),
        },
      ),
    );
  }
}
EOF

echo "Le projet QuizAcademy a été créé avec succès!"
echo "Pour démarrer, exécutez les commandes suivantes:"
echo "cd quizacademy"
echo "cd backend"
echo "docker-compose up -d"
echo "cd ../mobile"
echo "flutter run"
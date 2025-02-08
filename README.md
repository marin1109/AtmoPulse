# Application Météo – *AtmoPulse*

**AtmoPulse** est une application mobile développée avec **Flutter** qui fournit des informations météo complètes et en temps réel pour une ville ou une localisation donnée. Elle permet à l’utilisateur de consulter la météo actuelle, les prévisions pour les jours à venir, d’ajuster ses préférences d’unités et de recevoir des alertes en cas de conditions dangereuses.

---

## Sommaire

1. [Fonctionnalités](#fonctionnalités)  
2. [Aperçu de l'Application](#aperçu-de-lapplication)  
3. [Technologies Utilisées](#technologies-utilisées)  
4. [Installation & Exécution](#installation--exécution)  
5. [Structure du Projet](#structure-du-projet)  
6. [Contributions & Roadmap](#contributions--roadmap)  
7. [Auteur](#auteur)  

---

## Fonctionnalités

- **Météo actuelle** : Affiche la température, l’humidité, la vitesse et direction du vent, la pression, les précipitations, l’indice UV, etc.  
- **Prévisions sur plusieurs jours** : Possibilité de consulter les temperatures minimales et maximales pour les 3 prochains jours.
- **Recherche de villes** : Permet de rechercher des villes par leur nom et d’obtenir instantanément les conditions météorologiques et d'ajouter des villes en favoris.
- **Géolocalisation** : Récupère automatiquement la position GPS de l’utilisateur afin d’afficher la météo locale (avec l’autorisation de l’utilisateur).  
- **Gestion de compte** :  
  - Inscription et connexion.
  - Sauvegarde des préférences de l’utilisateur (température en °C, °F ou K, etc.).
  - Possibilité de mettre à jour son mot de passe ou de supprimer son compte.
- **Alertes météo** : Envoi d’alertes en cas de conditions météorologiques dangereuses par rapport aux préférences de l’utilisateur (température, vent, etc.).

---

## Aperçu de l’Application

*(A Completer)*

---

## Technologies Utilisées

- **Langage & Framework** :  
  - [Flutter](https://flutter.dev/) (Dart) – pour la création de l’application mobile multiplateforme.
- **Backend** :
  - [Flask](https://flask.palletsprojects.com/) – API REST pour la gestion des comptes, la communication avec la BDD, etc.
  - [Google Cloud SQL](https://cloud.google.com/sql/) – Base de données distante pour stocker les informations utilisateurs et préférences.
  - [Google Cloud App Engine](https://cloud.google.com/appengine/) – Hébergement du backend Flask.
- **API Météo** : [WeatherAPI](https://www.weatherapi.com/) – récupération des données météo.  
- **Géolocalisation** : [Geolocator](https://pub.dev/packages/geolocator) – plugin Flutter pour accéder à la position GPS.
- **Persistance locale** : [SharedPreferences](https://pub.dev/packages/shared_preferences) – permet de sauvegarder localement les préférences d’unités, etc. 
- **Gestion d’États** : [Provider](https://pub.dev/packages/provider) – pour partager et réagir aux modifications des préférences (unité de température, etc.).

---

## Installation & Exécution

1. **Cloner le dépôt**  
   ```bash
   git clone https://github.com/marin1109/AtmoPulse.git
   cd AtmoPulse
   ```

2. **Installer les dépendances Flutter**  
   ```bash
   flutter pub get
   ```

3. **Configurer les variables d’environnement**  
   - Créer un fichier `.env` dans le répertoire `assets/` (ou à l’emplacement indiqué) en y ajoutant vos clés d’API :
     ```
     WHEATHER_API_KEY=YOUR_WEATHER_API_KEY
     GCLOUD_API_BASE_URL=https://votre-backend-url.com
     ```
   - Adapter ces variables selon vos besoins (URL du backend, etc.).

4. **Exécuter l’application**  
     ```bash
     flutter run
     ```  

5. **(Optionnel) Tester**  
     ```bash
     flutter test
     ```

---

## Structure du Projet

```
├── lib/
│   ├── main.dart               # Point d'entrée de l'application Flutter
│   ├── services/               # Services (météo, géolocalisation, compte)
│   ├── view/                   # Vues de l'application
│   │   ├── user/               # Page de l'utilisateur
│   │   ├── dialogs/            # Dialogues (à propos, contact, etc.)
│   │   ├── home/               # Page d'accueil et affichage des données météo
│   │   ├── login_signup/       # Pages de connexion et d'inscription
│   │   └── settings/           # Page des préférences
│   ├── utils/                  # Logique de l'application (UserPreferences et classes abstractes)
│   ├── models/                 # Modèles de données (User, Weather)
│   │   └── types/              # Types de données (Temp, Humidity, etc.) avec validation et conversion
│   └── controllers/            # Contrôleurs pour gérer les interactions entre les vues et les services/models
├── DataBase_descriptive.md     # Description de la base de données et du schéma
├── Solutions.md                # Liste des problèmes rencontrés et solutions trouvées
└── README.md                   # Documentation du projet
```

- **`main.dart`** : point d’entrée de l’application Flutter.  
- **`services/`** : contient la logique d’interaction avec les APIs (Weather API, backend Flask).  
- **`view/`** : l’interface utilisateur (UI) :  
  - `user/` : gestion du compte utilisateur connecté (profil, déconnexion, etc.).
  - `login_signup/` : pages de connexion et d’inscription.
  - `dialogs/` : boîtes de dialogue (contact, à propos, etc.).  
  - `home/` : page d’accueil pour afficher la météo actuelle et les prévisions.  
  - `settings/` : gestion des préférences d’unités.  
- **`utils/`** : comprend des classes utilitaires (ex. : `UserPreferences`) pour gérer la logique d’état et de stockage local.  
- **`models/`** : modèles de données (User, Weather) pour structurer les informations.
  - `types/` : définitions et conversions des unités météo (température, pression, humidité, etc.).
- **`controllers/`** : contrôleurs pour gérer les interactions entre les vues et les  
---

## Contributions & Roadmap

- Les **Issues** et **Pull Requests** sont les bienvenus.  
- *Idées d'ajout de fonctionnalitées* :  
  - Gestion des thèmes (dark mode, light mode).  
  - Localisation multi-langues.
- *Idées d'amélioration* :  
  - Ajout de tests unitaires et d’intégration.  
  - Passage de SharedPreferences à une solution plus sécurisée (ex. : flutter_secure_storage).
  - Mise en place d’un linter et de règles de style pour uniformiser le code (ex. Effective Dart).
  - Gestion centralisée des erreurs et logs.
  - Envisager l’utilisation de tokens sécurisés (OAuth2, JWT), le chiffrement des données en transit (HTTPS).

N’hésitez pas à proposer vos idées et corrections !

---

## Ce que ce projet m’a permis d’apprendre

- Planification de l’architecture dès le début : J’ai réalisé à quel point une architecture claire (par exemple, en s’inspirant de la MVC) est essentielle pour faciliter la maintenance, la compréhension et l’évolution du code.
- Importance des patrons de conception : L’utilisation de patrons conceptuels (comme Provider pour la gestion d’états, Repository pour la gestion des données, etc.) permet de structurer et de découpler les différentes couches de l’application.
- Gestion des données et sécurité : Le choix des technologies de persistance (SharedPreferences, flutter_secure_storage) et la sécurisation de la communication (HTTPS, gestion des tokens, etc.) doivent être pensés en amont pour éviter les mauvaises surprises.
- Meilleure organisation en équipe : Même en solo, s’habituer à une organisation modulaire (services, models, views) permet d’accueillir plus facilement de nouveaux collaborateurs ou contributeurs.
- Gestion des états complexes : Avec Provider, j’ai pu apprendre à gérer les états et les préférences de l’utilisateur, notamment pour les unités de mesure. Cela m’a également montré l’importance de maintenir la cohérence entre les données stockées localement, en base de données et à l’écran.

---

## Auteur

**Marin Postolachi**  
- [GitHub](https://github.com/marin1109)  
- [*Pour toute question ou suggestion, n’hésitez pas à me contacter.*](mailto:marin.postolachi@etu.u-paris.fr)

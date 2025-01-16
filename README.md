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
│   ├── types/                  # Types de données (Temp, Humidity, etc.) avec validation et conversion
│   ├── view/                   # Vues de l'application
│   │   ├── account/            # Pages de connexion, inscription, profil utilisateur
│   │   ├── dialogs/            # Dialogues (à propos, contact, etc.)
│   │   ├── home/               # Page d'accueil et affichage des données météo
│   │   └── settings/           # Page des préférences
│   ├── utils/                  # Logique de l'application (UserPreferences, etc.)
│   ├── models/                 # Modèles de données (User, Weather)
│   ├── [...]
│   └── [...]
├── DataBase_descriptive.md     # Description de la base de données et du schéma
├── Solutions.md                # Liste des problèmes rencontrés et solutions trouvées
└── README.md                   # Documentation du projet
```

- **`main.dart`** : point d’entrée de l’application Flutter.  
- **`services/`** : contient la logique d’interaction avec les APIs (Weather API, backend Flask).  
- **`types/`** : définitions et conversions des unités météo (température, pression, humidité, etc.).  
- **`view/`** : l’interface utilisateur (UI) :  
  - `account/` : pages de connexion, inscription, gestion du compte.  
  - `dialogs/` : boîtes de dialogue (contact, à propos, etc.).  
  - `home/` : page d’accueil pour afficher la météo actuelle et les prévisions.  
  - `settings/` : gestion des préférences d’unités.  
- **`utils/`** : comprend des classes utilitaires (ex. : `UserPreferences`) pour gérer la logique d’état et de stockage local.  
- **`models/`** : modèles de données (User, Weather) pour structurer les informations.

---

## Contributions & Roadmap

- Les **Issues** et **Pull Requests** sont les bienvenus.  
- *Idées d’amélioration* :  
  - Ajout de tests unitaires et d’intégration.  
  - Gestion des thèmes (dark mode, light mode).  
  - Localisation multi-langues.

N’hésitez pas à proposer vos idées et corrections !

---

## Auteur

**Marin Postolachi**  
- [GitHub](https://github.com/marin1109)  
- [*Pour toute question ou suggestion, n’hésitez pas à me contacter.*](mailto:marin.postolachi@etu.u-paris.fr)

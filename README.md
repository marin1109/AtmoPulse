# Application Météo

Une application mobile de météo développée avec Flutter. L'application permet aux utilisateurs de consulter les prévisions météorologiques pour une localisation donnée. Elle utilise une API météo pour récupérer et afficher les données en temps réel.

## Fonctionnalités

- Consultation des prévisions météorologiques actuelles
- Affichage de la température, de l'humidité, de la vitesse du vent, etc.
- Alertes météo en cas de conditions dangereuses
- Prévision sur plusieurs jours
- Recherche de villes par nom

## Technologies Utilisées

- **Langage de programmation** : Dart
- **Framework** : Flutter
- **Backend** : Flask (API)
- **Base de données** : Google Cloud SQL
- **Hébergement** : Google Cloud App Engine

## Structure du Projet

```
├── lib/
│   ├── main.dart               # Point d'entrée de l'application
│   ├── services/               # Services de l'application
│   ├── types/                  # Types de données
│   ├── view/                   # Vues de l'application
│   │   ├── account/            # Page de l'utilisateur
│   │   ├── dialogs/            # Dialogues
│   │   ├── home/               # Page d'accueil
│   │   └── settings/           # Page des préférences
│   ├── utils/                  # Logique de l'application
│   ├── [...]
│   └── [...]
├── DataBase_descriptive.md     # Description de la base de données
├── Solutions.md                # Solutions aux problèmes rencontrés
└── README.md                   # Documentation du projet
```

## Auteur

- [**Marin Postolachi**](https://github.com/marin1109)

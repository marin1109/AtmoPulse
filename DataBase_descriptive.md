# Documentation de la Base de Données

Cette base de données est conçue pour gérer :
1. Les utilisateurs.
2. Les données météorologiques collectées par heure.
3. Les préférences des utilisateurs pour les unités de mesure.

---

## Structure des Tables

### 1. Table `utilisateurs`
Cette table stocke les informations des utilisateurs.
_____________________________________________________________________________________________
| **Champ**             | **Type**         | **Description**                                |
|-----------------------|------------------|------------------------------------------------|
| `id`                  | INT (PK)         | Identifiant unique de l'utilisateur.           |
| `prenom`              | VARCHAR(50)      | Prénom de l'utilisateur.                       |
| `nom`                 | VARCHAR(50)      | Nom de l'utilisateur.                          |
| `email`               | VARCHAR(100) (U) | Email unique pour chaque utilisateur.          |
| `mot_de_passe`        | VARBINARY(255)   | Mot de passe (haché).                          |
| `age`                 | TINYINT          | Âge de l'utilisateur.                          |
| `date_inscription`    | TIMESTAMP        | Date et heure d'inscription.                   |
| `humidite_max`        | SMALLINT         | Humidité maximale souhaitée.                   |
| `humidite_min`        | SMALLINT         | Humidité minimale souhaitée.                   |
| `temperature_max`     | SMALLINT         | Température maximale souhaitée.                |
| `temperature_min`     | SMALLINT         | Température minimale souhaitée.                |
| `vent_max`            | SMALLINT         | Vitesse du vent maximale souhaitée.            |
| `vent_min`            | SMALLINT         | Vitesse du vent minimale souhaitée.            |
| `uv`                  | TINYINT          | Index UV maximal souhaité.                     |
| `precipitations_max`  | SMALLINT         | Précipitations maximales souhaitées.           |
| `precipitations_min`  | SMALLINT         | Précipitations minimales souhaitées.           |
‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾
---

### 2. Table `preferences_unite`
Cette table stocke les préférences d'unités pour chaque utilisateur.
_________________________________________________________________________________________
| **Champ**             | **Type**         | **Description**                            |
|-----------------------|------------------|--------------------------------------------|
| `id`                  | INT (PK)         | Identifiant unique de la préférence.       |
| `id_utilisateur`      | INT (FK)         | Référence à l'utilisateur.                 |
| `unite_temperature`   | VARCHAR(25)      | Unité pour la température (ex: celsius).   |
| `unite_vent`          | VARCHAR(25)      | Unité pour la vitesse du vent (ex: kmh).   |
| `unite_humidite`      | VARCHAR(25)      | Unité pour l'humidité (ex: absolute).      |
| `unite_pression`      | VARCHAR(25)      | Unité pour la pression (ex: hPa).          |
| `unite_precipitations`| VARCHAR(25)      | Unité pour les précipitations (ex: mm).    |
‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾
**Relation :**
- `preferences_unite.id_utilisateur` est une clé étrangère vers `utilisateurs.id`.

---

### 3. Table `villes_favories`
Cette table stocke les villes favorites de chaque utilisateur.
_________________________________________________________________________________________
| **Champ**             | **Type**         | **Description**                            |
|-----------------------|------------------|--------------------------------------------|
| `id`                  | INT (PK)         | Identifiant unique de la ville favorite.   |
| `id_utilisateur`      | INT (FK)         | Référence à l'utilisateur.                 |
| `ville_url`           | VARCHAR(200)     | URL de la ville favorite.                  |
| `ville_nom`           | VARCHAR(50)      | Nom de la ville favorite.                  |
| `ville_region_nom`    | VARCHAR(50)      | Nom de la région de la ville favorite.     |
| `ville_pays_nom`      | VARCHAR(50)      | Nom du pays de la ville favorite.          |
‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾
**Relation :**
- `villes_favories.id_utilisateur` est une clé étrangère vers `utilisateurs.id`.

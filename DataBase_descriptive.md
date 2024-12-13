# Documentation de la Base de Données

Cette base de données est conçue pour gérer :
1. Les utilisateurs.
2. Les données météorologiques collectées par heure.
3. Les préférences des utilisateurs pour les unités de mesure.

---

## Structure des Tables

### 1. Table `utilisateurs`
Cette table stocke les informations des utilisateurs.

#### Table `utilisateurs` actuelle
| **Champ**             | **Type**         | **Description**                                |
|-----------------------|------------------|------------------------------------------------|
| `id`                  | INT (PK)         | Identifiant unique de l'utilisateur.           |
| `prenom`              | VARCHAR(50)      | Prénom de l'utilisateur.                       |
| `nom`                 | VARCHAR(50)      | Nom de l'utilisateur.                          |
| `email`               | VARCHAR(100) (U) | Email unique pour chaque utilisateur.          |
| `mot_de_passe`        | VARBINARY(255)   | Mot de passe (haché).                          |
| `age`                 | INT              | Âge de l'utilisateur.                          |
| `date_inscription`    | TIMESTAMP        | Date et heure d'inscription.                   |
| `humidite_max`        | FLOAT            | Humidité maximale souhaitée (en %).            |
| `humidite_min`        | FLOAT            | Humidité minimale souhaitée (en %).            |
| `temperature_max`     | SMALLINT         | Température maximale souhaitée (en C).         |
| `temperature_min`     | SMALLINT         | Température minimale souhaitée (en C).         |
| `pression_max`        | FLOAT            | Pression maximale souhaitée (en hPa).          |
| `pression_min`        | FLOAT            | Pression minimale souhaitée (en hPa).          |
| `vent_max`            | FLOAT            | Vitesse du vent maximale souhaitée (en km/h)   |
| `vent_min`            | FLOAT            | Vitesse du vent minimale souhaitée (en km/h)   |
| `uv`                  | TINYINT          | Index UV maximal souhaité.                     |
| `precipitations_max`  | FLOAT            | Précipitations maximales souhaitées (en mm).   |
| `precipitations_min`  | FLOAT            | Précipitations minimales souhaitées (en mm).   |

---

### 2. Table `preferences_unite`
Cette table stocke les préférences d'unités pour chaque utilisateur.

| **Champ**             | **Type**         | **Description**                            |
|-----------------------|------------------|--------------------------------------------|
| `id`                  | INT (PK)         | Identifiant unique de la préférence.       |
| `id_utilisateur`      | INT (FK)         | Référence à l'utilisateur.                 |
| `unite_temperature`   | VARCHAR(25)      | Unité pour la température (ex: celsius).   |
| `unite_vent`          | VARCHAR(25)      | Unité pour la vitesse du vent (ex: kmh).   |
| `unite_humidite`      | VARCHAR(25)      | Unité pour l'humidité (ex: absolute).      |
| `unite_pression`      | VARCHAR(25)      | Unité pour la pression (ex: hPa).          |
| `unite_precipitations`| VARCHAR(25)      | Unité pour les précipitations (ex: mm).    |

**Relation :**
- `preferences_unite.id_utilisateur` est une clé étrangère vers `utilisateurs.id`.

---

### 3. Table `donnees_meteo`
Cette table stocke les données météorologiques relevées par heure.

| **Champ**             | **Type**         | **Description**                            |
|-----------------------|------------------|--------------------------------------------|
| `id`                  | int (PK)         | Identifiant unique pour chaque relevé.     |
| `ville`               | int              | Référence à l'utilisateur (optionnel).     |
| `date_heure`          | datetime         | Date et heure du relevé.                   |
| `temperature`         | float            | Température relevée.                       |
| `humidite`            | float            | Humidité relevée (en %).                   |
| `pression`            | float            | Pression atmosphérique relevée (en hPa).   |
| `vent`                | float            | Vitesse du vent relevée (ex: km/h).        |
| `precipitations`      | float            | Précipitations relevées (ex: mm).          |
| `uv_index`            | int              | Index UV relevé.                           |

**Relation :**
- `donnees_meteo.id_utilisateur` est une clé étrangère vers `utilisateurs.id`.

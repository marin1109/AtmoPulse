# Documentation des Solutions aux Problèmes Rencontrés

## Introduction
Ce document recense les différents problèmes rencontrés ainsi que les solutions apportées pour les résoudre. Il a pour objectif de servir de référence pour éviter de rencontrer les mêmes difficultés à l'avenir.

## Problèmes et Solutions

### Problème 1 : Comment garder l'utilisateur connecté après la fermeture de l'application ou le deplacement vers une autre page
**Date** : 07/11/2024

**Contexte** : L'utilisateur doit se reconnecter à chaque fois qu'il ferme l'application ou change de page.

**Statut** : Résolu &#x2705;

#### Solution
- Utiliser le Shared Preferences pour stocker les informations, sans le mot de passe, car risque de sécurité. Ainsi, l'utilisateur n'aura pas à se reconnecter à chaque fois.

#### Remarques
- Il est important de nommer les variables de la même manière pour éviter les erreurs.

---

### Problème 2 : Comment séparer les unités de mesure de la donnée dans la base de données
**Date** : 23/11/2024

**Contexte** : Les données sont stockées dans la base de données avec des unitées de mesure prédéfinies, sans possibilité de les modifier. ex : 10km/h, 20°C, 1000hPa.

**Statut** : Résolu &#x2705;

#### Solution
- Créer une table pour les unités de mesure, puis une table pour les données. Ainsi, les données seront stockées sans unitées de mesure, et l'unitée de mesure sera stockée dans une autre table.

#### Remarques
- Il est important de mettre à jour la donnée de la mesure une fois que l'unitée de mesure est modifiée.

---

### Problème 3 : Comment envoyer les notifications à l'utilisateur
**Date** : 

**Contexte** : L'utilisateur doit être notifié lorsqu'une donnée dépasse ses limites.

**Statut** : Non commencé &#x274C;

#### Solution
- Utiliser le service de notification de Firebase pour envoyer les notifications à l'utilisateur.

#### Remarques
- Il est important de bien configurer le service de notification pour éviter les erreurs.

---

### Problème 4 : Comment ajouter les données de la météo à chaque heure dans la base de données.
**Date** :

**Contexte** : Les données de la météo doivent être ajoutées à la base de données à chaque heure mais aussi pour chaque ville dont l'utilisateur suit la météo.

**Statut** : Non commencé &#x274C;

#### Solution
- 

#### Remarques
-

--- 

### Problème 5 : Comment sécuriser les données de l'utilisateur
**Date** : 

**Contexte** : Les données de l'utilisateur sont stockées en clair dans SharedPreferences.

**Statut** : Non commencé &#x274C;

#### Solution
- Utiliser flutter_secure_storage pour stocker les données de l'utilisateur de manière sécurisée.

#### Remarques
- Il est important de ne pas stocker le mot de passe de l'utilisateur.

---

### Problème 6 : Mauvais paramètrage de l'inscription de l'utilisateur avec les unités de mesure et les données météorologiques

**Date** : 06/12/2024

**Contexte** : Lors de l'inscription, l'utilisateur ajoute ses données météorologiques préférées avec des unités de mesure basique. Cependant, dans la table de ses unités de mesure préférées, les préférences qu'il a dans l'application au moment de l'inscription sont stockées, ce qui crée une incohérence entre les deux tables.

**Statut** : Non commencé &#x274C;

#### Solution
- *A faire*

#### Remarques
- *A faire*

## Conclusion
Ce document a permis de recenser les différents problèmes rencontrés ainsi que les solutions apportées pour les résoudre. Il nous a permis de capitaliser sur les erreurs passées pour éviter de les reproduire à l'avenir.

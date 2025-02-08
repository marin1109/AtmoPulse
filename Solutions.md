Voici une version révisée et harmonisée du document, avec corrections et améliorations de style et d’orthographe :

---

# Documentation des Solutions aux Problèmes Rencontrés

## Introduction
Ce document recense les différents problèmes rencontrés ainsi que les solutions apportées pour les résoudre. Il a pour objectif de servir de référence et d’éviter que ces difficultés ne se reproduisent à l’avenir.

## Problèmes et Solutions

### Problème 1 : Conserver la session de l’utilisateur après la fermeture de l’application ou le déplacement vers une autre page
**Date** : 07/11/2024  
**Contexte** : L’utilisateur doit actuellement se reconnecter à chaque fois qu’il ferme l’application ou change de page.  
**Statut** : Résolu &#x2705;

#### Solution
- Utiliser **SharedPreferences** pour stocker les informations nécessaires à l’authentification, **sans y inclure le mot de passe** (pour des raisons de sécurité). Cela permet de maintenir la session de l’utilisateur.

#### Remarques
- Veiller à nommer les variables de manière cohérente pour éviter les erreurs.  
- Ne jamais stocker de mot de passe en clair.

---

### Problème 2 : Séparer les unités de mesure des données dans la base de données
**Date** : 23/11/2024  
**Contexte** : Les données sont stockées dans la base de données avec des unités de mesure prédéfinies (ex. : 10 km/h, 20 °C, 1000 hPa), sans possibilité de modification a posteriori.  
**Statut** : Résolu &#x2705;

#### Solution
- Créer une table dédiée aux unités de mesure et une autre pour les données.  
- Dans la table des données, stocker uniquement la valeur brute (sans unité).  
- Dans la table des unités, gérer la correspondance entre une donnée et son unité de mesure.

#### Remarques
- Mettre à jour la valeur de la mesure ou l’unité de mesure de manière cohérente lorsqu’un changement survient.  

---

### Problème 3 : Envoi de notifications à l’utilisateur
**Date** : 20/01/2025  
**Contexte** : L’utilisateur doit être notifié lorsqu’une donnée dépasse ses limites configurées.  
**Statut** : Résolu &#x2705;

#### Solution
- Utiliser le service de notification **Firebase** pour envoyer des notifications en temps réel à l’utilisateur.

#### Remarques
- Bien configurer le service de notification (permissions, token de l’utilisateur, etc.) pour éviter tout dysfonctionnement.

---

### Problème 4 : Sécuriser les données de l’utilisateur
**Date** : 08/02/2025  
**Contexte** : Les données de l’utilisateur sont actuellement stockées en clair dans **SharedPreferences**, ce qui pose un problème de sécurité.  
**Statut** : Non commencé &#x274C;

#### Solution
- Utiliser **flutter_secure_storage** pour stocker de manière chiffrée les informations sensibles de l’utilisateur.

#### Remarques
- Ne pas stocker le mot de passe de l’utilisateur, même dans un stockage sécurisé, si cela peut être évité. Utiliser plutôt des jetons d’authentification.

---

### Problème 5 : Mauvais paramétrage de l’inscription de l’utilisateur (unités de mesure et données météorologiques)
**Date** : 06/12/2024  
**Contexte** : Lors de l’inscription, l’utilisateur ajoute ses données météorologiques préférées avec des unités de mesure basiques. Cependant, la table recensant les unités de mesure préférées de l’utilisateur enregistre les préférences au moment de l’inscription, créant une incohérence entre les tables lorsque l’utilisateur effectue des modifications ultérieures.  
**Statut** : Résolu &#x2705;

#### Solution
- Récupérer les unités préférées depuis le **Provider** pour garantir la cohérence et la mise à jour des préférences de l’utilisateur.

#### Remarques
- Mettre à jour les unités de mesure préférées lorsqu’elles sont modifiées par l’utilisateur.

---

### Problème 6 : Les préférences de l’utilisateur ne sont pas actualisées lors de la modification des unités de mesure
**Date** : 25/12/2024  
**Contexte** : Lorsqu’un utilisateur modifie ses unités de mesure dans les paramètres, les données associées à ses préférences ne sont pas mises à jour.  
**Statut** : Résolu &#x2705;

#### Solution
- Créer une fonction de mise à jour des préférences de l’utilisateur qui sera appelée dès que ce dernier modifie ses unités de mesure.

#### Remarques
- Il est primordial de gérer la cohérence entre la modification des unités et la base de données, afin que ces changements soient effectivement pris en compte.

---

## Conclusion
Ce document recense les problèmes rencontrés ainsi que les solutions apportées ou envisagées. Il constitue un référentiel pour capitaliser sur les expériences passées et éviter de reproduire les mêmes erreurs. Les mises à jour régulières de ce document sont fortement recommandées afin de maintenir une documentation fiable et à jour.

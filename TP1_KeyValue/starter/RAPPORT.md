# RAPPORT — TP1 Redis

## 1. Comparaison de performance

### Cache MISS
- Le système interroge PostgreSQL.
- Temps de réponse plus lent (~2 secondes).
- Les données sont ensuite stockées dans Redis.

### Cache HIT
- Les données sont récupérées directement depuis Redis.
- Temps de réponse très rapide (< 1 ms).
- Réduction importante de charge sur PostgreSQL.

---

## 2. Justification des choix de modélisation

### String
Utilisé pour :
- Sessions utilisateur
- Stock produit
- Cache simple

Car les Strings sont rapides et simples.

### Hash
Utilisé pour :
- Produits
- Paniers

Car les Hash permettent de stocker plusieurs attributs dans une seule clé.

### List
Utilisé pour :
- Historique de navigation

Car les Lists conservent l'ordre des éléments.

### Set
Utilisé pour :
- Produits par catégorie

Car les Sets évitent les doublons.

### Sorted Set
Utilisé pour :
- Classement des ventes

Car les Sorted Sets permettent le tri par score.

---

## 3. Réponses aux questions de réflexion

### Que se passe-t-il si Redis redémarre ?

Les données en mémoire peuvent être perdues si la persistance n'est pas activée.
Pour éviter cela, Redis propose :
- RDB snapshots
- AOF (Append Only File)

---

### Comment gérer la cohérence cache/DB en cas d'accès concurrent ?

Solutions possibles :
- Utiliser des transactions Redis
- Invalider le cache après mise à jour DB
- Employer le pattern Write-Through ou Write-Behind
- Utiliser WATCH/MULTI/EXEC

---

### Quand un TTL trop court est-il problématique ?

Un TTL trop court provoque :
- Beaucoup de cache miss
- Plus de requêtes PostgreSQL
- Dégradation des performances
- Augmentation de charge serveur

---

## Bonus — Rate Limiting

Exemple : limiter un utilisateur à 100 requêtes/minute.

Commande Redis :

```python
r.incr(user_key)
r.expire(user_key, 60)

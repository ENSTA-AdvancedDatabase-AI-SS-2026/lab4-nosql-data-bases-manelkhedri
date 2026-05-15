# RAPPORT — TP2 MongoDB

## 1. Justification : Embedding vs Referencing

### Consultations → EMBEDDING

Les consultations ont été stockées directement dans le document patient car :

- Elles sont fréquemment consultées avec le dossier patient.
- Cela réduit les JOINs et améliore les performances.
- Un seul accès MongoDB permet d'obtenir tout l'historique médical.

Avantage :
- Lecture rapide.
- Modèle simple.

Inconvénient :
- Le document peut devenir volumineux.

---

### Analyses → REFERENCING

Les analyses ont été séparées dans une collection dédiée car :

- Leur volume peut devenir très important.
- Les résultats varient selon le type d'analyse.
- Certaines analyses sont consultées indépendamment.

Avantage :
- Documents patients plus légers.
- Meilleure scalabilité.

Inconvénient :
- Nécessite des opérations $lookup.

---

## 2. Résultats explain() avant/après indexation

| Requête | Sans index | Avec index |
|---|---|---|
| Recherche diabétiques Alger | totalDocsExamined élevé | exécution rapide |
| Recherche textuelle diagnostic | scan complet | utilisation index text |
| Lookup analyses | plus lent | amélioration grâce index patient_id |

### Observation

Les index réduisent fortement :

- totalDocsExamined
- executionTimeMillis

MongoDB utilise directement les structures indexées au lieu de scanner toute la collection.

---

## 3. Requête la plus complexe : statistiques croisées

Pipeline utilisé :

### Étape 1 — $lookup

Jointure entre :
- analyses
- patients

pour récupérer la wilaya du patient.

---

### Étape 2 — $unwind

Transformation du tableau patient en document simple.

---

### Étape 3 — $group

Regroupement par wilaya.

Calcul :
- nombre total d'analyses
- nombre d'analyses anormales

---

### Étape 4 — $project

Calcul du taux d'analyses anormales :

(anormales / total) × 100

---

### Étape 5 — $sort

Tri décroissant des wilayas avec le plus grand taux d'anomalies.

---

## Conclusion

MongoDB est adapté aux dossiers médicaux complexes grâce :

- au modèle documentaire flexible
- aux pipelines d'agrégation puissants
- aux index optimisant les performances
- à la possibilité de mélanger embedding et referencing

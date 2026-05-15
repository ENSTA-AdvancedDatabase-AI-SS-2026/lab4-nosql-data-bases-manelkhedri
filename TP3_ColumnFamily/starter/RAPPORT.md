# RAPPORT — TP3 Cassandra

## 1. Justification des Partition Keys

### Table mesures_par_capteur

Partition Key :

(capteur_id, date)

Pourquoi ?

- Répartition uniforme des données entre les nœuds.
- Évite les hot partitions.
- Les requêtes ciblent souvent un capteur sur une période.

Clustering Key :

timestamp DESC

Permet :

- récupération rapide des dernières mesures
- tri naturel chronologique

---

### Table alertes_par_wilaya

Partition Key :

(wilaya, date)

Pourquoi ?

- Les alertes sont souvent consultées par wilaya et journée.
- Répartition équilibrée des partitions.

---

### Table agregats_horaires

Partition Key :

(wilaya, date)

Pourquoi ?

- Optimisée pour dashboards temps réel.
- Lecture rapide des agrégats horaires.

---

## 2. Pourquoi ALLOW FILTERING est dangereux

ALLOW FILTERING oblige Cassandra à scanner un grand nombre de partitions.

Conséquences :

- forte consommation CPU
- latence élevée
- surcharge cluster
- performances imprévisibles

En production, cela devient très coûteux sur des millions de lignes.

Bonne pratique :

Créer une table adaptée à chaque requête fréquente.

---

## 3. Comparaison TWCS vs STCS vs LCS

| Stratégie | Usage | Avantages | Inconvénients |
|---|---|---|---|
| TWCS | Séries temporelles | Optimisé TTL et données temporelles | Peu adapté données aléatoires |
| STCS | Écriture intensive | Simple et performant en write | Lecture moins optimisée |
| LCS | Lectures fréquentes | Très rapide pour lecture | Compaction coûteuse |

---

### TWCS (TimeWindowCompactionStrategy)

Utilisé pour :

- logs
- IoT
- monitoring
- séries temporelles

Avantage principal :

Les données anciennes sont compactées ensemble puis expirent efficacement avec TTL.

---

### STCS (SizeTieredCompactionStrategy)

Utilisé pour :

- workloads majoritairement écriture
- données générales

Fonctionnement :

Fusionne les SSTables de taille similaire.

---

### LCS (LeveledCompactionStrategy)

Utilisé pour :

- applications orientées lecture
- requêtes nécessitant faible latence

Fonctionnement :

Organisation en niveaux pour réduire le nombre de SSTables lues.

---

## Conclusion

Cassandra est particulièrement adapté aux données IoT massives grâce :

- à sa scalabilité horizontale
- à son débit d'écriture très élevé
- aux modèles optimisés par requête
- aux TTL intégrés
- aux stratégies de compaction adaptées aux séries temporelles

USE smartgrid;

-- ==========================================
-- 3.1 Mesures capteur sur dernières 6 heures
-- ==========================================

SELECT *
FROM mesures_par_capteur
WHERE capteur_id = 123e4567-e89b-12d3-a456-426614174000
AND date = '2026-05-15'
AND timestamp >= '2026-05-15 12:00:00';


-- ==========================================
-- 3.2 Dernière mesure de chaque capteur
-- ==========================================

SELECT *
FROM mesures_par_capteur
WHERE wilaya = 'Alger'
AND date = '2026-05-15'
LIMIT 1;


-- ==========================================
-- 3.3 Capteurs en alerte à Alger
-- ==========================================

SELECT *
FROM alertes_par_wilaya
WHERE wilaya = 'Alger'
AND date = '2026-05-15';


-- Compter les alertes

SELECT COUNT(*)
FROM alertes_par_wilaya
WHERE wilaya = 'Alger'
AND date = '2026-05-15';


-- ==========================================
-- 3.4 Consommation totale par heure
-- ==========================================

SELECT heure,
       consommation_totale
FROM agregats_horaires
WHERE wilaya = 'Alger'
AND date = '2026-05-15';


-- ==========================================
-- 3.5 Détection anomalies tension
-- ==========================================

SELECT *
FROM mesures_par_capteur
WHERE capteur_id = 123e4567-e89b-12d3-a456-426614174000
AND date = '2026-05-15'
AND timestamp >= '2026-05-15 17:30:00'
AND (tension < 200 OR tension > 240)
ALLOW FILTERING;


-- ==========================================
-- 3.6 Top 10 capteurs les plus actifs
-- ==========================================

SELECT capteur_id,
       nb_mesures
FROM statistiques_capteurs
WHERE semaine = '2026-W20'
LIMIT 10;


-- ==========================================
-- 3.7 Pourquoi éviter ALLOW FILTERING
-- ==========================================

-- Mauvaise requête

SELECT *
FROM mesures_par_capteur
WHERE tension > 240
ALLOW FILTERING;


-- Problème :
-- Cassandra doit scanner toutes les partitions.
-- Très coûteux en production.


-- Bonne solution :
-- créer une table dédiée

CREATE TABLE mesures_anormales (
    date DATE,
    capteur_id UUID,
    timestamp TIMESTAMP,
    tension FLOAT,
    wilaya TEXT,
    PRIMARY KEY ((date), timestamp, capteur_id)
)
WITH CLUSTERING ORDER BY (timestamp DESC);


-- Requête optimisée

SELECT *
FROM mesures_anormales
WHERE date = '2026-05-15';

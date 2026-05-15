USE smartgrid;

-- ==========================================
-- 4.1 Stratégies de compaction
-- ==========================================

-- mesures_par_capteur
-- TWCS : idéal pour séries temporelles

-- alertes_par_wilaya
-- TWCS : données temporelles avec expiration

-- agregats_horaires
-- STCS : données moins volumineuses


-- ==========================================
-- 4.2 Configuration TWCS
-- ==========================================

ALTER TABLE mesures_par_capteur
WITH compaction = {
    'class': 'TimeWindowCompactionStrategy',
    'compaction_window_unit': 'DAYS',
    'compaction_window_size': '1'
};


-- ==========================================
-- 4.3 Vérifier les TTL
-- ==========================================

SELECT capteur_id,
       TTL(tension)
FROM mesures_par_capteur
WHERE capteur_id = 123e4567-e89b-12d3-a456-426614174000
AND date = '2026-05-15'
LIMIT 10;


-- Vérifier lignes expirant dans 7 jours

SELECT capteur_id,
       TTL(tension)
FROM mesures_par_capteur
WHERE capteur_id = 123e4567-e89b-12d3-a456-426614174000
AND date = '2026-05-15';


-- ==========================================
-- 4.4 Détection hot partition
-- ==========================================

-- Symptômes :
-- Une partition devient trop grande.
-- Latence élevée.
-- Un seul nœud surchargé.


-- Détection via :

nodetool tablestats smartgrid.mesures_par_capteur


-- Correction :

-- Ajouter davantage de granularité
-- Exemple : partition par heure au lieu de journée

CREATE TABLE mesures_par_capteur_v2 (
    capteur_id UUID,
    date DATE,
    heure INT,
    timestamp TIMESTAMP,
    tension FLOAT,
    courant FLOAT,
    puissance FLOAT,
    wilaya TEXT,
    PRIMARY KEY ((capteur_id, date, heure), timestamp)
)
WITH CLUSTERING ORDER BY (timestamp DESC);

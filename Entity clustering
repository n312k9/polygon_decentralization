-- entity_clustering.sql
-- Implements Algorithm 2 (Sec 3.4): entity-adjusted Nakamoto coefficients
-- Groups consecutive validators as co-controlled candidates if
--   |id(vi) - id(vj)| <= delta_id  AND  |si - sj| <= delta_s
-- Baseline: delta_id = 5, delta_s = 1,000 POL
-- Sensitivity grid: delta_id in {3,5,10} x delta_s in {500,1000,5000} -> Table 2

WITH active_set AS (
    -- pull from active_validator_set.sql result, sorted ascending by validatorId
    SELECT validatorId, stake_pol
    FROM query_8272036   -- active_validator_set.sql (https://dune.com/queries/8272036)
    ORDER BY validatorId
),
params AS (
    -- edit these two values to sweep the 9 threshold configurations
    SELECT 5 AS delta_id, 1000 AS delta_s
),
pairwise AS (
    SELECT
        a.validatorId,
        a.stake_pol,
        LAG(a.validatorId) OVER (ORDER BY a.validatorId) AS prev_id,
        LAG(a.stake_pol)   OVER (ORDER BY a.validatorId) AS prev_stake
    FROM active_set a
),
anchors AS (
    SELECT
        p.validatorId,
        p.stake_pol,
        CASE
            WHEN p.prev_id IS NOT NULL
                 AND (p.validatorId - p.prev_id) <= (SELECT delta_id FROM params)
                 AND ABS(p.stake_pol - p.prev_stake) <= (SELECT delta_s FROM params)
            THEN 1 ELSE 0
        END AS clustered_with_prev
    FROM pairwise p
)
-- Entity grouping: co-controlled pairs flagged for manual/recursive anchor resolution
SELECT
    validatorId,
    stake_pol,
    clustered_with_prev
FROM anchors
ORDER BY validatorId

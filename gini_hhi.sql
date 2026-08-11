-- gini_hhi.sql
-- Computes Gini coefficient (Eq. 4) and HHI (Eq. 5) from the study-end active set
-- Output feeds Table 1 (G = 0.8156, HHI = 557.2) and Figure 1(a) Lorenz curve

WITH active_set AS (
    SELECT validatorId, stake_pol
    FROM query_8272036        -- active_validator_set.sql (https://dune.com/queries/8272036)
),
totals AS (
    SELECT SUM(stake_pol) AS total_stake, COUNT(*) AS m
    FROM active_set
),
ranked AS (
    -- ascending rank for Gini's order statistic s(i)
    SELECT
        validatorId,
        stake_pol,
        ROW_NUMBER() OVER (ORDER BY stake_pol ASC) AS i
    FROM active_set
),
gini_terms AS (
    SELECT
        r.i,
        r.stake_pol,
        t.m,
        t.total_stake,
        (t.m - r.i + 0.5) * r.stake_pol AS weighted_term
    FROM ranked r
    CROSS JOIN totals t
),
gini_agg AS (
    -- MAX() wraps m/total_stake so every column in the select list is an
    -- aggregate expression -- Trino requires this even though totals has
    -- exactly one row per join
    SELECT
        1 - (2.0 / (MAX(m) * MAX(total_stake))) * SUM(weighted_term) AS gini_coefficient
    FROM gini_terms
),
hhi_terms AS (
    SELECT
        validatorId,
        stake_pol,
        POWER(stake_pol / t.total_stake, 2) * 10000 AS w_sq
    FROM active_set
    CROSS JOIN totals t
),
hhi_agg AS (
    SELECT SUM(w_sq) AS hhi
    FROM hhi_terms
)
SELECT
    g.gini_coefficient,
    h.hhi,
    t.m           AS validator_count,
    t.total_stake AS total_staked_pol
FROM gini_agg g
CROSS JOIN hhi_agg h
CROSS JOIN totals t

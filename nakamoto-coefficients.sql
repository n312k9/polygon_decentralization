-- nakamoto_coefficients.sql
-- Computes N_L (theta = 1/3, liveness) and N_S (theta = 2/3, safety) via running sum
-- Eq. 3. Output feeds Table 1 (N_L = 4, N_S = 11) and Figure 1(b) top-k cumulative control

WITH active_set AS (
    SELECT validatorId, stake_pol
    FROM query_8272036        -- active_validator_set.sql (https://dune.com/queries/8272036)
),
totals AS (
    SELECT SUM(stake_pol) AS total_stake FROM active_set
),
ranked AS (
    SELECT
        validatorId,
        stake_pol,
        ROW_NUMBER() OVER (ORDER BY stake_pol DESC) AS k,
        SUM(stake_pol) OVER (ORDER BY stake_pol DESC
                              ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS cum_stake
    FROM active_set
)
SELECT
    r.k,
    r.validatorId,
    r.stake_pol,
    r.cum_stake,
    r.cum_stake / t.total_stake AS cum_share,
    CASE WHEN r.cum_stake / t.total_stake >= 1.0/3 THEN true ELSE false END AS crosses_liveness_third,
    CASE WHEN r.cum_stake / t.total_stake >= 2.0/3 THEN true ELSE false END AS crosses_safety_two_thirds
FROM ranked r
CROSS JOIN totals t
ORDER BY r.k

-- N_L = MIN(k) WHERE crosses_liveness_third = true
-- N_S = MIN(k) WHERE crosses_safety_two_thirds = true

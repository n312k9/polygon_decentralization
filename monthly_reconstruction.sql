-- monthly_reconstruction.sql
-- Implements Sec 3.5: reapplies Algorithm 1 at each of 72 month-end boundaries
-- (June 2020 - May 2026) to produce the longitudinal N_L / N_S series -> Table 3, Figure 2

WITH month_ends AS (
    SELECT
        CAST(d AS DATE) AS month_end
    FROM UNNEST(
        SEQUENCE(
            DATE '2020-06-30',
            DATE '2026-05-31',
            INTERVAL '1' MONTH
        )
    ) AS t(d)
),
stake_events AS (
    SELECT
        validatorId,
        newAmount / 1e18 AS stake_pol,
        evt_block_time
    FROM polygon_validator_contract_2_ethereum.StakingInfo_evt_StakeUpdate
),
exited AS (
    SELECT validatorId, evt_block_time AS exit_time
    FROM polygon_validator_contract_2_ethereum.StakingInfo_evt_UnstakeInit
),
snapshot AS (
    -- for each month boundary, latest stake per validator as of that boundary
    SELECT
        me.month_end,
        se.validatorId,
        se.stake_pol,
        ROW_NUMBER() OVER (
            PARTITION BY me.month_end, se.validatorId
            ORDER BY se.evt_block_time DESC
        ) AS rn
    FROM month_ends me
    JOIN stake_events se
        ON se.evt_block_time <= CAST(me.month_end AS TIMESTAMP)
),
active_snapshot AS (
    SELECT
        s.month_end,
        s.validatorId,
        s.stake_pol
    FROM snapshot s
    LEFT JOIN exited ex
        ON s.validatorId = ex.validatorId
        AND ex.exit_time <= CAST(s.month_end AS TIMESTAMP)
    WHERE s.rn = 1
      AND ex.validatorId IS NULL
      AND s.stake_pol >= 1000
)
SELECT
    month_end,
    validatorId,
    stake_pol
FROM active_snapshot
ORDER BY month_end, stake_pol DESC

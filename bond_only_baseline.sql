-- bond_only_baseline.sql
-- Legacy/prior-study method using Staked.total (own bond only, excludes delegations)
-- Used in Sec 3.2 / 4.1 to demonstrate the 2.28x average undercount vs StakeUpdate.newAmount
-- Mirrors active_validator_set.sql logic but sourced from the Staked event instead

WITH latest_bond AS (
    SELECT
        validatorId,
        total / 1e18 AS bond_pol,      -- Staked.total field, own bond only
        evt_block_time,
        ROW_NUMBER() OVER (
            PARTITION BY validatorId
            ORDER BY evt_block_time DESC
        ) AS rn
    FROM polygon_validator_contract_2_ethereum.StakingInfo_evt_Staked
    WHERE evt_block_time >= TIMESTAMP '2020-05-30 00:00:00'
      AND evt_block_time <  TIMESTAMP '2026-05-30 00:00:00'
),
exited AS (
    SELECT DISTINCT validatorId
    FROM polygon_validator_contract_2_ethereum.StakingInfo_evt_UnstakeInit
    WHERE evt_block_time < TIMESTAMP '2026-05-30 00:00:00'
)
SELECT
    lb.validatorId,
    lb.bond_pol,
    lb.evt_block_time AS last_update
FROM latest_bond lb
LEFT JOIN exited ex ON lb.validatorId = ex.validatorId
WHERE lb.rn = 1
  AND ex.validatorId IS NULL
  AND lb.bond_pol >= 1000
ORDER BY lb.bond_pol DESC

-- Compare AVG(bond_pol) and MAX(bond_pol) here against
-- AVG(stake_pol) and MAX(stake_pol) in active_validator_set.sql
-- Paper reports: bond-only mean 15.2M / max 23.5M POL
-- delegation-inclusive mean 34.9M / max 411.5M POL (17.5x on largest validator)

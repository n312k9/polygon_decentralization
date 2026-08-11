-- delegation_flows.sql
-- Source: polygon_validator_contract_2_ethereum.StakingInfo_evt_ShareMinted / ShareBurned
-- Purpose: net delegation flow per validator (delegated in - undelegated out)
-- Supports Sec 3.2's delegation-inclusive framing; verified working query.

WITH
delegations_in AS (
    SELECT
        CAST(validatorId AS BIGINT)          AS validator_id,
        SUM(CAST(amount AS DOUBLE)) / 1e18   AS delegated_pol
    FROM polygon_validator_contract_2_ethereum.StakingInfo_evt_ShareMinted
    WHERE evt_block_time >= TIMESTAMP '2020-05-30'
      AND evt_block_time <  TIMESTAMP '2026-05-30'
    GROUP BY CAST(validatorId AS BIGINT)
),
delegations_out AS (
    SELECT
        CAST(validatorId AS BIGINT)          AS validator_id,
        SUM(CAST(amount AS DOUBLE)) / 1e18   AS undelegated_pol
    FROM polygon_validator_contract_2_ethereum.StakingInfo_evt_ShareBurned
    WHERE evt_block_time >= TIMESTAMP '2020-05-30'
      AND evt_block_time <  TIMESTAMP '2026-05-30'
    GROUP BY CAST(validatorId AS BIGINT)
)
SELECT
    COALESCE(i.validator_id, o.validator_id)           AS validator_id,
    COALESCE(i.delegated_pol, 0)                       AS total_delegated_in,
    COALESCE(o.undelegated_pol, 0)                     AS total_delegated_out,
    COALESCE(i.delegated_pol, 0)
    - COALESCE(o.undelegated_pol, 0)                   AS net_delegated_pol
FROM delegations_in  i
FULL OUTER JOIN delegations_out o
    ON i.validator_id = o.validator_id
ORDER BY net_delegated_pol DESC

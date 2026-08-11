-- stakeupdate.sql
-- Source: polygon_validator_contract_2_ethereum.StakingInfo_evt_StakeUpdate
-- Purpose: authoritative source of delegation-inclusive voting power (Sec 3.2)
-- Fires at every Heimdall checkpoint; newAmount = own bond + all accumulated delegations


SELECT
    CAST(validatorId AS BIGINT) AS validator_id,
    CAST(newAmount AS DOUBLE) / 1e18 AS stake_pol,
    evt_block_time,
    evt_block_number,
    evt_tx_hash
FROM polygon_validator_contract_2_ethereum.StakingInfo_evt_StakeUpdate
WHERE evt_block_time >= TIMESTAMP '2020-05-30 00:00:00'
  AND evt_block_time <  TIMESTAMP '2026-05-30 00:00:00'
ORDER BY validatorId, evt_block_time;

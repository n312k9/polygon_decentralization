-- unstakeinit.sql
-- Source: stakinginfo_evt_unstakeinit
-- Purpose: identifies exited validator set X, used to filter Algorithm 1 (Sec 3.3)

SELECT
    validatorId,
    amount,
    deactivationEpoch,
    evt_block_time,
    evt_block_number,
    evt_tx_hash
FROM polygon_validator_contract_2_ethereum.StakingInfo_evt_UnstakeInit
WHERE evt_block_time >= TIMESTAMP '2020-05-30 00:00:00'
  AND evt_block_time <  TIMESTAMP '2026-05-30 00:00:00'
ORDER BY validatorId, evt_block_time;

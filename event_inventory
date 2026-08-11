-- event_inventory.sql
-- Source: ethereum.logs, filtered to the StakingInfo contract
-- Purpose: inventory and classify every event topic0 emitted by the contract;
-- resolves topic0 hashes to named events (Staked, UnstakeInit, ShareMinted,
-- ShareBurned, Jailed, UnJailed) and tags each by security layer.
-- Verified working query; also supports Sec 4.4's jailing/accountability discussion.

WITH
all_events AS (
    SELECT
        topic0,
        COUNT(*)                                           AS event_count,
        MIN(block_time)                                    AS first_occurrence,
        MAX(block_time)                                     AS last_occurrence,
        COUNT(DISTINCT DATE_TRUNC('year', block_time))      AS years_active,
        SUM(
            CASE
                WHEN block_time < TIMESTAMP '2022-01-01'
                THEN 1 ELSE 0
            END
        )                                                   AS count_pre_2022,
        SUM(
            CASE
                WHEN block_time >= TIMESTAMP '2022-01-01'
                 AND block_time <  TIMESTAMP '2024-01-01'
                THEN 1 ELSE 0
            END
        )                                                   AS count_2022_2023,
        SUM(
            CASE
                WHEN block_time >= TIMESTAMP '2024-01-01'
                THEN 1 ELSE 0
            END
        )                                                   AS count_post_2024
    FROM ethereum.logs
    WHERE contract_address = 0xa59c847bd5ac0172ff4fe912c5d29e5a71a7512b
      AND block_time >= TIMESTAMP '2020-05-30'
      AND block_time <  TIMESTAMP '2026-05-30'
    GROUP BY topic0
),
classified AS (
    SELECT
        topic0,
        event_count,
        first_occurrence,
        last_occurrence,
        years_active,
        count_pre_2022,
        count_2022_2023,
        count_post_2024,
        CASE LOWER(CAST(topic0 AS VARCHAR))
            WHEN '0x1f6f3657d20c26bb92c83bf3b67ee26e1fa67048c58a2d7a7bfd34ba14db7ae4'
                THEN 'Jailed (N_L enforcement)'
            WHEN '0x6ae13773d88ac77a6d3e840a0c6e9a9c9ecf4e9ab3046e0a7e5d56b56d2f0c8'
                THEN 'UnJailed (liveness restored)'
            WHEN '0x35af9eea1f0e7b300b0a14fae90139a072470e44daa3f14b5069bebbc1265bda'
                THEN 'Staked (validator own stake)'
            WHEN '0x31d1715032654fde9867c0f095aecce1113049e30b9f4ecbaa6954ed6c63b8df'
                THEN 'UnstakeInit (validator exiting)'
            WHEN '0x0f9ccdda16b467e719059c85ebd8383fcb7f8ffa5576629fe3b842836e04dad1'
                THEN 'ShareMinted (delegation in)'
            WHEN '0xc9afff0972d33d68c8d330fe0ebd0e9f54491ad8c59ae17330a9206f280f086'
                THEN 'ShareBurned (delegation out)'
            ELSE 'Unclassified — verify manually'
        END                                                 AS event_type,
        CASE LOWER(CAST(topic0 AS VARCHAR))
            WHEN '0x1f6f3657d20c26bb92c83bf3b67ee26e1fa67048c58a2d7a7bfd34ba14db7ae4'
                THEN 'N_L — liveness accountability'
            WHEN '0x6ae13773d88ac77a6d3e840a0c6e9a9c9ecf4e9ab3046e0a7e5d56b56d2f0c8'
                THEN 'N_L — liveness restored'
            WHEN '0x35af9eea1f0e7b300b0a14fae90139a072470e44daa3f14b5069bebbc1265bda'
                THEN 'Staking layer'
            WHEN '0x31d1715032654fde9867c0f095aecce1113049e30b9f4ecbaa6954ed6c63b8df'
                THEN 'Staking layer'
            WHEN '0x0f9ccdda16b467e719059c85ebd8383fcb7f8ffa5576629fe3b842836e04dad1'
                THEN 'Delegation layer — required for Q1–Q3'
            WHEN '0xc9afff0972d33d68c8d330fe0ebd0e9f54491ad8c59ae17330a9206f280f086'
                THEN 'Delegation layer — required for Q1–Q3'
            ELSE 'Unknown'
        END                                                 AS security_layer
    FROM all_events
)
SELECT
    LOWER(CAST(topic0 AS VARCHAR))                       AS topic0,
    event_type,
    security_layer,
    event_count,
    first_occurrence,
    last_occurrence,
    years_active,
    count_pre_2022,
    count_2022_2023,
    count_post_2024
FROM classified
ORDER BY event_count ASC

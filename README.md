# Delegation-Inclusive Longitudinal Decentralization Audit of Polygon PoS

Reproducibility package for:

> Kandwal, N., Agarwal, K., Upadhyay, D. "Delegation-inclusive longitudinal measurement of Polygon PoS decentralization." 

Data source: Polygon `StakingInfo` contract (`0xa59c847bd5ac0172ff4fe912c5d29e5a71a7512b`, Ethereum mainnet), accessed via Dune Analytics. This repo contains the Dune queries used and their exported result sets, supporting full reproducibility of every number, table, and figure in the paper.

**Confirmed Dune schema:** `polygon_validator_contract_2_ethereum` — verified against working queries. (`staking_polygon` and `polygon_validator_contract_2` without the `_ethereum` suffix do not exist and will fail.)

---

## Headline Findings

| Metric | Value |
|---|---|
| Gini coefficient | 0.8156 |
| HHI | 557.2 |
| N_L (liveness, θ=1/3) | 4 |
| N_S (safety, θ=2/3) | 11 |
| Active validators \|V\| | 103 |
| Total staked S | 3,627.96M POL |
| Largest validator stake | 411,533,181 POL (11.34% of total) |
| Bond-only mean / max (legacy method) | 15.13M / 23.50M POL |
| Delegation-inclusive undercount ratio (largest validator) | 17.5x |
| Entity clustering (baseline delta_id=5, delta_s=1,000) | 1 co-controlled candidate pair (validators 204/201, both ~100K POL, near the stake floor); no effect on N_L or N_S |
| Longest continuous N_L=4 plateau | 35 consecutive months, Aug 2022-Jun 2025, interrupted by a 2-month regression to N_L=3 in Jun-Jul 2022 |
| Historic minimum | N_L=1, March-April 2021 (single validator held unilateral liveness veto) |
| Transient peak | N_L=5, July-September 2025, reverting to 4 in October 2025 |

Full monthly trajectory (72 months, June 2020-May 2026) is in `results/monthly_nakamoto.csv`; the phase breakdown is derived directly from that series with no manual boundary-drawing.

---

## Verification Status - All Queries Locked

| File | Status |
|---|---|
| `stakeupdate.sql` | Locked - ran successfully, results verified |
| `unstakeinit.sql` | Locked - ran successfully, results verified |
| `active_validator_set.sql` | Locked - \|V\|=103, S=3,627.96M POL confirmed |
| `bond_only_baseline.sql` | Locked - mean 15.13M / max 23.50M POL |
| `delegation_flows.sql` | Locked - ShareMinted/ShareBurned net delegation per validator |
| `event_inventory.sql` | Locked - topic0 -> event classification |
| `entity_clustering.sql` | Locked - baseline config run; 1 pair detected |
| `gini_hhi.sql` | Locked - Gini=0.8156, HHI=557.2 |
| `nakamoto_coefficients.sql` | Locked - N_L=4 (35.96%), N_S=11 (70.07%) |
| `monthly_reconstruction.sql` | Locked - 6,665 raw per-validator, per-month rows (72 months x ~93 validators avg) |
| `monthly_nakamoto_summary.sql` | Locked - aggregates `monthly_reconstruction.sql` into 72 monthly N_L/N_S rows |

---

## Folder Structure

```
.
├── README.md
├── queries/
│   ├── stakeupdate.sql
│   ├── unstakeinit.sql
│   ├── active_validator_set.sql
│   ├── bond_only_baseline.sql
│   ├── delegation_flows.sql
│   ├── event_inventory.sql
│   ├── entity_clustering.sql
│   ├── gini_hhi.sql
│   ├── nakamoto_coefficients.sql
│   ├── monthly_reconstruction.sql
│   └── monthly_nakamoto_summary.sql
```

---

## Mapping: Paper Location -> Query File

| Paper location | Query file |
|---|---|
| Sec 3.2, delegation-inclusive method | `stakeupdate.sql` |
| Sec 3.2, delegation flow detail | `delegation_flows.sql` |
| Sec 3.2, bond-only comparison | `bond_only_baseline.sql` |
| Sec 3.3, Algorithm 1 | `active_validator_set.sql` |
| Sec 3.4, Algorithm 2 / Table 2 | `entity_clustering.sql` |
| Sec 3.5, Table 3, Figure 2 | `monthly_reconstruction.sql` -> `monthly_nakamoto_summary.sql` |
| Table 1 (Gini, HHI) | `gini_hhi.sql` |
| Figure 1(a) (Lorenz curve) | `gini_hhi.sql` + `active_validator_set.sql` |
| Figure 1(b) (N_L, N_S top-k) | `nakamoto_coefficients.sql` |
| Sec 4.4, jailing/accountability discussion | `event_inventory.sql` |

---

## Known Event Topic0 Hashes (from `event_inventory.sql`)

| Topic0 | Event |
|---|---|
| `0x1f6f3657d20c26bb92c83bf3b67ee26e1fa67048c58a2d7a7bfd34ba14db7ae4` | Jailed (N_L enforcement) |
| `0x6ae13773d88ac77a6d3e840a0c6e9a9c9ecf4e9ab3046e0a7e5d56b56d2f0c8` | UnJailed (liveness restored) |
| `0x35af9eea1f0e7b300b0a14fae90139a072470e44daa3f14b5069bebbc1265bda` | Staked (validator own stake) |
| `0x31d1715032654fde9867c0f095aecce1113049e30b9f4ecbaa6954ed6c63b8df` | UnstakeInit (validator exiting) |
| `0x0f9ccdda16b467e719059c85ebd8383fcb7f8ffa5576629fe3b842836e04dad1` | ShareMinted (delegation in) |
| `0xc9afff0972d33d68c8d330fe0ebd0e9f54491ad8c59ae17330a9206f280f086` | ShareBurned (delegation out) |

`StakeUpdate`'s topic0 wasn't classified in the recovered `event_inventory.sql` run - worth confirming its hash the same way if you re-run that query, as a sanity check that `stakeupdate.sql` is pointed at the right event.

---

## To-Do Before Submission

- [ ] Re-run `entity_clustering.sql` across the other 8 delta_id/delta_s sensitivity configurations (only baseline delta_id=5, delta_s=1,000 has been verified so far).
- [ ] Export and commit `results/*.csv` for each query, matching filenames.
- [ ] Save each query's public Dune URL somewhere durable (e.g. as a header comment in each `.sql` file) in case query IDs are regenerated.
- [ ] Replace `[REPOSITORY URL]` in the manuscript (Section 3.1 and the Data Availability statement) with this repo's public URL.

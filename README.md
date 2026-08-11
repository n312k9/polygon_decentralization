# Delegation-Inclusive Longitudinal Decentralization Audit of Polygon PoS

Reproducibility package for:

> Kandwal, N., Agarwal, K., Upadhyay, D. "Delegation-inclusive longitudinal measurement of Polygon PoS decentralization."

Data source: Polygon `StakingInfo` contract (`0xa59c847bd5ac0172ff4fe912c5d29e5a71a7512b`, Ethereum mainnet), accessed via Dune Analytics. This repo contains the Dune queries used and their exported result sets.

---

## Folder Structure

```
.
├── README.md
├── queries/
│   ├── stakeupdate.sql              # stakinginfo_evt_stakeupdate — delegation-inclusive stake source (Sec 3.2)
│   ├── unstakeinit.sql              # stakinginfo_evt_unstakeinit — exited validator set
│   ├── active_validator_set.sql     # Algorithm 1 — active set, |V|=103, S=3,627.96M POL (Table 1)
│   ├── entity_clustering.sql        # Algorithm 2 — entity clustering, 9 Δid/Δs configs (Table 2)
│   ├── monthly_reconstruction.sql   # 72 monthly N_L / N_S snapshots (Table 3, Figure 2)
│   ├── gini_hhi.sql                 # Gini (Eq. 4) and HHI (Eq. 5) — Table 1, Figure 1(a)
│   ├── nakamoto_coefficients.sql    # N_L, N_S running-sum at θ=1/3, 2/3 — Figure 1(b)
│   └── bond_only_baseline.sql       # Staked.total-only legacy method — comparison in Sec 3.2, 4.1
```

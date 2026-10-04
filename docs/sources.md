# Sources et versions figées

Ce document fixe, une fois pour toutes, les versions exactes des artefacts
étudiés. Toute référence à « SUDP » ou à « l'implémentation de référence »
dans ce dépôt renvoie à ces versions précises, pas à une version future ou
antérieure du papier ou du code.

## Papier SUDP

- **Titre** : *SUDP: Secret-Use Delegation Protocol for Agentic Systems*
- **Auteurs** : Xiaohang Yu, Hejia Geng, Xinmeng Zeng, William Knottenbelt
- **arXiv** : [2604.24920](https://arxiv.org/abs/2604.24920)
- **Version étudiée** : **v3, 22 mai 2026** (arxiv.org/abs/2604.24920v3)
  - v1 : 27 avril 2026
  - v2 : 1 mai 2026
  - **v3 : 22 mai 2026 ← version de référence de ce projet**
- Toute citation de section (§3.2, §5, §9, etc.) dans ce dépôt renvoie à la
  pagination/numérotation de v3.
- **Vérification v4** (demandée le 03/10/2026, à refaire avant dépôt
  final) : aucune v4 retrouvée au 03/10/2026 — v3 (22/05/2026) reste la
  dernière version publiée sur arXiv:2604.24920.
- **Exigence de canal II.2** (vérifiée le 03/10/2026) : le texte exige
  explicitement un canal U→T « end-to-end authenticated and confidential »
  — pas seulement confidentiel. Voir [traceability.md](traceability.md),
  section AV, pour l'incidence sur la présentation du résultat.

## Implémentation de référence

- **Dépôt** : [github.com/xhyumiracle/sudp](https://github.com/xhyumiracle/sudp)
- **Commit étudié** : `e953b67129c5edf08b8c5af540c7ada2a8294088`
  - Message : `release: v0.3.0 — execution-budget multiplicity`
  - Date : 2026-08-19
  - Choix délibéré : ce commit introduit précisément le mécanisme de budget
    d'exécution (`Multiplicity`, `authorize_use`) qui est l'objet de l'axe 2
    de la méthodologie (voir [traceability.md](traceability.md)). Fixer ce
    commit garantit que le modèle Tamarin et le code de référence parlent de
    la même sémantique de budget.
- Fichiers du code de référence directement mobilisés pour la fidélité du
  modèle Phase II (ce jalon) :
  - `custodian/rust/src/operation.rs` — tuple `Operation = (act, bind, valid)`,
    `Multiplicity`, `Valid::check`.
  - `custodian/rust/src/phases/grant.rs` — `redeem()` (Phase II.3),
    `authorize_use()` (Phase III, admission par budget), `validate_op_against()`.
  - `custodian/rust/src/phases/consumption.rs` — dispatch Phase III
    (`execute_use`, `execute_export`, `execute_lifecycle`), non modélisé dans
    ce premier jalon (voir portée du fichier `.spthy`).
- Pour réobtenir exactement cette version du code :
  ```bash
  git clone https://github.com/xhyumiracle/sudp.git
  cd sudp && git checkout e953b67129c5edf08b8c5af540c7ada2a8294088
  ```

## SAGA (comparaison, §voir comparison-saga-aith.md)

- **Titre** : *SAGA: A Security Architecture for Governing AI Agentic Systems*
- **Auteurs** : Syros, G. et al.
- **Venue** : NDSS 2026
- **arXiv** : [2504.21034](https://arxiv.org/abs/2504.21034)
- Code public et reproductible (voir dépôt cité dans le papier).

## PACT, APC, InterSAGE, HDP (comparaison, ajout du 03/10/2026)

- **PACT** : Fan, Li, Tian, Wang, Li & Wang (2026), *The Granularity
  Mismatch in Agent Security*, [arXiv:2605.11039](https://arxiv.org/abs/2605.11039).
- **APC** : Muruaga (2026), *Bounded Agents: Delegation Security for
  Multi-Agent AI Systems*. **Aucun identifiant DOI/arXiv retrouvé** — à
  traiter comme une revendication non vérifiable indépendamment, au même
  titre qu'AITH (voir [comparison-saga-aith.md](comparison-saga-aith.md)).
- **InterSAGE** : Zou, Guo, Zhan, Zhao, Li & Liu (2026), *InterSAGE: The
  Secure and Verifiable Interoperability Protocol for An Internet of
  Agents*, [arXiv:2608.13030](https://arxiv.org/abs/2608.13030).
- **HDP** : Dalugoda (2026), [arXiv:2604.04522](https://arxiv.org/abs/2604.04522) ;
  Internet-Draft IETF `draft-helixar-hdp-agentic-delegation`, révision
  **-01 du 3 août 2026** (version demandée par l'encadrant), révision
  **-02 du 11 septembre 2026** (plus récente disponible).

## AITH (comparaison, mention encadrée)

- Revendication d'une vérification Tamarin de propriétés de délégation
  humain-agent, publique depuis avril 2026.
- **Statut à la date de rédaction (septembre 2026)** : ni modèle, ni script,
  ni artefact de preuve consultables publiquement. Traité dans ce projet
  strictement comme une *revendication non vérifiée indépendamment* — jamais
  comme une antériorité mécanisée confirmée (voir contrainte 1 du cadrage de
  l'encadrant, et [comparison-saga-aith.md](comparison-saga-aith.md)).

## Outillage de vérification

- **Tamarin Prover** 1.12.0 (binaire officiel `linux64-ubuntu`,
  [release GitHub](https://github.com/tamarin-prover/tamarin-prover/releases/tag/1.12.0)).
- **Maude** 3.2 (paquet Ubuntu 24.04 `noble`, `3.2-2build1`), moteur de
  réécriture requis par Tamarin.
- Installation entièrement locale (sans `sudo`, sans modification système) :
  voir [reproducibility/toolchain/setup_toolchain.sh](../reproducibility/toolchain/setup_toolchain.sh).

## Littérature méthodologique

- Jackson, D. et al. *Seemingly Similar Uses of Cryptography Are Not the
  Same*, CCS 2019 — justification des abstractions cryptographiques (voir
  commentaire d'en-tête de `sudp_phase2.spthy` sur l'abstraction des
  signatures WebAuthn-style).
- Meier, S., Schmidt, B., Cremers, C., Basin, D. *The TAMARIN Prover for the
  Symbolic Analysis of Security Protocols*, CAV 2013.
- Manuel officiel Tamarin Prover (dernière version en ligne,
  [tamarin-prover.com/manual](https://tamarin-prover.com/manual/)).

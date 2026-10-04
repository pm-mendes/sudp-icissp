# Mechanizing SUDP: Stateful Authorization Guarantees and Deployment Obligations for Agentic Secret Use

Première mécanisation sous Tamarin Prover du protocole **SUDP** (*Secret-Use
Delegation Protocol*, Yu et al., v3, 22 mai 2026, arXiv:2604.24920) —
axe 1 (modèle formel d'autorité et de délégation) du projet de thèse au
CEDRIC/CNAM, sous la supervision de Yulliwas.

Cible : ICISSP 2027, piste Position/Regular Paper, deadline **22 octobre 2026 (AoE)**.

## Question scientifique directrice

Déterminer quelles garanties de SUDP sont préservées lorsque ses obligations
d'intégration (déploiement, gestion d'état durable, budgets d'usage)
deviennent explicites dans le modèle formel — pas simplement « vérifier que
SUDP est sûr ».

## Cadrage (à respecter dans toute contribution à ce dépôt)

1. **Pas de surévaluation de la nouveauté.** SAGA (NDSS 2026) a déjà une
   analyse ProVerif complète et reproductible. AITH revendique une
   vérification Tamarin non reproductible à ce jour — à citer uniquement
   comme revendication, jamais comme antériorité confirmée. La revendication
   correcte : première mécanisation de **SUDP spécifiquement**. Détail :
   [docs/comparison-saga-aith.md](docs/comparison-saga-aith.md).
2. **Pas de vocabulaire d'impossibilité cryptographique.** SUDP offre des
   garanties *conditionnées à des hypothèses de déploiement explicites*,
   jamais une garantie absolue.
3. **Distinguer admission et effet.** Le jeton de fraîcheur `r` (Phase II,
   à usage unique) ≠ le budget d'exécution `multiplicity` (Phase III,
   potentiellement > 1). « Au plus une fois » au niveau du protocole
   n'implique pas « exactement une fois » au niveau de l'effet réel.
4. **Gestion des budgets = objet d'analyse documenté**, pas une faille à
   sensationnaliser.

Voir le tableau de traçabilité pour la mise en œuvre concrète de ces
contraintes dans le modèle.

## État d'avancement (au 03/10/2026)

| Livrable | Statut |
|---|---|
| Tableau de traçabilité (AV, OB, UB, CRC, budget/challenge) | [docs/traceability.md](docs/traceability.md) — « 3 propriétés complètes (AV, OB, CRC) + 1 partielle (UB) » sur la Phase II, `executable` compté comme contrôle et non comme propriété |
| `.spthy` Phase II (Grant Authorization) | [models/phase2-grant-authorization/sudp_phase2.spthy](models/phase2-grant-authorization/sudp_phase2.spthy) — AV, OB, CRC vérifiés, UB (admission) vérifié |
| Variante d'affaiblissement d'hypothèse II.2 (méthodologie étape 3) | [models/phase2-grant-authorization/hypothesis-necessity/](models/phase2-grant-authorization/hypothesis-necessity/) — CRC et AV tombent quand le canal II.2 n'est plus confidentiel ; clarifié : le papier exige un canal authentifié **et** confidentiel, le modèle réalise l'authentification au niveau contenu (signature) et la confidentialité au niveau canal (`aenc`) |
| **Axe 2 tranché (03/10) : budgets/concurrence**, Phase III | [models/phase3-budget/](models/phase3-budget/) — N=1 et N=2, atomique et non atomique, un lemme d'exécutabilité par N ; UB vérifié sous atomicité, **falsifié** (contre-exemple de nécessité) sans atomicité, pour N=1 et N=2 |
| Comparaison SAGA / AITH / PACT / APC / InterSAGE / HDP | [docs/comparison-saga-aith.md](docs/comparison-saga-aith.md) |
| Dossier de reproductibilité | [reproducibility/](reproducibility/) — `bash reproducibility/run_all.sh` reproduit tout, aucun problème de terminaison rencontré |

Prochaines étapes (go/no-go du 12/10) : squelette SCITEPRESS (sections
modèle + Phase II), versement complet dans Overleaf, analyse de nécessité
étendue à d'autres hypothèses, adaptateur d'intégration concret — voir
`AUDIT-SUDP-2026-10-03.md` pour le détail des actions et échéances.

## Structure du dépôt

```
.
├── docs/
│   ├── sources.md                  # versions figées : papier v3, commit repo, outils
│   ├── traceability.md             # propriété → hypothèses → modèle Tamarin → résultat
│   └── comparison-saga-aith.md     # SUDP vs SAGA vs AITH (nouveauté correctement bornée)
├── models/
│   └── phase2-grant-authorization/
│       ├── sudp_phase2.spthy               # modèle de base (Phase II)
│       └── hypothesis-necessity/
│           └── sudp_phase2_weak_channel.spthy  # canal II.2 affaibli
├── reproducibility/
│   ├── run_all.sh                  # tout reproduire depuis un checkout propre
│   ├── toolchain/                  # installation locale tamarin-prover + Maude, sans sudo
│   ├── logs/                       # sorties tamarin-prover archivées
│   └── traces/                     # traces JSON exportées
└── references/references.bib
```

## Reproduire les résultats

```bash
bash reproducibility/run_all.sh
```

Aucune dépendance système préalable requise : le script installe
`tamarin-prover` 1.12.0 et `maude` 3.2 dans `~/.local/`, sans `sudo`. Détails
dans [reproducibility/README.md](reproducibility/README.md).

## Sources exactes

Papier SUDP v3 (22 mai 2026, arXiv:2604.24920), dépôt de référence
[xhyumiracle/sudp](https://github.com/xhyumiracle/sudp) au commit
`e953b67129c5edf08b8c5af540c7ada2a8294088`, SAGA (NDSS 2026,
arXiv:2504.21034). Détail complet et justification de chaque choix de
version : [docs/sources.md](docs/sources.md).

## Branches

Le développement se fait sur `develop` ; `main` reste la branche stable.

## Licence

[MIT](LICENSE).

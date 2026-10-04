# Phase II — Grant Authorization

Modèle Tamarin de la Phase II de SUDP (requête, signature par l'autorisateur,
redemption par le Custodian). Voir l'en-tête de
[`sudp_phase2.spthy`](sudp_phase2.spthy) pour le périmètre exact et les
abstractions, et [`docs/traceability.md`](../../docs/traceability.md) pour
le lien entre chaque lemme et la propriété du papier qu'il incarne.

## Reproduire

```bash
source ../../reproducibility/toolchain/env.sh   # après setup_toolchain.sh
tamarin-prover --prove sudp_phase2.spthy
```

Résultat attendu (voir [`../../reproducibility/logs/phase2_full_run.log`](../../reproducibility/logs/phase2_full_run.log)) :

```
executable (exists-trace): verified (7 steps)
AV_authorization_verifiability (all-traces): verified (9 steps)
OB_operation_binding (all-traces): verified (10 steps)
CRC_wrapping_key_secrecy (all-traces): verified (5 steps)
UB_challenge_single_redemption_partial (all-traces): verified (14 steps)
```

## Variante `hypothesis-necessity/`

[`hypothesis-necessity/sudp_phase2_weak_channel.spthy`](hypothesis-necessity/sudp_phase2_weak_channel.spthy)
retire la seule hypothèse de confidentialité du canal II.2 (le grant est
envoyé en clair au lieu d'être chiffré sous la clé publique du Custodian).
Résultat attendu :

```
executable (exists-trace): verified (7 steps)
CRC_wrapping_key_secrecy (all-traces): falsified - found trace (5 steps)
AV_authorization_verifiability (all-traces): falsified - found trace (7 steps)
```

Ceci **n'est pas une faille de SUDP tel que spécifié** (l'hypothèse de canal
confidentiel est explicitement en vigueur dans le protocole) : c'est la
démonstration, au sens de la méthodologie d'affaiblissement d'hypothèses,
que cette hypothèse assure une double fonction — confidentialité de W* ET
intégrité de sa liaison à la signature, puisque β ne lie pas W*. Voir
[`docs/traceability.md`](../../docs/traceability.md), section AV, pour la
discussion complète.

## Ouvrir en mode interactif (inspection de traces)

```bash
tamarin-prover interactive sudp_phase2.spthy
# puis ouvrir http://localhost:3001 dans un navigateur
```

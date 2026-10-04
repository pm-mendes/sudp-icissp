# Phase III — Budget d'exécution (axe 2 : budgets/concurrence)

Garde-fous fixés par Yulliwas le 03/10/2026 : budget N=1 et N=2, un lemme
d'exécutabilité par N, deux sessions entrelacées sur le même compteur, avec
et sans atomicité ; la version non atomique devait donner le contre-exemple
de nécessité. **Aucun problème de terminaison rencontré** (tous les runs
sous 16 s) — pas de réduction de portée nécessaire avant le 09/10.

## Fichiers

Quatre théories Tamarin **indépendantes**, chacune autonome (reprend la
Phase I/II de [`../phase2-grant-authorization/sudp_phase2.spthy`](../phase2-grant-authorization/sudp_phase2.spthy)).
Volontairement séparées : faire coexister une variante atomique et une
variante non atomique dans la même théorie laisserait Tamarin utiliser les
règles non atomiques pour contredire un lemme énoncé sur la variante
atomique (erreur commise puis corrigée en cours de construction — voir
l'historique de ce dossier).

| Fichier | Résultat |
|---|---|
| `sudp_phase3_budget_N1_atomic.spthy` | `executable` vérifié (6 pas) ; `UB_N1_atomic_at_most_one_execution` **vérifié** (12 pas) |
| `sudp_phase3_budget_N1_nonatomic.spthy` | `executable` vérifié (6 pas) ; `UB_N1_nonatomic_at_most_one_execution` **falsifié** (10 pas) — contre-exemple de nécessité |
| `sudp_phase3_budget_N2_atomic.spthy` | `executable_one_execution` et `executable_two_executions` vérifiés (7, 11 pas) ; `UB_N2_atomic_at_most_two_executions` **vérifié** (156 pas) |
| `sudp_phase3_budget_N2_nonatomic.spthy` | `executable_two_executions` vérifié (10 pas) ; `UB_N2_nonatomic_at_most_two_executions` **falsifié** (16 pas) — contre-exemple de nécessité |

Logs complets : [`../../reproducibility/logs/`](../../reproducibility/logs/)
(`phase3_N1_atomic_run.log`, etc.). Traces JSON :
[`../../reproducibility/traces/`](../../reproducibility/traces/).

## Ce que le modèle isole

- **Admission (Phase II) vs. effet (Phase III)** : le jeton `r` (`Fresh`,
  linéaire, consommé une fois à la redemption — prouvé dans le modèle
  Phase II) et le compteur durable `CounterZero(r)`/`CounterOne(r)` (créé
  à la redemption, manipulé uniquement en Phase III) sont deux objets
  Tamarin distincts avec des cycles de vie indépendants. « Au plus une
  admission par r » (Phase II) n'implique pas « au plus N effets » tant
  que le compteur lui-même n'est pas correctement gardé (Phase III).
- **Atomicité, pas la valeur de N** : le même défaut (une règle qui relit
  l'état du compteur sans le réserver) casse aussi bien le budget N=1 que
  N=2 — modélisé deux fois pour le montrer, pas parce que le mécanisme
  diffère.
- **Entrelacement sans réseau** : les contre-exemples non atomiques ne
  font intervenir aucune règle d'attaquant Dolev-Yao — c'est un défaut
  purement interne à la gestion d'état du Custodian (deux sessions
  légitimes concurrentes sur la même ressource), distinct des résultats
  de la Phase II qui, eux, dépendent de l'attaquant réseau.

## Reproduire

```bash
source ../../reproducibility/toolchain/env.sh
tamarin-prover --prove sudp_phase3_budget_N1_atomic.spthy
tamarin-prover --prove sudp_phase3_budget_N1_nonatomic.spthy
tamarin-prover --prove sudp_phase3_budget_N2_atomic.spthy
tamarin-prover --prove sudp_phase3_budget_N2_nonatomic.spthy
```

## Limites assumées à ce stade

- Budget borné à de petites valeurs explicites (N=1, N=2) plutôt qu'un
  compteur de Peano générique — choix délibéré pour rester dans les
  garde-fous et écarter le risque de non-terminaison sur un compteur non
  borné ; confirmé inutile ici (tous les runs terminent en quelques
  secondes), mais le passage à un N symbolique reste un travail distinct.
- L'opération `o` reste opaque (voir Phase II) ; le budget `m` n'est pas
  encore lié cryptographiquement dans `β` (pas demandé par les
  garde-fous du 03/10 ; à faire si un relecteur demande la liaison
  budget↔signature par symétrie avec le résultat sur W*).
- Pas encore de modélisation du côté « effet observable dans le service
  externe » distinct de l'admission au Custodian (`Executed(r)` représente
  ici l'admission Phase III, pas un effet EE séparé) — prochaine
  itération si retenue.

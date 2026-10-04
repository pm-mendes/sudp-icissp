# Tableau de traçabilité — propriétés, hypothèses, modèle Tamarin

Ce tableau relie chaque propriété de sécurité visée aux hypothèses dont elle
dépend, à l'élément concret du modèle Tamarin qui l'incarne, et au résultat
obtenu (ou attendu, pour ce qui dépasse ce premier jalon). Il sert la
question scientifique directrice : déterminer quelles garanties de SUDP
sont préservées lorsque ses obligations d'intégration deviennent explicites
dans le modèle formel — pas simplement « vérifier que SUDP est sûr ».

Sources figées : voir [sources.md](sources.md) (SUDP v3, 22/05/2026,
arXiv:2604.24920 ; commit `e953b671...4088` du dépôt de référence).

Modèle Phase II : [`models/phase2-grant-authorization/sudp_phase2.spthy`](../models/phase2-grant-authorization/sudp_phase2.spthy).
Variante d'affaiblissement d'hypothèse (canal II.2) : [`hypothesis-necessity/sudp_phase2_weak_channel.spthy`](../models/phase2-grant-authorization/hypothesis-necessity/sudp_phase2_weak_channel.spthy).
Modèle Phase III (budget/concurrence, axe 2) : [`models/phase3-budget/`](../models/phase3-budget/) — quatre théories N∈{1,2}×{atomique,non atomique}.
Logs d'exécution : [`reproducibility/logs/`](../reproducibility/logs/). Traces exportées (JSON + dot) : [`reproducibility/traces/`](../reproducibility/traces/).

> **Relevé du tableau de bord (correction du 03/10/2026)** : « 5/5 lemmes »
> ne veut pas dire 5 propriétés. Sur la Phase II, le compte exact est
> **3 propriétés complètes (AV, OB, CRC) + 1 propriété partielle (UB,
> volet admission)** ; `executable` est un contrôle de non-vacuité du
> modèle (étape 1 de la méthodologie), pas une propriété de sécurité — il
> ne doit pas être compté dans le numérateur. Sur la Phase III (ce
> jalon), UB est maintenant couvert aussi pour le volet effet/budget,
> avec un résultat par N∈{1,2} et par régime d'atomicité (voir section
> dédiée ci-dessous).

## Exécutabilité — contrôle méthodologique, pas une propriété (étape 1)

**Ce n'est pas une propriété de sécurité** : c'est un contrôle de
non-vacuité préalable, requis par la méthodologie avant de faire confiance
à un seul lemme `all-traces`. Ne pas le compter dans le total de propriétés
vérifiées (correction du tableau de bord, voir ci-dessus).

| Élément | Détail |
|---|---|
| Rôle | Au moins une session honnête aboutit à une redemption réussie (Phase II), resp. à une exécution admise (Phase III). Écarte le risque qu'un `all-traces` soit vrai uniquement parce qu'une erreur de modélisation rend le protocole inexécutable. |
| Hypothèses requises | Aucune. |
| Élément Tamarin | `lemma executable` (`exists-trace`), action `Redeemed(...)` (Phase II) ou `Executed(...)` (Phase III). |
| Résultat Phase II | Vérifié — trace en 7 étapes. |
| Résultat Phase III | Un lemme d'exécutabilité **par combinaison de restrictions active dans les preuves de ce fichier** (voir section « Restrictions » ci-dessous) : `executable_atomic`/`executable_nonatomic` pour N=1 (6 étapes chacun) ; `executable_one_execution`/`executable_two_executions` pour N=2 atomique (7, 11 étapes) ; `executable_two_executions` pour N=2 non atomique (10 étapes) — ce dernier confirmant que le budget *prévu* (2) reste atteignable même dans la variante défaillante, ce qui exclut que le contre-exemple de nécessité ne soit qu'un modèle devenu trivialement inexécutable. |

## Restrictions utilisées et exécutabilité par combinaison

Une seule `restriction` existe dans l'ensemble de ces modèles :

```
restriction Equality:
  "All x y #i. Eq(x, y) @ i ==> x = y"
```

Elle sert uniquement à exprimer la vérification de signature
(`verify(sig, beta, pkU) = true`) sans pattern-matching direct sur
`sign(_, ltkU)` — idiome standard qui évite un avertissement de bonne
formation Tamarin (« unintended pattern matching », rencontré et corrigé
lors de la construction du modèle Phase II, voir historique). Elle est
**active dans toutes les preuves** de tous les fichiers `.spthy` de ce
dépôt (Phase II base, variante canal affaibli, Phase III ×4) : il n'y a
qu'une seule combinaison de restrictions à couvrir, et chaque fichier porte
son propre lemme `exists-trace` sous cette combinaison (listés ci-dessus
et dans `models/phase3-budget/README.md`). Aucun fichier n'introduit de
restriction supplémentaire ni de combinaison distincte à ce jour.

## AV — Authorization Verifiability

| Élément | Détail |
|---|---|
| Propriété visée (papier) | Toute exécution induite via le mécanisme est couverte par un événement d'autorisation attribuable à l'utilisateur UU. |
| Hypothèses requises | Signature EUF-CMA (idéalisée via le builtin `signing` de Tamarin) ; clé longue durée de l'autorisateur non compromise ; canal II.2 confidentiel+authentique (voir colonne « Nécessité »). |
| Élément Tamarin | `lemma AV_authorization_verifiability` : toute action `Redeemed(T, cidU, o, r, wstar)` est précédée d'une action `AuthorizerSigned(cidU, T2, o, r, wstar)`. |
| Résultat (modèle de base) | **Vérifié** — 9 étapes. |
| Nécessité de l'hypothèse « canal confidentiel » | **Vérifiée expérimentalement** : dans la variante affaiblie (`hypothesis-necessity/`), retirer uniquement le chiffrement du message II.2 fait tomber AV (contre-exemple en 7 étapes, exporté dans `reproducibility/traces/phase2_weak_channel.json` et `phase2_weak_channel_CRC.dot`). Constat de modélisation : β = H(DS_bind‖r‖H(o)) ne lie **pas** W* ; c'est donc la confidentialité du canal II.2 — pas la signature seule — qui protège l'intégrité de la liaison W*↔signature. Ce n'est **pas** une faille de SUDP tel que spécifié avec son hypothèse de canal confidentiel en vigueur ; c'est la démonstration que cette hypothèse assure une double fonction (secret ET intégrité de W*) qui mériterait d'être rendue explicite dans le papier. |

### Le canal II.2 exige confidentialité ET authentification — vérifié sur le texte

Vérification demandée le 03/10/2026 : **oui**, SUDP v3 exige explicitement
que le canal U→T (II.2) soit « *end-to-end authenticated and confidential* »
(texte du papier), et pas seulement confidentiel. Ceci **change la
présentation** du résultat ci-dessus, dans le sens suivant :

- Le papier distingue deux legs au trajet du grant : **T→U** (matériel
  public uniquement — pas de confidentialité requise, juste une protection
  contre l'altération, « *detected at redemption through the signature on
  β* ») et **U→T** (porte W\* — confidentialité **et** authentification
  requises).
- Le modèle réalise ces deux propriétés par **deux mécanismes à deux
  niveaux différents**, et non par une seule primitive de canal : la
  confidentialité est portée par le chiffrement `aenc` vers la clé publique
  du Custodian (niveau canal) ; l'authentification est portée par la
  signature intégrée au contenu, `sign(β, ltkU)` (niveau contenu,
  end-to-end — exactement le vocabulaire du papier). Le modèle de base
  réalise donc bien les **deux** exigences, simplement pas par la même
  construction Tamarin.
- La variante affaiblie ne retire que le mécanisme de confidentialité ;
  le mécanisme d'authentification (la signature intégrée) reste intact
  dans les deux variantes. La chute d'AV dans la variante affaiblie n'est
  donc **pas** imputable à une perte d'authentification — elle montre
  spécifiquement que la confidentialité seule protège aussi l'intégrité
  de W* (puisque β ne le lie pas), un rôle qu'on n'attendrait pas d'elle a
  priori. Ceci confirme, plutôt que contredit, l'asymétrie que le papier
  lui-même pose entre les deux legs (T→U : intégrité détectée à
  redemption suffit ; U→T : confidentialité et authentification exigées
  en prévention).
- Limite assumée : le modèle ne teste pas séparément « authentification
  du canal sans confidentialité » (un attaquant qui casserait
  uniquement l'authentification, la confidentialité restant intacte) —
  hors périmètre de ce jalon, candidat pour l'étape 3 étendue à d'autres
  hypothèses si jugé utile.

## OB — Operation Binding

| Élément | Détail |
|---|---|
| Propriété visée (papier) | Une autorisation est liée à une opération `o` spécifique ; le mécanisme n'induit l'exécution d'aucune opération sémantiquement distincte de `o` (anti-substitution, Phase II.4). |
| Hypothèses requises | Résistance aux collisions de `H` ; signature EUF-CMA ; `o` inclus dans le calcul de β. |
| Élément Tamarin | `lemma OB_operation_binding` : si `Redeemed(T,cidU,o,r,wstar)` et `AuthorizerSigned(cidU,T,o2,r,wstar)` partagent `(r, wstar)`, alors `o = o2`. |
| Résultat | **Vérifié** — 10 étapes. |
| Limite de fidélité | `o` est modélisé comme un terme opaque (non décomposé en `act/bind/valid`) — voir en-tête du `.spthy`. Suffisant pour Phase II ; la décomposition devient nécessaire pour modéliser le dispatch Phase III (jalon suivant). |

## CRC — Confidentiality under Requester Compromise

| Élément | Détail |
|---|---|
| Propriété visée (papier) | La compromission du requester n'expose pas de matériel porteur d'autorité. |
| Hypothèses requises | Canal II.2 confidentiel (chiffrement sous la clé publique du Custodian) ; clé privée du Custodian non compromise. |
| Élément Tamarin | `lemma CRC_wrapping_key_secrecy` : secret standard sur `wstar` (`not (Ex #j. K(wstar) @ j)`). Le Requester n'a **pas** de rôle honnête dédié — il est fusionné avec l'attaquant Dolev-Yao, conformément au modèle d'adversaire de base du papier (§3.2, A^R + A^net) : c'est le pire cas pour RR, donc le cas pertinent pour CRC. |
| Résultat (modèle de base) | **Vérifié** — 5 étapes : W* reste secret même face à un Requester/réseau totalement adversarial. |
| Nécessité de l'hypothèse « canal confidentiel » | **Vérifiée expérimentalement** : dans la variante affaiblie, CRC tombe (contre-exemple en 5 étapes) dès que le message II.2 est envoyé en clair — résultat attendu, il confirme que le modèle n'est pas trivialement sûr indépendamment de cette hypothèse. |

## UB — Use Boundedness

| Élément | Détail |
|---|---|
| Propriété visée (papier) | L'exécution induite via le mécanisme ne peut excéder les bornes que UU a autorisées. |
| Distinction essentielle (contrainte 3 du cadrage) | Le jeton de fraîcheur `r` (Phase II, admission par le Custodian) et le budget d'exécution `multiplicity` (Phase III, effet) sont deux notions séparées. « Au plus une fois » au niveau de l'admission n'implique pas « exactement une fois » au niveau de l'effet réel — SUDP §5/§9 autorise explicitement `multiplicity ∈ {1, …, ∞}` (`custodian/rust/src/operation.rs::Multiplicity`). |
| **Volet admission (Phase II)** | `lemma UB_challenge_single_redemption_partial` : un même challenge `r` ne peut fonder deux redemptions distinctes. **Vérifié** — 14 étapes. |
| **Volet effet/budget (Phase III, ce jalon — axe 2)** | Quatre modèles dans [`models/phase3-budget/`](../models/phase3-budget/), paramétrés par N∈{1,2} et par le régime d'atomicité du compteur durable `CounterZero(r)`/`CounterOne(r)`. Voir tableau détaillé ci-dessous. |
| Statut global | **UB est maintenant couvert sur ses deux volets** pour des budgets explicites N=1 et N=2 : admission bornée (Phase II, inchangé) et effet borné *sous réserve d'atomicité du compteur* (Phase III, ce jalon) — avec démonstration explicite que l'atomicité est nécessaire, pas accessoire. |

### Résultats Phase III (budget d'exécution)

| Modèle | `executable` (par N) | UB (effet borné) |
|---|---|---|
| N=1, atomique | Vérifié (6 étapes) | **Vérifié** — `UB_N1_atomic_at_most_one_execution` (12 étapes) |
| N=1, non atomique | Vérifié (6 étapes) | **Falsifié** — `UB_N1_nonatomic_at_most_one_execution` (10 étapes) : contre-exemple de nécessité |
| N=2, atomique | Vérifiés (7 et 11 étapes, une et deux exécutions) | **Vérifié** — `UB_N2_atomic_at_most_two_executions` (156 étapes) |
| N=2, non atomique | Vérifié (10 étapes) | **Falsifié** — `UB_N2_nonatomic_at_most_two_executions` (16 étapes) : contre-exemple de nécessité |

Les deux contre-exemples non atomiques ne font intervenir **aucune règle
d'attaquant réseau** : ce sont des défauts purement internes à la gestion
d'état du Custodian (deux sessions légitimes concurrentes qui lisent le
même compteur avant qu'aucune n'ait committé son usage), distincts par
nature des résultats Phase II (qui, eux, dépendent de l'attaquant
Dolev-Yao). Ceci illustre précisément la contrainte 4 du cadrage : la
gestion du compteur durable et son atomicité sont un **choix de
déploiement documenté**, pas une vulnérabilité du protocole SUDP — le
protocole ne spécifie pas comment le compteur doit être implémenté ;
ce jalon montre que l'implémenter sans section critique/verrouillage ne
réalise pas la borne UB que le papier revendique sous l'hypothèse d'un
compteur correctement géré.

Aucun des quatre modèles n'a rencontré de problème de terminaison (tous
sous 16 secondes) : pas de réduction de portée nécessaire au 09/10.

## Distinction Budget / Challenge — vue d'ensemble

| Aspect | Jeton de fraîcheur `r` (Phase II) | Budget d'exécution `multiplicity` (Phase III) |
|---|---|---|
| Nature Tamarin | Fait linéaire `Fresh($T, r)`, consommé une fois (par `Custodian_Attempt_Redeem`, quel que soit le résultat de la validation ultérieure — fidèle à `redeem()` step 1, « r is consumed regardless of which step fails »). | Fait linéaire **mutable** `CounterZero(r)`→`CounterOne(r)`→exhausted (compteur d'usages), créé à la redemption, manipulé uniquement en Phase III. |
| Portée dans le code de référence | `custodian/rust/src/phases/grant.rs::redeem()`. | `custodian/rust/src/phases/grant.rs::authorize_use()` + `operation.rs::Multiplicity`. |
| Sémantique | Anti-rejeu de l'admission d'une grant précise. | Borne du nombre d'exécutions Phase III sous une grant déjà admise. |
| Confusion à éviter | Ne pas lire « r à usage unique » comme « l'opération ne s'exécute qu'une fois » — un budget `multiplicity > 1` autorise plusieurs exécutions sous la même grant redemptée une seule fois. |
| Statut dans ce jalon | **Modélisé et prouvé** (`UB_challenge_single_redemption_partial`). | **Modélisé et prouvé pour N∈{1,2}**, avec démonstration que la borne ne tient que sous atomicité du compteur (voir [`models/phase3-budget/`](../models/phase3-budget/)). |

## Abstractions cryptographiques et limites résiduelles

| Abstraction | Justification | Limite documentée |
|---|---|---|
| Signature = builtin `signing` de Tamarin (EUF-CMA idéalisée, `verify(sign(m,sk),m,pk(sk))=true`) | Standard pour une première analyse symbolique ; cf. Jackson et al., CCS'19, sur la nécessité de justifier chaque abstraction plutôt que de la sous-entendre. | Élide le contexte de liaison au canal propre aux authentificateurs WebAuthn-style (`rpId`, `origin`) que `Authenticator::verify_assertion` vérifie en plus de β dans l'implémentation de référence. Une attaque par confusion d'origine inter-sites est hors du périmètre de cette idéalisation. |
| W* modélisé comme frais (`Fr(~wstar)`) plutôt que dérivé par PRF de la credential | Suffisant pour les propriétés de secret/liaison visées ici (le modèle n'a pas besoin de la structure interne de la dérivation pour AV/OB/CRC). | À réviser si un futur jalon porte sur la robustesse au niveau credential (CSB/CMC/RFS, hors périmètre — voir ci-dessous). |
| Canal II.2 modélisé par chiffrement asymétrique explicite (`aenc`) sous la clé publique du Custodian, plutôt que par un canal Tamarin implicite | Rend l'hypothèse de confidentialité syntaxiquement explicite et *retirable* — condition nécessaire pour la méthodologie d'affaiblissement d'hypothèses (étape 3). | Le modèle de base ne compromet jamais la clé privée du Custodian (pas de règle `Reveal`) ; l'ajout d'une telle règle est le mécanisme prévu pour étendre l'analyse de nécessité des hypothèses à d'autres composants. |
| Requester fusionné avec l'attaquant Dolev-Yao | Pire cas exact pour CRC, cohérent avec le modèle d'adversaire de base du papier (§3.2). | Ne permet pas, en l'état, de distinguer un Requester honnête-mais-bogué d'un Requester activement malveillant — non nécessaire pour ce jalon. |

## Hors périmètre de ce jalon (assumé, pas oublié)

- **Dispatch Phase III complet** (`use`/`export`/`write`/`rotate`/`enroll`/`revoke`) — ce jalon modélise l'admission d'une exécution générique sous budget (`Executed(r)`), pas le dispatch par type d'acte ; nécessaire pour CRC au sens plein (« le secret ne quitte jamais T vers RR »), actuellement seul W* (pas le secret applicatif `s_o`) est couvert.
- **Effet observable côté service externe, distinct de l'admission au Custodian** — `Executed(r)` représente ici l'admission Phase III (équivalent de `authorize_use() -> Ok`), pas un fait séparé pour l'effet constaté dans le service externe EE. La distinction admission/effet est déjà faite entre Phase II (`Redeemed`) et Phase III (`Executed`) ; reste à faire *à l'intérieur* de Phase III.
- **Liaison cryptographique du budget `m`** : `m` n'est pas encore inclus dans `β` (comme `o` l'est) — une substitution de budget par un adversaire qui intercepterait un grant chiffré n'a pas été testée, par symétrie avec le résultat obtenu sur W*.
- **CSB, CMC, RFS** (extensions de robustesse : compromission du stockage persistant / de la mémoire d'exécution / secret par époque de rotation) — nécessitent des hypothèses matérielles (TEE) que le modèle Dolev-Yao standard ne représente pas nativement ; hors des quatre propriétés-cœur demandées pour ce jalon.
- **Révocation vs. autorisations déjà accordées** — écarté pour l'axe 2 (décision du 03/10/2026 : budgets/concurrence retenu, pour éviter le recouvrement avec RECLAIM qui porte déjà sur la révocation côté ICISSP).
- **Compteur N symbolique** (arithmétique de Peano générale plutôt que N∈{1,2} énumérés) — non nécessaire : les garde-fous du 03/10 bornent volontairement à N=1/N=2, et aucun problème de terminaison n'a justifié d'aller plus loin pour ce jalon.
- **Adaptateur d'intégration concret** (étape 4 de la méthodologie) — prévu une fois le modèle Phase III stabilisé et le squelette SCITEPRESS avancé.

# SUDP, SAGA, AITH : ce que chacun vérifie, sous quel outil, avec quel degré de reproductibilité

*Note de cadrage (une demi-page). Objectif : situer précisément ce travail
sans surévaluer sa revendication de nouveauté (contrainte 1 du cadrage de
l'encadrant). Sources figées dans [sources.md](sources.md).*

**SAGA** (Syros et al., NDSS 2026, arXiv:2504.21034) propose une
architecture de gouvernance pour systèmes agentiques IA et fournit une
**analyse ProVerif complète**, avec artefacts publics et reproductibles :
code source disponible, preuves de secret et d'authentification sous un
adversaire Dolev-Yao. C'est la référence en matière de vérification
mécanisée pour la délégation d'autorité entre agents, et son objectif est
le **contrôle d'accès inter-agents** : garantir qu'un agent n'exécute que
les actions que la politique de gouvernance lui permet.

**AITH** revendique, depuis avril 2026, une vérification Tamarin de
propriétés de délégation humain-agent. **Ni le modèle, ni les scripts, ni
un artefact de preuve ne sont publiquement consultables ou reproductibles**
à la date de rédaction de ce document (septembre 2026). Ce travail ne cite
donc AITH que comme une *revendication des auteurs*, jamais comme un
résultat vérifié indépendamment, et jamais comme une antériorité mécanisée
confirmée.

**Ce travail** mécanise **SUDP** (Yu et al., v3, arXiv:2604.24920) sous
**Tamarin Prover**. SUDP vise un objectif distinct de celui de SAGA et de la
revendication d'AITH : la **non-exposition du secret au requester**
lui-même — empêcher qu'un agent requester, même compromis, n'acquière une
autorité réutilisable sur un secret, indépendamment de tout contrôle
d'accès inter-agents en amont. SAGA et SUDP sont complémentaires plutôt que
concurrents : SAGA pourrait gouverner *quel* agent peut proposer *quelle*
opération, tandis que SUDP gouverne *comment* cette opération, une fois
proposée, s'exécute sans jamais exposer le secret sous-jacent au
proposant.

## Revendication de nouveauté retenue

**Ni** « première vérification mécanisée d'un protocole de délégation
d'agents » (faux : SAGA le fait déjà, avec preuve à l'appui) **ni**
« première antériorité sur AITH » (non comparable : AITH n'est pas
reproductible, donc pas falsifiable). La revendication défendable et
strictement délimitée est : **première mécanisation de SUDP
spécifiquement**, sous Tamarin, avec traçabilité explicite entre les
hypothèses de déploiement de SUDP (canal confidentiel de la Phase II,
budget d'exécution durable de la Phase III) et les garanties formelles
qu'elles rendent possibles — un objet que ni SAGA ni la revendication
d'AITH ne couvrent, puisqu'aucun des deux ne traite ce protocole.

| | Protocole modélisé | Outil | Propriétés | Reproductibilité |
|---|---|---|---|---|
| SAGA (NDSS 2026) | Gouvernance inter-agents (contrôle d'accès) | ProVerif | Secret, authentification | **Publique, reproduite indépendamment possible** (code + preuves disponibles) |
| AITH (revendication, avril 2026) | Délégation humain-agent | Tamarin (revendiqué) | Non précisé publiquement | **Non reproductible** — aucun artefact consultable |
| Ce travail | SUDP (non-exposition du secret au requester) | Tamarin | AV, OB, CRC, UB (admission + effet borné, N∈{1,2}) | Publique dès ce dépôt — voir [reproducibility/](../reproducibility/) |

## Quatre voisins supplémentaires (ajout du 03/10/2026)

*Bibliographie reprise et croisée avec la veille déjà établie pour un autre
chantier du même auteur ([`08-TWEB-PBD/VEILLE-NOUVEAUTE.md`](../../../overleaf/08-TWEB-PBD/VEILLE-NOUVEAUTE.md),
18/09/2026) — mêmes réserves de méthode : les caractérisations ci-dessous
viennent de résumés indexés sauf mention contraire, et tout chiffre annoncé
par des auteurs est signalé comme tel, jamais recopié comme un fait établi.*

- **PACT** (Fan, Li, Tian, Wang, Li & Wang, 2026, *The Granularity Mismatch
  in Agent Security*, arXiv:2605.11039) — attribue des rôles sémantiques aux
  arguments d'appels d'outils et vérifie leur provenance contre un contrat
  de confiance par rôle. **Aucun résultat de vérification formelle
  mécanisée mentionné dans le résumé** (ce qui ne prouve pas son absence,
  à confirmer sur le texte intégral). Modèle de confiance : infrastructure
  honnête à l'intérieur d'un domaine administratif (moniteur fiable).
  Objectif distinct de SUDP : PACT lie la provenance des *arguments*
  d'un appel d'outil, SUDP empêche l'exposition du *secret* utilisé par cet
  appel au requester lui-même — les deux sont complémentaires, pas
  concurrents.
- **APC** (Muruaga, 2026, *Bounded Agents: Delegation Security for
  Multi-Agent AI Systems*) — **non citable comme résultat vérifié en
  l'état** : aucun identifiant DOI ni arXiv retrouvé à ce jour, donc aucun
  texte intégral consultable indépendamment. Les auteurs annoncent deux
  théorèmes prouvés (*Blast Radius Monotonicity*, *Composition Soundness*)
  et des chiffres d'évaluation (latence, taux de blocage) — **ces chiffres
  sont non sourcés** et ne doivent pas être cités comme des faits établis.
  Traité ici exactement comme AITH : une revendication, pas une
  antériorité confirmée.
- **InterSAGE** (Zou, Guo, Zhan, Zhao, Li & Liu, 2026, *InterSAGE: The
  Secure and Verifiable Interoperability Protocol for An Internet of
  Agents*, arXiv:2608.13030) — architecture à quatre couches (identité
  persistante par DID/Verifiable Credentials, découverte, négociation de
  confiance, responsabilité), avec atténuation monotone de capacité et
  audit cryptographique sans registre à consensus. Les auteurs se comparent
  à plus de 50 travaux ; cette affirmation d'exhaustivité est reprise ici
  comme une **affirmation d'auteurs, non vérifiée indépendamment**.
  Périmètre distinct de SUDP : InterSAGE structure l'interopérabilité et
  l'identité inter-agents, SUDP protège un secret ponctuel face à un
  requester donné — pas de recouvrement de propriétés vérifiées.
- **HDP** (Dalugoda, 2026, *HDP: A Lightweight Cryptographic Protocol for
  Human Delegation Provenance in Agentic AI Systems*, arXiv:2604.04522 ;
  également publié comme Internet-Draft IETF
  `draft-helixar-hdp-agentic-delegation`, révision **-01 du 3 août 2026**,
  révision **-02 plus récente du 11 septembre 2026** — SDK TypeScript
  public) — jeton liant un événement d'autorisation humaine à une session,
  chaque délégation d'agent formant un saut signé dans une chaîne en
  ajout seul, vérifiable hors ligne avec la seule clé publique Ed25519 de
  l'émetteur. Granularité la plus étroite des quatre voisins : HDP lie la
  *session*, pas l'opération individuelle — SUDP lie chaque grant à une
  opération `o` précise via β, ce qui est une garantie plus fine mais à
  une échelle différente (par opération, pas par chaîne de délégation).
  Pas de résultat de vérification mécanisée revendiqué dans les sources
  consultées.

**Aucun des quatre ne traite SUDP ni la non-exposition du secret au
requester** : la revendication de nouveauté de ce travail (première
mécanisation de SUDP spécifiquement, voir ci-dessus) reste inchangée par
leur ajout — ils élargissent le paysage des protocoles de délégation
agentique comparables, sans réduire le périmètre propre à SUDP.

## Vérification de l'existence d'une version SUDP v4

**Aucune v4 retrouvée** à la date du 03/10/2026 : arXiv:2604.24920 n'a que
trois versions publiées (v1 27/04/2026, v2 01/05/2026, v3 22/05/2026 — la
version étudiée par ce projet). Toute nouvelle vérification devra être
refaite si une v4 apparaît avant le 22/10 ; à recontrôler avant dépôt final.

# Dossier de reproductibilité

```
reproducibility/
├── run_all.sh              # tout reproduire depuis un checkout propre
├── toolchain/
│   ├── setup_toolchain.sh  # installe tamarin-prover 1.12.0 + Maude 3.2, localement, sans sudo
│   └── env.sh              # généré par setup_toolchain.sh ; à sourcer avant tamarin-prover
├── logs/                   # sorties texte complètes de tamarin-prover --prove
└── traces/                 # traces exportées en JSON (--output-json)
```

## Reproduire tous les résultats

```bash
bash reproducibility/run_all.sh
```

Ce script installe la chaîne d'outils si nécessaire (aucune modification
système : tout est extrait sous `~/.local/`, aucun `sudo`), puis relance
exactement les deux commandes dont les logs sont archivés dans `logs/` :

```bash
tamarin-prover --prove models/phase2-grant-authorization/sudp_phase2.spthy \
  --output-json=reproducibility/traces/phase2_base.json

tamarin-prover --prove models/phase2-grant-authorization/hypothesis-necessity/sudp_phase2_weak_channel.spthy \
  --output-json=reproducibility/traces/phase2_weak_channel.json
```

## Pourquoi une installation locale plutôt qu'un paquet système

`tamarin-prover` n'est pas empaqueté pour Ubuntu ; `maude` l'est mais son
paquet n'a jamais été mis à jour vers une version explicitement supportée
par Tamarin 1.12.0 (Tamarin liste 2.7.1–3.5.1 comme testées ; Ubuntu 24.04
fournit 3.2, non listée mais fonctionnellement compatible — un avertissement
« unsupported version » apparaît au lancement, sans effet sur les preuves
obtenues, comme le confirme le test croisé ci-dessous). `setup_toolchain.sh`
télécharge le binaire officiel de Tamarin et extrait le `.deb` Maude
d'Ubuntu 24.04 (`noble`) sans les installer au niveau système, pour rester
reproductible sans droits root et sans modifier l'environnement partagé.

## Contrôle de cohérence effectué

Avant d'archiver les logs ci-dessus, la chaîne d'outils a été validée par
un test en trois temps :
1. `tamarin-prover --prove` sur le modèle de base → 5/5 lemmes vérifiés,
   y compris `executable` (condition nécessaire, méthodologie étape 1).
2. Correction d'un avertissement de bonne formation (`wellformedness`) sur
   la règle `Custodian_Redeem_Success` initiale (correspondance de motif
   profonde sur la clé de signature) via l'idiome standard
   `verify(...)=true` + `restriction Equality` — voir historique du fichier
   `.spthy` — puis re-vérification : 5/5 lemmes, **zéro avertissement**.
3. Variante `hypothesis-necessity/` (canal II.2 non confidentiel) → CRC et
   AV tombent avec un contre-exemple concret, confirmant que les lemmes du
   modèle de base ne sont pas vrais indépendamment de leurs hypothèses.

## Versions exactes

Voir [`../docs/sources.md`](../docs/sources.md) pour le papier SUDP, le
commit du dépôt de référence, et les versions de Tamarin/Maude.

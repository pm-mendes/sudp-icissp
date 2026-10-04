#!/usr/bin/env bash
# Reproduces every Tamarin result claimed in docs/traceability.md and
# docs/comparison-saga-aith.md from a clean checkout.
#
# Usage: bash reproducibility/run_all.sh
set -euo pipefail
cd "$(dirname "$0")/.."

if ! command -v tamarin-prover >/dev/null 2>&1; then
  echo "tamarin-prover not on PATH -- installing a local toolchain..."
  bash reproducibility/toolchain/setup_toolchain.sh
fi
# shellcheck disable=SC1091
source reproducibility/toolchain/env.sh

tamarin-prover --version

mkdir -p reproducibility/logs reproducibility/traces

echo "== Phase II base model =="
tamarin-prover --prove models/phase2-grant-authorization/sudp_phase2.spthy \
  --output-json=reproducibility/traces/phase2_base.json \
  | tee reproducibility/logs/phase2_full_run.log

echo "== Phase II, weakened II.2 channel (hypothesis-necessity variant) =="
tamarin-prover --prove models/phase2-grant-authorization/hypothesis-necessity/sudp_phase2_weak_channel.spthy \
  --output-json=reproducibility/traces/phase2_weak_channel.json \
  | tee reproducibility/logs/phase2_weak_channel_run.log
tamarin-prover --prove=CRC_wrapping_key_secrecy \
  models/phase2-grant-authorization/hypothesis-necessity/sudp_phase2_weak_channel.spthy \
  --output-dot=reproducibility/traces/phase2_weak_channel_CRC.dot >/dev/null

echo "== Phase III, budget d'exécution (axe 2 : budgets/concurrence) =="
for variant in N1_atomic N1_nonatomic N2_atomic N2_nonatomic; do
  echo "-- ${variant} --"
  tamarin-prover --prove "models/phase3-budget/sudp_phase3_budget_${variant}.spthy" \
    --output-json="reproducibility/traces/phase3_${variant}.json" \
    | tee "reproducibility/logs/phase3_${variant}_run.log"
done

echo "== Done. Expected:"
echo "   Phase II base: 3 propriétés + 1 partielle vérifiées, executable vérifié (contrôle, pas une propriété)."
echo "   Phase II canal affaibli: CRC_wrapping_key_secrecy et AV_authorization_verifiability FALSIFIÉS."
echo "   Phase III N1/N2 atomique: UB vérifié. Phase III N1/N2 non atomique: UB FALSIFIÉ (contre-exemple de nécessité)."
echo "   Détail et lien à chaque propriété : docs/traceability.md"

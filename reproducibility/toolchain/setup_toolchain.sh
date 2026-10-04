#!/usr/bin/env bash
# Installs tamarin-prover 1.12.0 + Maude 3.2 into a self-contained,
# user-local prefix (no root, no system package install). Reproduces the
# exact toolchain used to produce the traces under reproducibility/logs/.
#
# Usage:
#   bash reproducibility/toolchain/setup_toolchain.sh
#   source reproducibility/toolchain/env.sh
#   tamarin-prover --version
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PREFIX="${TAMARIN_LOCAL_PREFIX:-$HOME/.local}"
WORK="$(mktemp -d)"
trap 'rm -rf "$WORK"' EXIT

TAMARIN_VERSION="1.12.0"
TAMARIN_URL="https://github.com/tamarin-prover/tamarin-prover/releases/download/${TAMARIN_VERSION}/tamarin-prover-${TAMARIN_VERSION}-linux64-ubuntu.tar.gz"

echo "== Installing tamarin-prover ${TAMARIN_VERSION} into ${PREFIX} =="
mkdir -p "${PREFIX}/tamarin"
curl -sL -o "${WORK}/tamarin.tar.gz" "${TAMARIN_URL}"
tar xzf "${WORK}/tamarin.tar.gz" -C "${PREFIX}/tamarin"
chmod +x "${PREFIX}/tamarin/tamarin-prover"
mkdir -p "${PREFIX}/bin"
ln -sf "${PREFIX}/tamarin/tamarin-prover" "${PREFIX}/bin/tamarin-prover"

echo "== Installing Maude (Ubuntu 24.04 'noble' packages, extracted locally) =="
cd "${WORK}"
apt-get download \
  maude \
  libgmpxx4ldbl \
  libbdd0c2 \
  libtecla1t64 \
  libsigsegv2
mkdir -p "${WORK}/extract"
for deb in *.deb; do
  dpkg -x "${deb}" "${WORK}/extract"
done

mkdir -p "${PREFIX}/lib" "${PREFIX}/share/maude"
cp -a "${WORK}/extract/usr/lib/x86_64-linux-gnu/"*.so* "${PREFIX}/lib/"
cp "${WORK}/extract/usr/bin/maude" "${PREFIX}/bin/maude"
cp "${WORK}/extract/usr/share/maude/prelude.maude" "${PREFIX}/share/maude/"
chmod +x "${PREFIX}/bin/maude"

cat > "${SCRIPT_DIR}/env.sh" <<EOF
# Source this file before invoking tamarin-prover.
export PATH="${PREFIX}/bin:\$PATH"
export LD_LIBRARY_PATH="${PREFIX}/lib:\${LD_LIBRARY_PATH:-}"
export MAUDE_LIB="${PREFIX}/share/maude"
EOF

echo "== Done. Run: source ${SCRIPT_DIR}/env.sh =="

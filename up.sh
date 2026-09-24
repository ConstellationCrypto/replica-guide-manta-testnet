#!/usr/bin/env bash

set -eu

if [ -f .env ]; then
  set -a
  # shellcheck disable=SC1091
  source .env
  set +a
fi

if [ -z "${L1_RPC_URL:-}" ]; then
  echo "Set L1_RPC_URL in the environment or in .env (see .env.example)." >&2
  exit 1
fi

export L1_RPC_URL

if [ ! -f jwt-secret.txt ]; then
  openssl rand -hex 32 > jwt-secret.txt
fi

if [ ! -f p2p-node-key.txt ]; then
  openssl rand -hex 32 > p2p-node-key.txt
fi

echo "Bringing up Manta Sepolia replica (op-reth + AltDA)..."
docker compose up -d

echo "L2 RPC:             http://localhost:${OP_RETH_RPC_PORT:-8545}"
echo "op-node rollup RPC: http://localhost:${OP_NODE_RPC_HOST_PORT:-7545}"

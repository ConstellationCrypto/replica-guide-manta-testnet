# manta-sepolia Replica Guide

op-reth replica (AltDA) using [docker-compose.yml](docker-compose.yml) with:

- **op-reth** `public.ecr.aws/i6b2w2n6/op-reth:v2.3.1`
- **op-node** `public.ecr.aws/i6b2w2n6/op-node:1.16.1-celestia-e9ec322-altda` ([AltDA mode](https://docs.optimism.io/builders/chain-operators/features/alt-da-mode))
- **op-alt-da** `public.ecr.aws/i6b2w2n6/op-alt-da:v0.15.0-11cc587` ([celestiaorg/op-alt-da](https://github.com/celestiaorg/op-alt-da))

Celestia namespace: `ca1de12a2f7443cbfbb5` (29-byte v0 form in config: `00000000000000000000000000000000000000ca1de12a2f7443cbfbb5`).

op-reth peers with Caldera's replica over execution-layer p2p (`--trusted-peers` in [docker-compose.yml](docker-compose.yml), port `30303`). op-node peers with it over `--p2p.static` (port `9003`). Both directions need outbound TCP from the host.

## Datadir snapshot (recommended)

Download and extract into `./datadir` before the first start:

https://constellationlabs-dashboard-beta.s3.amazonaws.com/bedrock-manta-sepolia-reth-2026-May-14.tar

## Configure op-alt-da

Edit [op-alt-da-config.toml](op-alt-da-config.toml): set Celestia bridge gRPC URL and auth token for read-only access.

## Run

`L1_RPC_URL` must point at Ethereum Sepolia (chain id `11155111`).

```bash
cp .env.example .env   # set L1_RPC_URL
make up
# or without make: bash ./up.sh
```

Stop:

```bash
make down
```

## Query

L2 RPC (default op-reth port `8545`):

```bash
RPC_URL=http://localhost:8545
curl $RPC_URL -X POST -H "Content-Type: application/json" --data \
    '{"jsonrpc":"2.0","method":"eth_chainId","params":[],"id":1}'
```

Rollup sync status (default op-node port `7545`):

```bash
RPC_URL=http://localhost:7545
curl $RPC_URL -X POST -H "Content-Type: application/json" --data \
    '{"jsonrpc":"2.0","method":"optimism_syncStatus","params":[],"id":1}' | jq .
```

or `bash progress.sh`

## Celestia upgrades

Please refer to celestia docs for network upgrades: https://docs.celestia.org/how-to-guides/participate#network-upgrades

## In case of problems

The deployed Manta Sepolia network runs `op-alt-da:0.12.0`. This guide pins the newer `v0.15.0-11cc587`, which is the version the guide was written and tested against. If op-alt-da fails to start or cannot read blobs, try `public.ecr.aws/i6b2w2n6/op-alt-da:0.12.0` in [docker-compose.yml](docker-compose.yml). The config file format may differ between the two versions.

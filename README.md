# manta-sepolia Replica Guide

op-reth replica (AltDA) using [docker-compose.yml](docker-compose.yml) with:

- **op-reth** `public.ecr.aws/i6b2w2n6/op-reth:v2.3.1`
- **op-node** `public.ecr.aws/i6b2w2n6/op-node:1.16.1-celestia-e9ec322-altda` ([AltDA mode](https://docs.optimism.io/builders/chain-operators/features/alt-da-mode))
- **op-alt-da** `public.ecr.aws/i6b2w2n6/op-alt-da:v0.15.0-11cc587` ([celestiaorg/op-alt-da](https://github.com/celestiaorg/op-alt-da))

Celestia namespace: `ca1de12a2f7443cbfbb5` (29-byte v0 form in config: `00000000000000000000000000000000000000ca1de12a2f7443cbfbb5`).

## How the replica syncs

Two independent data paths, both preconfigured:

**Following the chain head.** op-node receives new blocks over the OP Stack p2p network from Caldera's replica (`--p2p.static`, port `9003`). op-reth pulls the block bodies and state it is missing over execution-layer p2p from the same replica (`--trusted-peers`, port `30303`). op-node runs `--syncmode=execution-layer`, so after a restart or when starting from a snapshot, op-reth catches up to the head through this path rather than re-executing from L1.

**Verifying against L1.** op-node independently derives the chain from Sepolia batch data. Batch contents live on Celestia. op-alt-da fetches them, from Celestia if you configure a bridge, otherwise from Caldera's public S3 cache. This path advances the `safe` head. It is slow and is not what makes the replica usable; the p2p path is.

Both need outbound TCP from the host.

## Datadir snapshot (required)

Download and extract into `./datadir` before the first start:

https://constellationlabs-dashboard-beta.s3.amazonaws.com/bedrock-manta-sepolia-reth-2026-May-14.tar

Manta Sepolia changed its data-availability format early in its life. The current op-node cannot derive the early blocks, so a sync from genesis will not complete. The snapshot starts after the change.

## DA reads

By default op-alt-da reads batch data from Caldera's public S3 cache. No credentials are needed and the cache holds the chain's full history. This is the recommended setup.

You can instead read from your own Celestia Mocha node by uncommenting and setting `bridge_addr` and `bridge_auth_token` in [op-alt-da-config.toml](op-alt-da-config.toml). Only do this with an archival node. Celestia nodes prune blobs older than the sampling window, and op-alt-da treats a Celestia "not found" as final without consulting S3, so a pruned node breaks derivation of anything older than that window.

## Run

`L1_RPC_URL` must point at Ethereum Sepolia (chain id `11155111`).

```bash
cp .env.example .env   # set L1_RPC_URL
make up
# or without make: bash ./up.sh
```

`up.sh` generates `jwt-secret.txt` and `p2p-node-key.txt` on first run. Keep them out of version control.

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

`unsafe_l2` tracks the chain head via p2p. `safe_l2` tracks L1 derivation and lags behind; that is expected.

Catch-up progress: `bash progress.sh`

## Apple Silicon

The images are amd64 only and run under Rosetta. Rosetta miscomputes one of the ciphers libp2p uses, which breaks every op-node peer connection. The compose file sets `GODEBUG=cpu.avx2=off` on op-node to work around it. It is harmless on other hosts.

## Celestia upgrades

Please refer to celestia docs for network upgrades: https://docs.celestia.org/how-to-guides/participate#network-upgrades

## In case of problems

The deployed Manta Sepolia network runs `op-alt-da:0.12.0`. This guide pins the newer `v0.15.0-11cc587`, which is the version the guide was written and tested against. If op-alt-da fails to start or cannot read blobs, try `public.ecr.aws/i6b2w2n6/op-alt-da:0.12.0` in [docker-compose.yml](docker-compose.yml). The config file format may differ between the two versions.

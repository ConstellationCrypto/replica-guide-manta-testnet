# manta-sepolia Replica Guide

1. Set `L1_RPC_URL` in `up.sh`
2. Run `make up`.

# Latest snapshot
https://constellationlabs-dashboard-beta.s3.amazonaws.com/manta-testnet-12-05-2025.tar.gz

# Commands:

```
make up
make down
make clean
```

To query the RPC:

```
RPC_URL=http://localhost:8545
curl $RPC_URL -X POST -H "Content-Type: application/json" --data \
    '{"jsonrpc":"2.0","method":"eth_chainId","params":[],"id":1}'
```

To check on the sync status of the node:

```
RPC_URL=http://localhost:7545
curl $RPC_URL -X POST -H "Content-Type: application/json" --data \
    '{"jsonrpc":"2.0","method":"optimism_syncStatus","params":[],"id":1}' | jq .
```

or `bash progress.sh`

## op-reth replica (AltDA)

Uses [docker-compose-reth.yml](docker-compose-reth.yml) with:

- **op-reth** `public.ecr.aws/i6b2w2n6/op-reth:v2.2.3`
- **op-node** `public.ecr.aws/i6b2w2n6/op-node:1.16.1-celestia-e9ec322-altda` ([AltDA mode](https://docs.optimism.io/builders/chain-operators/features/alt-da-mode))
- **op-alt-da** `public.ecr.aws/i6b2w2n6/op-alt-da:v0.15.0-11cc587` ([celestiaorg/op-alt-da](https://github.com/celestiaorg/op-alt-da))

Celestia namespace: `ca1de12a38532b871dac` (29-byte v0 form in config: `00000000000000000000000000000000000000ca1de12a38532b871dac`).

### Reth datadir snapshot (recommended)

Download and extract into `./reth_data` before the first start:

https://constellationlabs-dashboard-beta.s3.amazonaws.com/manta-testnet-12-05-2025.tar.gz

### Configure op-alt-da

Edit [op-alt-da-config.toml](op-alt-da-config.toml): set Celestia bridge gRPC URL and auth token for read-only access.

### Run

`L1_RPC_URL` must point at Ethereum Sepolia (chain id `11155111`).

```bash
cp .env.example .env   # set L1_RPC_URL
make reth-up
# or: export L1_RPC_URL=<sepolia-rpc> && docker compose -f docker-compose-reth.yml up -d
```

Rollup sync status (default op-node port `27545`):

```bash
RPC_URL=http://localhost:27545 bash progress.sh
```

    make reth-down

# Celestia upgrades
Please refer to celestia docs for network upgrades: https://docs.celestia.org/how-to-guides/participate#network-upgrades

# Pie Tactic Model — Evaluation

Offline evaluation of a LoRA fine-tuned **Qwen2.5-Coder-7B** tactic predictor for the [Pie](https://github.com/timthedev07/trypieagain) proof assistant.

## Requirements

- Docker with the [NVIDIA Container Toolkit](https://docs.nvidia.com/datacenter/cloud-native/container-toolkit/install-guide.html) installed
- An NVIDIA GPU with CUDA 12.4+ support
- ~15 GB free disk space (image ~10 GB + base model ~4 GB cached on first run)

## Run

```bash
docker compose -f docker-compose.run.yml run pie-model
```

The base model (`unsloth/qwen2.5-coder-7b-instruct-bnb-4bit`) is downloaded from HuggingFace on first run into a named Docker volume and reused on subsequent runs.

### Options

```bash
# Show per-step predictions
docker compose -f docker-compose.run.yml run pie-model --verbose

# Limit to the first N proofs
docker compose -f docker-compose.run.yml run pie-model --max-examples 10

# Save detailed results to a JSON file on the host
docker compose -f docker-compose.run.yml \
  run -v "$PWD/results:/out" pie-model \
  --output /out/results.json
```

## Metrics reported

| Metric               | Description                                                            |
| -------------------- | ---------------------------------------------------------------------- |
| **Exact match**      | Predicted tactic == gold tactic (string-exact)                         |
| **Tactic head**      | Correct tactic name, ignoring arguments                                |
| **Category**         | Correct tactic category (introduction / elimination / …)               |
| **Proof completion** | All steps of a proof are exact-match correct (pessimistic lower bound) |

Results are broken down by difficulty (easy / medium / hard) and per tactic name.

## Model details

|                |                                                                                 |
| -------------- | ------------------------------------------------------------------------------- |
| Base model     | `unsloth/qwen2.5-coder-7b-instruct-bnb-4bit`                                    |
| Adapter        | LoRA (r=32, α=64, dropout=0.05)                                                 |
| Quantisation   | 4-bit NF4 (bitsandbytes)                                                        |
| Target modules | q/k/v/o projections + gate/up/down projections                                  |
| Test set       | `test-even-or-odd-holdout.jsonl` (even-or-odd theorems, held out from training) |

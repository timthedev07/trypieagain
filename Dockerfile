# ── Stage: inference image ────────────────────────────────────────────────────
# pytorch/pytorch already ships Python 3.11 + PyTorch built against CUDA 12.4,
# so we skip the heavyweight conda setup entirely.
FROM pytorch/pytorch:2.5.1-cuda12.4-cudnn9-runtime

# ── Image metadata ───────────────────────────────────────────────────────────
LABEL org.opencontainers.image.title="pie-model"
LABEL org.opencontainers.image.description="Offline evaluation of a LoRA fine-tuned Qwen2.5-Coder-7B tactic predictor for the Pie proof assistant"
LABEL org.opencontainers.image.source="https://github.com/timthedev07/trypieagain"
LABEL org.opencontainers.image.base.name="pytorch/pytorch:2.5.1-cuda12.4-cudnn9-runtime"

# ── Environment ───────────────────────────────────────────────────────────────
ENV PYTHONUNBUFFERED=1 \
    # HuggingFace will cache model weights here; mount a volume to persist them
    HF_HOME=/app/hf_cache \
    # Silence the "running as root" HF warning inside containers
    TRANSFORMERS_VERBOSITY=error

WORKDIR /app

# ── System dependencies ───────────────────────────────────────────────────────
RUN apt-get update && apt-get install -y --no-install-recommends \
        git \
        ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# ── Python dependencies ───────────────────────────────────────────────────────
# torch / torchvision are already in the base image; list only what we add.
COPY docker-requirements.txt .
RUN pip install --no-cache-dir -r docker-requirements.txt

# ── Application code & adapter ───────────────────────────────────────────────
COPY evaluate_offline.py .
COPY test-even-or-odd-holdout.jsonl .
COPY adapter/ ./adapter/

# ── Default command ───────────────────────────────────────────────────────────
# The base model (unsloth/qwen2.5-coder-7b-instruct-bnb-4bit) is ~4 GB and is
# downloaded on first run into the HF_HOME volume so it is not re-fetched on
# every container restart.
#
# Override CMD at runtime to pass extra flags, e.g.:
#   docker run ... pie-model --verbose --max-examples 5
CMD ["python", "evaluate_offline.py", \
     "--adapter", "/app/adapter", \
     "--test-proofs", "/app/test-even-or-odd-holdout.jsonl"]

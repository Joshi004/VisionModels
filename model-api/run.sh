#!/usr/bin/env bash
# run.sh - Launch the shared model-api server inside a tmux session so it
# survives an SSH disconnect (the same pattern generate.sh recommends for
# long jobs).
#
# Safe to re-run: attaches to the existing session instead of starting a
# second one if it's already up.
#
# Env overrides:
#   MODEL_API_HOST, MODEL_API_PORT        (default 0.0.0.0:8012)
#   MODEL_API_FALLBACK_PARTITION          (default "background")
#   MODEL_API_MAX_INFLIGHT                (optional soft concurrency cap, global across backends)
#   MODEL_API_RETENTION_DAYS              (finished job cleanup, default 7)
#   MODEL_API_DISABLE_AUTH                (skip bearer-token auth entirely -- defaults to 1/on
#                                           below, since this deployment is on a trusted network;
#                                           set to 0 before running this script to require the
#                                           bearer token again)
#
#   LTX_MEM_PER_GPU, LTX_CPUS, LTX_API_TIME   (LTX-2.3 backend's own Slurm allocation shape)
#   WAN_ANIMATE_PROJECT_ROOT                          (default /home/naresh/Vision/ModelService_Wan-Animate-2/v1)
#   WAN_ANIMATE_MEM_PER_GPU, WAN_ANIMATE_CPUS, WAN_ANIMATE_API_TIME   (Wan-Animate v1's own Slurm allocation shape)
#
#   PARAKEET_PROJECT_ROOT                             (default /home/naresh/Vision/ModelService_Parakeet)
#   PARAKEET_MEM_PER_GPU, PARAKEET_CPUS, PARAKEET_JOB_TIME   (Parakeet backend's own Slurm allocation shape)
set -euo pipefail

# Auth defaults to disabled (see the header comment above) -- only takes
# effect if the caller hasn't already set this var to something else.
export MODEL_API_DISABLE_AUTH="${MODEL_API_DISABLE_AUTH:-1}"

API_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SESSION="model-api"

if tmux has-session -t "$SESSION" 2>/dev/null; then
  echo "Session '$SESSION' is already running. Attaching (Ctrl-b d to detach without stopping it)..."
  exec tmux attach -t "$SESSION"
fi

tmux new-session -d -s "$SESSION" \
  "cd '$API_DIR' && '$API_DIR/venv/bin/uvicorn' server:app --host \"\${MODEL_API_HOST:-0.0.0.0}\" --port \"\${MODEL_API_PORT:-8012}\"; exec bash"

echo "Started in tmux session '$SESSION'."
echo "Attach:  tmux attach -t $SESSION   (Ctrl-b d to detach without stopping it)"
echo "Stop:    tmux kill-session -t $SESSION"
if [ "$MODEL_API_DISABLE_AUTH" = "1" ]; then
  echo "Auth:    DISABLED (MODEL_API_DISABLE_AUTH=1) -- no bearer token required on any endpoint."
else
  echo "Bearer token file: $API_DIR/secrets/api_token.txt"
fi
if [ -d "$API_DIR/ui/dist" ]; then
  echo "Web UI:  http://localhost:${MODEL_API_PORT:-8012}/ui/  (after tunneling, e.g. ssh -L 8012:localhost:8012 ...)"
else
  echo "Web UI:  not built yet -- see ui/README.md (cd ui && npm install && npm run build), then restart this script."
fi

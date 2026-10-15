#!/bin/bash
# hookscript VM 100 (Games): $1=vmid $2=fase
case "$2" in
pre-start)
  if pct status 103 2>/dev/null | grep -q running; then
    echo "Desligue o CT ollama (103) primeiro: a GPU esta em uso por ele." >&2; exit 1
  fi
  /usr/local/sbin/gpu-to-vfio.sh || exit 1 ;;
esac
exit 0

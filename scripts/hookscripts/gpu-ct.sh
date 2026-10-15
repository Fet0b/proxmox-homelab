#!/bin/bash
# hookscript CT 103 (ollama): $1=vmid $2=fase
case "$2" in
pre-start)
  if qm status 100 2>/dev/null | grep -q running; then
    echo "Desligue a VM Games (100) primeiro: a GPU esta em uso por ela." >&2; exit 1
  fi
  /usr/local/sbin/gpu-to-nvidia.sh || exit 1 ;;
post-stop) /usr/local/sbin/gpu-to-vfio.sh ;;
esac
exit 0

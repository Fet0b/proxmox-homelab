#!/bin/bash
# Move a GPU (07:00.0/.1) de vfio-pci para nvidia (uso pelo CT ollama). Idempotente.
exec 9>/run/gpu-switch.lock; flock 9
set -e
GPU=0000:07:00.0; AUD=0000:07:00.1
drv() { basename "$(readlink /sys/bus/pci/devices/$1/driver 2>/dev/null)" 2>/dev/null || true; }
if [ "$(drv $GPU)" = nvidia ]; then exit 0; fi
for d in $GPU $AUD; do
  [ -e /sys/bus/pci/devices/$d/driver ] && echo $d > /sys/bus/pci/devices/$d/driver/unbind
done
echo nvidia > /sys/bus/pci/devices/$GPU/driver_override
modprobe nvidia
modprobe nvidia_uvm
echo $GPU > /sys/bus/pci/drivers_probe
echo vfio-pci > /sys/bus/pci/devices/$AUD/driver_override
echo $AUD > /sys/bus/pci/drivers_probe
[ "$(drv $GPU)" = nvidia ] || { echo "falha ao ligar nvidia" >&2; exit 1; }
nvidia-modprobe -u -c0

#!/bin/bash
# Devolve a GPU ao vfio-pci (uso pela VM Games). Idempotente.
exec 9>/run/gpu-switch.lock; flock 9
GPU=0000:07:00.0; AUD=0000:07:00.1
drv() { basename "$(readlink /sys/bus/pci/devices/$1/driver 2>/dev/null)" 2>/dev/null || true; }
if [ "$(drv $GPU)" = vfio-pci ] && ! lsmod | grep -q '^nvidia'; then exit 0; fi
if lsmod | grep -q '^nvidia_uvm'; then rmmod nvidia_uvm; fi
for m in nvidia_modeset nvidia; do lsmod | grep -q "^$m " && rmmod $m; done
for d in $GPU $AUD; do
  [ -e /sys/bus/pci/devices/$d/driver ] && echo $d > /sys/bus/pci/devices/$d/driver/unbind
  echo vfio-pci > /sys/bus/pci/devices/$d/driver_override
  echo $d > /sys/bus/pci/drivers_probe
done
[ "$(drv $GPU)" = vfio-pci ]

# Docker rootless em LXC não privilegiado

O CT 152 (`development`) é um ambiente de desenvolvimento com **dois usuários isolados**. Cada um tem seu próprio daemon Docker rootless, `~/.config` separado e CLIs distintas (CLIs de nuvem e Git distintas em cada um).

## Por que rootless dentro de um LXC

Docker rootless precisa de uma faixa grande de UIDs subordinados (`/etc/subuid`). Num CT não privilegiado, o `root` do container só enxerga os UIDs que o host mapeia — o padrão (65536) é pouco para 2 usuários com subuid cada.

## O que foi feito

1. **Host** — ampliar a faixa de subuid/subgid do root:
   ```
   # /etc/subuid e /etc/subgid
   root:100000:196608
   ```
2. **CT** — `idmap` com a faixa ampliada, TUN para rede e `keyctl`:
   ```
   features: nesting=1,keyctl=1
   lxc.idmap: u 0 100000 196608
   lxc.idmap: g 0 100000 196608
   lxc.cgroup2.devices.allow: c 10:200 rwm
   lxc.mount.entry: /dev/net/tun dev/net/tun none bind,create=file
   ```
   Veja o arquivo completo em [config/guests/ct-152.conf](../config/guests/ct-152.conf).
3. **Dentro do CT** — instalar `uidmap`, `dbus-user-session`, `slirp4netns`, habilitar *linger* e rodar `dockerd-rootless-setuptool.sh install` em cada usuário.
4. **AppArmor** — o perfil `rootlesskit` do Ubuntu 24.04 bloqueava a rede do daemon rootless; foi desativado **somente dentro do CT**. É um trade-off consciente: o isolamento continua garantido por user namespaces e pelo CT não privilegiado.

## Verificação

```bash
sudo -iu dev1 docker run --rm hello-world
sudo -iu dev2 docker compose up -d
```

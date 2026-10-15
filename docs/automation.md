# Automação

## Terraform (`bpg/proxmox`)

Veja [terraform/](../terraform). Pontos-chave:

- Autenticação por **token de API** via `PROXMOX_VE_API_TOKEN` — nada de segredo no código.
- Senha de root gerada com `random_password` e exposta como output `sensitive`.
- Chave SSH pública injetada em `initialization.user_account.keys`.
- O estado (`*.tfstate`) contém segredos: **não versionar**. Veja o `.gitignore`.
- Nota prática: o resolver em Go (usado pelo Terraform) pode falhar com DNS de Tailscale/roteador; contornei rodando o comando num *mount namespace* com `resolv.conf` alternativo (`unshare -m` + `mount --bind`).

## Bot do Telegram

Um bot em Python (somente biblioteca padrão) controla o host por chats autorizados (`TG_ALLOWED`):

| Comando | Ação |
|---------|------|
| `/status`, `/temp` | carga, memória, uptime, estado da GPU e temperaturas (`k10temp`, `nvme`, `nvidia-smi`) |
| `/ollama`, `/games` | desliga um e liga o outro, acionando a troca de GPU |
| `/start`, `/stop`, `/reboot`, `/forcestop ID` | controla qualquer convidado via `pvesh`/`qm`/`pct` |
| `/hostreboot`, `/hostshutdown` | host (com confirmação por botão) |

Roda como serviço systemd com `EnvironmentFile` (token fora do código) e `python3 -I` (modo isolado).

## Patch de temperatura na UI

[scripts/ui/pve-thermal-patch.sh](../scripts/ui/pve-thermal-patch.sh) adiciona ao `Nodes.pm` e ao `pvemanagerlib.js` um campo *Temperatura* lendo `/sys/class/hwmon` (`k10temp`/`coretemp`). É idempotente (marcador `PATCH-THERMAL`) e deve ser reexecutado após upgrades do `pve-manager`. Guarde cópias `.orig` dos arquivos antes.

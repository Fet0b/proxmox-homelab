# Backup e energia

## Backup

Job `vzdump` diário (ver [config/host/jobs.cfg](../config/host/jobs.cfg)):

```
vzdump: backup-development
	schedule 21:00
	mode snapshot
	compress zstd
	prune-backups keep-daily=3,keep-weekly=2
	storage local
	vmid 152
```

- `snapshot` mantém o CT no ar; o `local-lvm` (LVM-thin) torna isso barato.
- Um backup de teste de ~1,2 GB cabe confortavelmente na retenção de 3 diários + 2 semanais.
- **Limitação conhecida:** o destino (`local`) está no **mesmo disco** do PVE. Protege de erro humano, **não de falha de disco**. Próximo passo: PBS ou `rclone` para nuvem/outro host.

## Armazenamento

| Storage | Tipo | Conteúdo | Tamanho |
|---------|------|----------|---------|
| `local` | dir (`/var/lib/vz`) | ISO, templates, backups, snippets | ~94 GB |
| `local-lvm` | LVM-thin | discos de VMs/CTs | ~338 GB |

Disco único de 500 GB com *thin provisioning* — a soma dos discos alocados passa do físico, então vale **monitorar o uso do pool** (`lvs`, `pvesm status`).

## Desligar à noite, ligar às 06:00

Para economizar energia, o host pode desligar à noite e ser acordado pelo RTC:

```bash
rtcwake -m off -t $(date -d 'tomorrow 06:00' +%s)
```

Pontos de atenção:
- Gravar e ler o alarme **não prova** que o firmware liga a partir de S5. Teste uma vez com acesso físico.
- Se não subir, habilite *RTC Alarm / Resume by Alarm* na BIOS e/ou **Wake-on-LAN**: `ethtool -s nic0 wol g` (persistir em `/etc/network/interfaces` com `post-up`).
- Agende o desligamento **depois** do backup (21:00), por exemplo às 23:00.
- Antes de desligar, lembre que o **Pi-hole** (DNS da casa) fica fora do ar; defina um DNS secundário no roteador.

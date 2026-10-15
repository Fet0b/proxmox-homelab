# Lições aprendidas

- **`driver_override` > blacklist dinâmica**: trocar o driver da GPU em tempo de execução é confiável se você descarregar na ordem certa (`uvm` → `modeset` → `nvidia`).
- **Exclusão mútua explícita nos hooks** evita o pior cenário (dois convidados brigando pela mesma GPU) e dá uma mensagem útil ao usuário.
- **Rede em 100 Mb/s**: `ethtool nic0` reporta 100 Mb/s — provável cabo/porta; vale checar antes de culpar o software por transferências lentas.
- **HDD único** com *thin pool*: acompanhe o espaço e planeje um segundo disco (idealmente SSD) e backup externo.
- **Dois usuários, dois daemons**: Docker rootless dá isolamento real entre contextos distintos sem VMs extras.
- **AppArmor `rootlesskit`** no Ubuntu 24.04 quebra a rede do Docker rootless em LXC; desativar dentro do CT resolve.
- **Não confie só no RTC** para ligar a máquina — teste com acesso físico.
- **Segredos fora do repo**: tokens por env/`EnvironmentFile`, `tfstate` no `.gitignore`.

## Roadmap

- [ ] Backup externo (PBS/rclone) e teste de restauração
- [ ] Segundo disco (SSD) e migração do `local-lvm`
- [ ] Monitoramento (Prometheus + Grafana) com alertas pelo Telegram
- [ ] Persistir WoL e rotina de desligamento noturno
- [ ] Mover o Terraform de todos os CTs para um único módulo

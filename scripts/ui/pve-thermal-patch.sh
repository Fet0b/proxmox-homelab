#!/bin/bash
# Reaplica o patch de temperatura no Summary do PVE (idempotente). Rode apos upgrades do pve-manager.
set -e
PM=/usr/share/perl5/PVE/API2/Nodes.pm
JS=/usr/share/pve-manager/js/pvemanagerlib.js
if ! grep -q 'PATCH-THERMAL' $PM; then
python3 - <<'PY'
p='/usr/share/perl5/PVE/API2/Nodes.pm'
s=open(p).read()
a="        $res->{cpuinfo} = PVE::ProcFSTools::read_cpuinfo();\n"
b=a+r'''
        # PATCH-THERMAL
        eval {
            my @t;
            for my $h (sort glob("/sys/class/hwmon/hwmon*")) {
                my $n = PVE::Tools::file_read_firstline("$h/name") // next;
                next if $n !~ /^(k10temp|coretemp)$/;
                my $v = PVE::Tools::file_read_firstline("$h/temp1_input") // next;
                push @t, sprintf("%s %.1f \x{b0}C", (PVE::Tools::file_read_firstline("$h/temp1_label") // 'CPU'), $v/1000);
            }
            $res->{thermal} = join(' / ', @t) if @t;
        };
'''
assert a in s
open(p,'w').write(s.replace(a,b,1))
PY
perl -I/usr/share/perl5 -c $PM
fi
if ! grep -q "PATCH-THERMAL" $JS; then
python3 - <<'PY'
p='/usr/share/pve-manager/js/pvemanagerlib.js'
s=open(p).read()
a="""            textField: 'cpuinfo',
            renderer: Proxmox.Utils.render_cpu_model,
            value: '',
        },
"""
b=a+"""        {
            // PATCH-THERMAL
            itemId: 'thermal',
            colspan: 2,
            printBar: false,
            title: gettext('Temperatura'),
            textField: 'thermal',
            renderer: (v) => v || '-',
            value: '',
        },
"""
assert s.count(a)==1
open(p,'w').write(s.replace(a,b,1))
PY
fi
systemctl restart pvedaemon pveproxy pvestatd

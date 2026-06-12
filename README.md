# lan-playground

SRCDS LAN Playground with [bhoptimer](https://github.com/shavitush/bhoptimer).

## Host Requirements

- [Vagrant](https://www.vagrantup.com/)
- [VirtualBox](https://www.virtualbox.org/)
- [Task](https://taskfile.dev/)

## Setup

```sh
git clone https://github.com/happydez/lan-playground.git
cd lan-playground

task gen-key   # generate ssh keys into ./files (one time)
task up        # bring up both VMs (controlnode, lan)
task site      # install ansible collections on controlnode and run site.yml

task halt      # stop the VMs after playing (without destroying them)
    OR
task destroy   # destroy the VMs completely (you'll have to set everything up again)
```

Default controlnode server IP: `192.168.128.64`  
Default lan server IP: `192.168.128.32`

**Whitelist/Admin access**: Add your SteamID to
`ansible/server/cstrike/addons/sourcemod/configs/whitelist.txt`  
and grant yourself admin in
`ansible/server/cstrike/addons/sourcemod/configs/admins_simple.ini`,
then push both with `task deploy`.

**Other commands:**

```sh
task deploy           # sync ansible/server + recompile plugins + reload the map
task site-check       # dry-run site.yml (--check --diff)
task ping             # ansible ping the servers from controlnode
task ssh-controlnode  # ssh into controlnode
task ssh-lan          # ssh into the game server
task halt / destroy / status
```

Running individual roles:

```sh
ansible-playbook playbooks/site.yml --tags lan      # plugins/content only
ansible-playbook playbooks/site.yml --tags srcds    # srcds/configs only
```

## Extras

- **Nginx** listens on port **80** (FastDL: `http://192.168.128.32/fastdl/lan/bhop/...`).
- **`http://192.168.128.32/srcds_db.php`** - Adminer web UI for MySQL
  (server `localhost`, user `root`, password from `mysql_root_password`
  in group_vars).
- **Deploying your own content**: anything you want pushed to the game server
  goes into `ansible/server/` (the tree mirrors the server layout:
  `cstrike/...`, `fastdl/...`) and ships with `task deploy`. Note that
  `cstrike/addons/sourcemod/data/` is **not overwritten** (only the scaffold
  is synced, existing files are left untouched). If you need different
  behavior, adjust the rsync options in the `deploy_recompile` role.
- **Maps**: if you want to share a local maps folder with the VM
  set up a `synced_folder` in the `Vagrantfile` (same way the `ansible`
  folder is shared with controlnode) and upload from there.

## Ansible layout
```
ansible/
├── inventory/group_vars/lan_servers/   # all configuration (servers, passwords, lists)
├── playbooks/site.yml                  # full provisioning
├── playbooks/tasks/server.yml          # per-server role wiring
├── server/                             # local content for task deploy
└── roles/
    ├── common/    # packages, steam user, rcon-cli, docker, adminer, journald
    ├── network/   # ssh, ufw, dns, hostname, ipv4-precedence
    ├── mysql/     # mysql + timer/flags databases
    ├── nginx/     # fastdl
    ├── srcds/     # steamcmd, CS:S, MM/SM, systemd, logrotate
    ├── lan/       # extensions and plugins (data-driven)
    └── deploy_recompile/  # rsync + spcomp + reload
```

Platform: **Ubuntu 22.04 (jammy)**. To support another distro, add
`vars/<Distro>-<major>.yml` and `setup-<OSFamily>.yml` to the relevant roles.

# Basic NixOS Configuration Flake w/ Lock
NixOS installed on Hetzner Cloud Server via [Traditional ISO Installation](https://wiki.nixos.org/wiki/Install_NixOS_on_Hetzner_Cloud)
## Hetzner Cloud Server Specs
- Name: CX23
- ARCHITECTURE: x86 (Intel/AMD)
- VCPUS: 2
- RAM: 4 GB
- SSD: 40 GB
## Includes
- Git, Nixfmt preinstalled
- SSH only access w/ root disabled (password login disabled)
- User Group Wheel sudo Permission w/o Password Entry
- User Profiles w/ authorized_keys
- Vscode Remote Explorer w/ vscode-server
- Timezone, Locale and Console Keymap
- Network Hostname
- ...
## Remote Deployment (Internet Connection on Machine required)
```sudo nixos-rebuild switch --flake github:sejlim/hetzner-nixos#selims-server --refresh``` 
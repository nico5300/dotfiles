# SSH Agent
In `/etc/security/pam_env.conf`, add the following line:
```
SSH_AUTH_SOCK DEFAULT="${XDG_RUNTIME_DIR}/ssh-agent.socket"
```

# KDE + i3 = <3
After the stow, run:
```
systemctl --user mask plasma-kwin_x11.service
```

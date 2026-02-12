#!/usr/bin/env bash
set -euo pipefail

# Ubuntu: Fail2Ban SSH aggressive jail, journald-only, ban for 1 week.
# - Uses systemd backend (journalctl) [6](https://unix.stackexchange.com/questions/268357/how-to-configure-fail2ban-with-systemd-journal)[2](https://deepwiki.com/fail2ban/fail2ban/4.1-ssh-filter)
# - Uses ssh.service journal match on Ubuntu [7](https://www.decodednode.com/2024/04/getting-fail2ban-working-on-ubuntu-2204.html)[6](https://unix.stackexchange.com/questions/268357/how-to-configure-fail2ban-with-systemd-journal)
# - Aggressive mode [2](https://deepwiki.com/fail2ban/fail2ban/4.1-ssh-filter)[8](https://unix.stackexchange.com/questions/662946/fail2ban-regex-help-for-banning-sshd-connection-attempts)

# installation
# sudo ./fail2ban.sh
# sudo ANTIME=1w MAXRETRY=2 FINDTIME=10m MODE=aggressive PUBLICKEY=any ./fail2ban.sh

BANTIME="${BANTIME:-1w}"
FINDTIME="${FINDTIME:-10m}"
MAXRETRY="${MAXRETRY:-3}"
MODE="${MODE:-aggressive}"
# Count failed pubkey attempts too (useful for key-only servers). sshd filter supports this knob. [2](https://deepwiki.com/fail2ban/fail2ban/4.1-ssh-filter)
PUBLICKEY="${PUBLICKEY:-any}"

JAIL_DIR="/etc/fail2ban/jail.d"
JAIL_FILE="${JAIL_DIR}/sshd-journald.local"

need_root() {
  if [[ "${EUID}" -ne 0 ]]; then
    echo "ERROR: run as root (sudo $0)" >&2
    exit 1
  fi
}

backup_if_exists() {
  local f="$1"
  if [[ -f "$f" ]]; then
    local ts
    ts="$(date +%Y%m%d_%H%M%S)"
    cp -a "$f" "${f}.bak_${ts}"
    echo "==> Backup: ${f} -> ${f}.bak_${ts}"
  fi
}

install_pkgs() {
  echo "==> Installing fail2ban (and systemd python bindings if needed)"
  apt-get update -y
  # python3-systemd is commonly used for systemd/journal integrations in python tooling; harmless if already present.
  apt-get install -y fail2ban python3-systemd || apt-get install -y fail2ban
}

write_jail() {
  mkdir -p "${JAIL_DIR}"
  backup_if_exists "${JAIL_FILE}"

  echo "==> Writing jail config: ${JAIL_FILE}"
  cat > "${JAIL_FILE}" <<EOF
[DEFAULT]
backend = systemd

[sshd]
enabled  = true
mode     = ${MODE}
maxretry = ${MAXRETRY}
findtime = ${FINDTIME}
bantime  = ${BANTIME}
publickey = ${PUBLICKEY}

# Ubuntu typically logs sshd under ssh.service in journald; sshd.service may be an alias with no entries. [7](https://www.decodednode.com/2024/04/getting-fail2ban-working-on-ubuntu-2204.html)[6](https://unix.stackexchange.com/questions/268357/how-to-configure-fail2ban-with-systemd-journal)
# journalctl-style matching: include the unit and/or the sshd comm. [7](https://www.decodednode.com/2024/04/getting-fail2ban-working-on-ubuntu-2204.html)[6](https://unix.stackexchange.com/questions/268357/how-to-configure-fail2ban-with-systemd-journal)
journalmatch = _SYSTEMD_UNIT=ssh.service + _SYSTEMD_UNIT=sshd.service + _COMM=sshd
EOF
}

restart_and_show() {
  echo "==> Enabling + restarting fail2ban"
  systemctl enable --now fail2ban
  systemctl restart fail2ban

  echo "==> Status:"
  fail2ban-client status || true
  echo
  fail2ban-client status sshd || true
}

smoke_test_hints() {
  cat <<'EOF'

==> Smoke tests (journald):
1) Verify ssh logs exist in the journal:
   journalctl -u ssh.service --since "10 min ago" --no-pager | tail -n 50

2) See recent auth failures quickly:
   journalctl -u ssh.service --since "1 hour ago" --no-pager | grep -E "Failed|Invalid|preauth" | tail -n 50

If bans don’t happen as expected, it’s usually a mismatch between log messages and regex.
Fail2Ban supports a systemd backend and journal match configuration. [6](https://unix.stackexchange.com/questions/268357/how-to-configure-fail2ban-with-systemd-journal)[2](https://deepwiki.com/fail2ban/fail2ban/4.1-ssh-filter)

EOF
}

main() {
  need_root
  install_pkgs
  write_jail
  restart_and_show
  smoke_test_hints
  echo "Done."
}

main "$@"
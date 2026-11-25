#!/usr/bin/env bash
# this fix 
set -e
[ "$EUID" -eq 0 ] || { echo "run wit sudo pls! ,,, it will change audio drivers"; exit 1; }

CONF=/etc/modprobe.d/matebook-audio.conf
CPU=$(grep -m1 -oE 'GenuineIntel|AuthenticAMD' /proc/cpuinfo)
MODE=${1:-}
[ -z "$MODE" ] && { [ "$CPU" = "GenuineIntel" ] && MODE=intel || MODE=amd; }

echo "Detected/selected: $MODE"
[ -f "$CONF" ] && cp "$CONF" "$CONF.bak" # bokbokbokbok cockadoodledoo!

# install firmaware
if command -v apt >/dev/null; then
  apt update && apt install -y firmware-sof-signed alsa-ucm-conf alsa-utils pipewire-audio || \
  apt install -y firmware-sof-signed alsa-ucm-conf alsa-utils
elif command -v pacman >/dev/null; then
  pacman -S --needed --noconfirm sof-firmware alsa-ucm-conf alsa-utils
elif command -v dnf >/dev/null; then
  dnf install -y alsa-sof-firmware alsa-ucm alsa-utils
fi

# 2 change the driver cofgnig
if [ "$MODE" = "intel" ]; then
  # forces legacy driver
  cat > "$CONF" <<'EOF'
options snd-intel-dspcfg dsp_driver=1
options snd_hda_intel power_save=0
EOF
else
  # AMD: disable the ACP digital-mic driver that often steals the card, keep HDA
  cat > "$CONF" <<'EOF'
blacklist snd_rn_pci_acp3x
blacklist snd_pci_acp3x
blacklist snd_pci_acp5x
blacklist snd_pci_acp6x
options snd_hda_intel power_save=0
EOF
fi

# 3 rebuild initramfs and then unmutre
(command -v update-initramfs >/dev/null && update-initramfs -u) || \
(command -v mkinitcpio >/dev/null && mkinitcpio -P) || \
(command -v dracut >/dev/null && dracut -f) || true
amixer -c 0 sset Master unmute 2>/dev/null || true
amixer -c 0 sset Speaker unmute 2>/dev/null || true
amixer -c 0 sset Headphone unmute 2>/dev/null || true

echo "sudo rm $CONF && reboot"
echo "^"
echo "|"
echo "|"
echo "done ^_^ reboot now to apply the fix! to undo, execute this command"


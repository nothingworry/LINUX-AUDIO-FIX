-# disclaimer! this has only been tested on ubuntu linux with a huawei mateBook d15.

# Linux Audio Software Fix

*As we mostly know,* getting audio to work on Linux can be tricky with **some hardware**.
Sometimes it outputs to "Dummy Output", or to nothing at all.

**this fixes it easily!** Kinda.

It makes your system use the Intel SOF audio driver (plus the required firmware) instead of the one that fails to detect your sound card.
If you have an **Intel CPU** (11th gen or newer is the best bet), this shell script should fix it!

**How to use:**
1. Download the script (e.g. `fix.sh`)
2. Run `sudo bash fix.sh`
3. Reboot

**To undo:** `sudo rm /etc/modprobe.d/matebook-audio.conf && sudo reboot`

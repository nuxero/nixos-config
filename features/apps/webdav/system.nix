{ config, pkgs, lib, ... }:

{
  environment.systemPackages = [ pkgs.rclone ];

  # Allow non-root users to access the FUSE mount
  programs.fuse.userAllowOther = true;

  # rclone mount via native NixOS fileSystems
  # Uses the standard rclone config at /etc/rclone/saves.conf
  # which defines a [saves] remote pointing to the WebDAV server.
  fileSystems."/mnt/saves" = {
    device = "saves:";
    fsType = "rclone";
    options = [
      "nodev"
      "nofail"
      "allow_other"
      "args2env"
      "config=/etc/rclone/saves.conf"
      # VFS cache: full read/write with local caching
      "vfs-cache-mode=full"
      "vfs-cache-max-size=2G"            # max local disk used by cache
      "vfs-cache-max-age=24h"            # evict files not accessed in 24h
      "vfs-read-chunk-size=32M"          # stream in 32M chunks (fast playback start)
      "vfs-read-chunk-size-limit=off"    # no limit on chunk growth
      "vfs-write-back=5s"                # delay uploads slightly
      # Directory listing cache
      "dir-cache-time=5m"
      # Buffer for streaming reads
      "buffer-size=64M"
      # File ownership
      "uid=1000"
      "gid=100"
      "umask=002"
    ];
  };

  # One-time setup:
  #
  # If you already have a "saves" remote in your user rclone config, copy it
  # directly (rclone config show redacts passwords — use the raw file):
  #
  #   sudo mkdir -p /etc/rclone
  #   grep -A 10 '^\[saves\]' ~/.config/rclone/rclone.conf | sudo tee /etc/rclone/saves.conf > /dev/null
  #   sudo chmod 600 /etc/rclone/saves.conf
  #
  # Or create it from scratch:
  #
  #   sudo mkdir -p /etc/rclone
  #   rclone obscure 'your-plain-password'   # copy the output
  #   sudo bash -c 'cat > /etc/rclone/saves.conf << EOF
  #   [saves]
  #   type = webdav
  #   url = https://saves.hectorzelaya.dev
  #   vendor = other
  #   user = your-username
  #   pass = your-obscured-password
  #   EOF'
  #   sudo chmod 600 /etc/rclone/saves.conf
}

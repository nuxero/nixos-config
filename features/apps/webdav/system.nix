{ config, pkgs, lib, ... }:

{
  # Enable davfs2 support (provides mount.davfs helper)
  services.davfs2.enable = true;

  # Mount the WebDAV resource automatically on first access
  fileSystems."/mnt/saves" = {
    device = "https://saves.hectorzelaya.dev";
    fsType = "davfs";
    options = [
      "rw"
      "_netdev"               # wait for network before mounting
      "x-systemd.automount"   # mount on first access (doesn't block boot)
      "noauto"                # don't mount at early boot
      "uid=hector"
      "gid=users"
    ];
  };

  # Credentials are stored statefully in /etc/davfs2/secrets
  # Before first rebuild, create the file:
  #
  #   sudo mkdir -p /etc/davfs2
  #   sudo bash -c 'cat > /etc/davfs2/secrets << EOF
  #   /mnt/saves  your-username  your-password
  #   EOF'
  #   sudo chmod 600 /etc/davfs2/secrets
  #   sudo chown root:root /etc/davfs2/secrets
}

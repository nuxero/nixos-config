{ config, pkgs, ... }:

{
  # TEMPORARY: Capture kernel panics that the journal misses.
  # printk.always_kmsg_dump tells the kernel to write dmesg to pstore on panic.
  # systemd-pstore archives /sys/fs/pstore/ on boot for later analysis.
  # After a silent crash, check: ls /var/lib/systemd/pstore/ or journalctl -b 0 --grep pstore
  # Remove once silent crashes are diagnosed.
  boot.kernelParams = [ "printk.always_kmsg_dump=Y" ];
  systemd.services.systemd-pstore.wantedBy = [ "multi-user.target" ];

  # TEMPORARY: Log CPU/GPU/NVMe temps every 30s — survives hard power-off for post-crash analysis.
  # Added to diagnose whether Apr 13 freezes are thermal or MES firmware bug.
  # Remove once root cause is confirmed.
  systemd.services.thermal-logger = {
    description = "Log thermal sensor data";
    after = [ "multi-user.target" ];
    wantedBy = [ "multi-user.target" ];
    path = [ pkgs.coreutils ];
    serviceConfig = {
      Type = "simple";
      Restart = "always";
      ExecStart = pkgs.writeShellScript "thermal-logger" ''
        read_sensor() {
          for hw in /sys/class/hwmon/hwmon*/; do
            [ "$(cat "''${hw}name" 2>/dev/null)" = "$1" ] && cat "''${hw}temp1_input" 2>/dev/null && return
          done
          echo "?"
        }
        while true; do
          ts=$(date +%H:%M:%S)
          echo "$ts cpu=$(read_sensor k10temp) gpu=$(read_sensor amdgpu) nvme=$(read_sensor nvme)" >> /var/log/thermal.log
          sleep 30
        done
      '';
    };
  };

  # Rotate thermal log — tmpfiles cleans entries older than 7d.
  systemd.tmpfiles.rules = [ "f /var/log/thermal.log 0644 root root 7d" ];

  # Monitor NVMe health (Samsung 990 EVO Plus has intermittent controller crashes).
  services.smartd.enable = true;
  environment.systemPackages = [ pkgs.smartmontools pkgs.lm_sensors ];
}

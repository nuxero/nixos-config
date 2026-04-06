{ config, pkgs, ... }:

{
  home.packages = with pkgs; [
    # IDE — Community Edition (free, no license needed)
    jetbrains.idea-community

    # Java toolchain
    jdk21
    maven

    # Web test automation drivers
    chromedriver
  ];

  # Ensure JAVA_HOME is set for IntelliJ and Maven
  home.sessionVariables = {
    JAVA_HOME = "${pkgs.jdk21}/lib/openjdk";
  };

  # Guide for setting up per-project test automation environments
  home.file."automated-qa-guide.md".text = builtins.readFile ./automated-qa-guide.md;
}

{ config, pkgs, lib, ... }:

let
  cfg = config.custom.cli;

  flakeDir = "$HOME/nixos-config";

  # Stable locations for the staged build + captured diff, so later steps
  # reuse step 1's exact result — no rebuild, no re-evaluation, no sudo until
  # you choose to apply.
  stageDir  = "$HOME/.cache/nixos-staged";
  stageLink = "${stageDir}/result";     # symlink to the built generation
  diffFile  = "${stageDir}/diff.txt";   # plain-text package diff (for the LLM)
  overFile  = "${stageDir}/overview.md"; # natural-language summary

  # ---------------------------------------------------------------------------
  # Staged system update, split around the privilege boundary + an LLM summary.
  #
  #   Step 1  os-fetch    — UNATTENDED. Updates flake inputs, fully builds the
  #                         new generation, saves a plain-text package diff,
  #                         and (best-effort) generates a natural-language
  #                         overview via `os-explain`. Never elevates, so it
  #                         can run while you're away with no sudo prompt.
  #
  #   (any time) os-explain — Feeds the saved diff to Kiro CLI and prints/saves
  #                         a plain-English overview (groups, risk, reboot
  #                         needs). Re-runnable; also called by os-fetch.
  #
  #   Step 2  os-apply    — When you return. Promotes the already-built
  #                         generation to the boot default (needs sudo).
  #                         Instant: reuses step 1's out-link, nothing rebuilds.
  #                         Running system untouched; reboot to apply.
  #
  # `nh os build` builds without elevating; `nh os boot <out-link>` sets the
  # boot default from that exact store path. `nvd diff` produces the plain
  # diff; `kiro-cli chat --no-interactive` turns it into prose.
  # ---------------------------------------------------------------------------

  # Prompt used to turn the raw diff into a natural-language overview.
  # Kept as a Nix string so it lives with the scripts and stays consistent.
  # Single logical paragraph (no line-continuations) so no stray characters
  # leak into the emitted shell text.
  explainPrompt = "Below is the output of an `nvd diff` between my current NixOS system generation and a newly built one (nvd is a Nix package version diff tool; markers: [U*]/[U.] updated, [C*]/[C.] rebuilt/changed derivation, [A.] added, [R.] removed; version-string changes shown as old -> new). Give me a concise natural-language overview grouped by theme (e.g. desktop environment, kernel/drivers, dev tools, applications). For each group note what changed and why it matters. Call out anything that needs a reboot (kernel, graphics/NVIDIA modules), any major-version bumps, and any security-relevant updates. End with a one-line overall risk assessment. Do not invent details you cannot infer from the diff. Here is the diff:";

  osExplain = pkgs.writeShellApplication {
    name = "os-explain";
    runtimeInputs = with pkgs; [ coreutils ];
    text = ''
      set -euo pipefail
      DIFF="${diffFile}"
      OVERVIEW="${overFile}"

      if [ ! -s "$DIFF" ]; then
        echo "!! No saved diff at $DIFF" >&2
        echo "   Run 'os-fetch' first." >&2
        exit 1
      fi

      # kiro-cli lives outside the Nix profile (see `which kiro-cli`), so resolve
      # it from PATH rather than pinning it as a runtime input.
      if ! command -v kiro-cli >/dev/null 2>&1; then
        echo "!! kiro-cli not found on PATH; showing the raw diff instead." >&2
        echo "   You can also paste $DIFF into a chat and ask for an overview." >&2
        cat "$DIFF"
        exit 0
      fi

      echo ">> Generating natural-language overview via Kiro CLI..."
      # Build the prompt via a quoted heredoc so backticks/() in the text are
      # treated literally (no command substitution, no shellcheck SC2006), then
      # append the diff. Feed the whole thing to a one-shot, non-interactive chat.
      PROMPT_FILE="$(mktemp)"
      trap 'rm -f "$PROMPT_FILE"' EXIT
      cat > "$PROMPT_FILE" <<'PROMPT_EOF'
${explainPrompt}
PROMPT_EOF
      {
        cat "$PROMPT_FILE"
        printf '\n\n'
        cat "$DIFF"
      } | kiro-cli chat --no-interactive --trust-tools= | tee "$OVERVIEW"

      echo ""
      echo ">> Overview saved to $OVERVIEW"
    '';
  };

  osFetch = pkgs.writeShellApplication {
    name = "os-fetch";
    runtimeInputs = with pkgs; [ nh nvd nix-output-monitor coreutils nix osExplain ];
    text = ''
      set -euo pipefail
      FLAKE="${flakeDir}"
      LINK="${stageLink}"
      DIFF="${diffFile}"
      mkdir -p "${stageDir}"

      echo ">> [1/2] Updating flake inputs (flake.lock)..."
      nix flake update --flake "$FLAKE"

      echo ""
      echo ">> [1/2] Building new generation (no sudo; safe to leave running)..."
      nh os build "$FLAKE" --out-link "$LINK" --diff always

      # Save a plain-text (colorless) diff for the LLM overview and your records.
      echo ">> Saving package diff to $DIFF ..."
      nvd --color never diff /run/current-system "$LINK" > "$DIFF" || true

      echo ""
      echo ">> Build complete and staged at: $LINK"

      # Best-effort natural-language overview. Never fail the fetch over it
      # (offline, kiro-cli missing, etc.) — the raw diff is already saved.
      echo ""
      os-explain || echo ">> (Skipped overview; run 'os-explain' later.)"

      echo ""
      echo ">> Nothing has been applied. Run 'os-apply' when you're back to set it"
      echo "   as the boot default, then reboot."
    '';
  };

  osApply = pkgs.writeShellApplication {
    name = "os-apply";
    runtimeInputs = with pkgs; [ nh coreutils ];
    text = ''
      set -euo pipefail
      LINK="${stageLink}"

      if [ ! -e "$LINK" ]; then
        echo "!! No staged build found at $LINK" >&2
        echo "   Run 'os-fetch' first." >&2
        exit 1
      fi

      echo ">> [2/2] Setting staged generation as boot default (needs sudo)..."
      echo "   Target: $(readlink -f "$LINK")"
      # Promote the exact path built by os-fetch — no rebuild, no re-eval.
      nh os boot "$LINK"

      echo ">> Done. Boot default updated; running system unchanged."
      echo "   Reboot to apply — 'systemctl reboot'."
    '';
  };
in
{
  options.custom.cli = {
    gitUserName = lib.mkOption {
      type = lib.types.str;
      description = "Git user.name";
    };
    gitUserEmail = lib.mkOption {
      type = lib.types.str;
      description = "Git user.email";
    };
    gitSmtpServer = lib.mkOption {
      type = lib.types.str;
      default = "smtp.gmail.com";
      description = "SMTP server for git send-email";
    };
    gitSmtpServerPort = lib.mkOption {
      type = lib.types.int;
      default = 587;
      description = "SMTP server port for git send-email";
    };
    gitSmtpEncryption = lib.mkOption {
      type = lib.types.str;
      default = "tls";
      description = "SMTP encryption method for git send-email (tls or ssl)";
    };
    gitSmtpUser = lib.mkOption {
      type = lib.types.str;
      default = cfg.gitUserEmail;
      description = "SMTP user for git send-email (defaults to gitUserEmail)";
    };
  };

  config = {
    home.packages = with pkgs; [
      vim wget btop eza bat fastfetch
      nh nix-output-monitor nvd poppler-utils

      # Staged system-update helpers (defined above)
      osFetch osApply osExplain

      # Base runtimes — for uvx, npx, standalone MCP servers, one-off scripts
      python3
      uv
      nodejs
    ];

    programs.git = {
      enable = true;
      package = pkgs.gitFull;
      settings = {
        user.name = cfg.gitUserName;
        user.email = cfg.gitUserEmail;
        alias = {
          ci = "commit";
          co = "checkout";
          s = "status";
        };
        init.defaultBranch = "main";
        pull.rebase = true;
        core.editor = "vim";
        sendemail = {
          smtpServer = cfg.gitSmtpServer;
          smtpServerPort = cfg.gitSmtpServerPort;
          smtpEncryption = cfg.gitSmtpEncryption;
          smtpUser = cfg.gitSmtpUser;
          confirm = "auto";
        };
      };
    };

    programs.bash = {
      enable = true;
      enableCompletion = true;
      shellAliases = {
        ll = "eza -l";
        la = "eza -la";
        # System updates: 'os-fetch' (unattended build) now, 'os-apply' (set
        # boot default, needs sudo) later. Both are on PATH via home.packages.
        update = "nh os switch --update";  # legacy: build + activate in one shot
        ".." = "cd ..";
      };
      initExtra = ''
        export PATH="$HOME/.local/bin:$PATH"

        # Helper function: make a directory and instantly cd into it
        mkcd() {
          mkdir -p "$1" && cd "$1"
        }
      '';
    };

    programs.starship = {
      enable = true;
      enableBashIntegration = true;
      settings = {
        add_newline = false;
        character = {
          success_symbol = "[➜](bold green)";
          error_symbol = "[✗](bold red)";
        };
        package.disabled = true;
      };
    };

    programs.direnv = {
      enable = true;
      nix-direnv.enable = true;
    };
  };
}

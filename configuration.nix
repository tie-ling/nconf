# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).

{ config, lib, pkgs, inputs, ... }:

{
  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Let 'nixos-version --json' know about the Git revision
  # of this flake.
  system.configurationRevision = lib.mkIf (inputs.self ? rev) inputs.self.rev;

  security.chromiumSuidSandbox.enable = true;

  programs.sway = {
    enable = true;
    extraPackages = builtins.attrValues {
      inherit (pkgs)
        bemenu swaylock swayidle foot brightnessctl grim i3status pinentry-qt
        wl-mirror wl-clipboard gammastep;
      inherit (pkgs.gnome) adwaita-icon-theme gnome-themes-extra;
    };
  };

  services.xserver = {
    layout = "yc";
    extraLayouts."yc" = {
      description = "my layout";
      languages = [ "eng" ];
      symbolsFile = ./ergo-keymap-yc.txt;
    };
  };
  console.useXkbConfig = true;

  services = {
    tlp.enable = true;
    yggdrasil = {
      enable = true;
      openMulticastPort = false;
      extraArgs = [ "-loglevel" "error" ];
      settings.Peers =
        #curl -o test.html https://publicpeers.neilalexander.dev/
        # grep -e 'tls://' -e 'tcp://' -e 'quic://' test.html | grep online | sed 's|<td id="address">|"|' | sed 's|</td><td.*|"|g' | sort | wl-copy -n
        (import ./yggdrasil-peers.nix);
    };
    dnscrypt-proxy2 = {
      enable = true;
      upstreamDefaults = true;
      settings = { ipv6_servers = true; };
    };
    emacs = {
      enable = true;
      package = ((pkgs.emacsPackagesFor pkgs.emacs29-nox).emacsWithPackages
        (epkgs:
          builtins.attrValues {
            inherit (epkgs) mu4e nix-mode magit pyim pyim-basedict auctex;
            inherit (epkgs.treesit-grammars) with-all-grammars;
          }));
      defaultEditor = true;
    };
    logind = {
      extraConfig = ''
        HandlePowerKey=suspend
      '';
      lidSwitch = "suspend";
      lidSwitchDocked = "ignore";
      lidSwitchExternalPower = "suspend";
    };
    pipewire = {
      enable = true;
      alsa.enable = true;
      pulse.enable = true;
    };
  };

  programs.tmux = {
    enable = true;
    keyMode = "emacs";
    newSession = true;
    terminal = "tmux-direct";
    extraConfig = ''
      unbind C-b
      unbind f7
      set -u prefix
      set -g prefix f7
      bind -N "Send the prefix key" f7 send-prefix
    '';
  };

  security = {
    doas.enable = true;
    sudo.enable = false;
    lockKernelModules = false;
  };

  zramSwap.enable = true;

  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  boot.initrd.systemd.enable = true;

  programs.git.enable = true;

  home-manager.users.yc.home.stateVersion = "23.11";
  home-manager.users.yc.programs.chromium = {
    enable = true;
    package = pkgs.ungoogled-chromium;
    commandLineArgs = [
      "--ozone-platform-hint=auto"
      "--enable-features=VaapiVideoDecodeLinuxGL,VaapiVideoEncoder,TouchpadOverscrollHistoryNavigation"
      "--js-flags=--jitless"
      "--start-maximized"
      "--disable-remote-fonts"
      "--disable-smooth-scrolling"
      "--gtk-version=4"
      "--disable-webgl"
      "--incognito"
    ];
  };

  nixpkgs.overlays = [
    (final: prev: rec {
      zathura_core = prev.zathuraPkgs.zathura_core.overrideAttrs
        (o: { patches = [ ./zathura-restart_syscall.patch ]; });
      zathura =
        prev.zathuraPkgs.zathuraWrapper.override { inherit zathura_core; };
    })
  ];

  programs.gnupg.agent = {
    enable = true;
    enableSSHSupport = true;
    pinentryFlavor = "qt";
  };
  networking = {
    firewall.enable = true;
    nameservers = [ "127.0.0.1" ];
    networkmanager = {
      enable = true;
      dns = "none";
      ensureProfiles.profiles = {
        home-wifi = {
          connection = {
            id = "fuclw";
            permissions = "";
            type = "wifi";
          };
          ipv4 = {
            dns-search = "";
            method = "auto";
          };
          ipv6 = {
            addr-gen-mode = "stable-privacy";
            dns-search = "";
            method = "auto";
          };
          wifi = {
            mac-address-blacklist = "";
            mode = "infrastructure";
            ssid = "TP-Link_48C2";
          };
          wifi-security = {
            auth-alg = "open";
            key-mgmt = "wpa-psk";
            psk = "77017543";
          };
        };

      };
    };
    hosts = { "200:8bcd:55f4:becc:4d85:2fa6:2ed2:5eba" = [ "tl.yc" ]; };
  };
  nix.registry.nixpkgs.flake = inputs.nixpkgs;

  users.mutableUsers = false;
  users.users = {
    yc = {
      initialHashedPassword =
        "$6$UxT9KYGGV6ik$BhH3Q.2F8x1llZQLUS1Gm4AxU7bmgZUP7pNX6Qt3qrdXUy7ZYByl5RVyKKMp/DuHZgk.RiiEXK8YVH.b2nuOO/";
      description = "Yuchen Guo";
      extraGroups = [
        # use doas
        "wheel"
      ];
      isNormalUser = true;
      packages = builtins.attrValues {
        inherit (pkgs)
          mg emacs29-nox mu zathura yt-dlp mpv xournalpp pavucontrol msmtp isync
          gpxsee qrencode;
      } ++ [
        (pkgs.pass.withExtensions (exts: [ exts.pass-otp ]))
        (pkgs.texliveBasic.withPackages (ps:
          builtins.attrValues {
            inherit (ps)
              collection-basic collection-mathscience collection-pictures
              collection-luatex collection-langenglish collection-langgerman
              interval

              ###### pdf manipulation tool
              pdfjam # depends on pdfpages, geometry
              # pdfpages and dependencies
              pdfpages eso-pic atbegshi pdflscape
              ######

              # unicode-math and deps
              unicode-math fontspec realscripts lualatex-math
              # quotes
              csquotes
              # checks
              chktex lacheck;
          }))
      ];
    };
  };
  hardware.opengl.extraPackages = [ pkgs.intel-media-driver ];
  fonts.packages =
    [ pkgs.dejavu_fonts pkgs.noto-fonts-cjk-sans pkgs.gyre-fonts ];
  fonts.fontconfig = {
    defaultFonts = {
      sansSerif = [ "DejaVu Sans" "Noto Sans CJK SC" ];
      monospace = [ "DejaVu Sans Mono" "Noto Sans Mono CJK SC" ];
      serif = [ "DejaVu Serif" "Noto Sans CJK SC" ];
    };
  };
  xdg.portal = {
    enable = true;
    wlr.enable = true;
  };
  # networking.hostName = "nixos"; # Define your hostname.

  # Set your time zone.
  time.timeZone = "Europe/Berlin";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

  # Enable sound.
  sound.enable = true;

  # Most users should NEVER change this value after the initial install, for any reason,
  # even if you've upgraded your system to a new NixOS release.

  system.stateVersion = "23.11"; # Did you read the comment?

}


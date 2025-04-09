{ encore
, config
, pkgs
, lib
, ...
}:
with lib; let
  cfg = config.programs.encore;
in
{
  options.programs.encore = {
    enable = mkEnableOption "Enable Encore CLI";

    settings = {
      browser = mkOption {
        type = types.enum [ "auto" "never" "always" ];
        default = "always";
        description = ''
          Whether to open the local development dashboard in the browser on startup.
          Can be "auto", "never", or "always".
        '';
      };
    };
  };

  config = mkIf cfg.enable {
    home.packages = [
      encore
    ];

    xdg.configFile."encore/config".source = (pkgs.formats.toml { }).generate "encore-config" {
      run = {
        browser = cfg.settings.browser;
      };
    };
  };
}

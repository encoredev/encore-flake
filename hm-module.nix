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
        type = types.nullOr (types.enum [ "auto" "never" "always" ]);
        default = null;
        description = ''
          Whether to open the local development dashboard in the browser on startup.
          Can be "auto", "never", or "always".

          When null, no config file is written and Encore's own default ("auto")
          applies.
        '';
      };
    };
  };

  config = mkIf cfg.enable {
    home.packages = [
      encore
    ];

    xdg.configFile."encore/config" = mkIf (cfg.settings.browser != null) {
      source = (pkgs.formats.toml { }).generate "encore-config" {
        run = {
          browser = cfg.settings.browser;
        };
      };
    };
  };
}

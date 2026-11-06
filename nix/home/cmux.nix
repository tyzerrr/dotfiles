{ pkgs, ... }:
{
  # 旧 settings.json はスキーマ宣言以外すべてコメントアウトされたテンプレートだった
  xdg.configFile."cmux/settings.json".source = (pkgs.formats.json { }).generate "cmux-settings" {
    "$schema" = "https://raw.githubusercontent.com/manaflow-ai/cmux/main/web/data/cmux-settings.schema.json";
    schemaVersion = 1;
  };
}

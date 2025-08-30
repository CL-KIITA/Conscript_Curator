import "package:color/color.dart";
import "package:nyxx/nyxx.dart" show DiscordColor;

extension DiscordColorConvert on Color {
  DiscordColor forDiscord() {
    RgbColor rgb = this.toRgbColor();
    return DiscordColor.fromRgb(rgb.r.round(), rgb.g.round(), rgb.b.round());
  }
}

final class Colors {
  const Colors();
  static Color get ruwi => RgbColor(136, 0, 0);
  static Color get marbleBasic => 0xd3.toRgbColor;
  static Color get marbleLight => 0xef.toRgbColor;
  static Color get marbleDark => 0xaa.toRgbColor;
  static Color get marble1 => Colors.marbleBasic;
  static Color get marble2 => Colors.marbleLight;
  static Color get marble3 => Colors.marbleDark;
  static Color get marbleGrue => HexColor("a2b1a4");
  static Color marble(int variant) => switch (variant){
    1 => Colors.marble1,
    2 => Colors.marble2,
    3 => Colors.marble3,
    _ => Colors.marble((variant - 1) % 3 + 1),
  }
  static Color get grue => HexColor("36c8b5");
}

const colors = Colors();

extension ColorTriplet on num {
  Color get toRgbColor => RgbColor(this, this, this);
}
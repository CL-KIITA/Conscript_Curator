import "dart:io";
import "dart:convert";

import "package:conscript_curator/xlib/general.dart";
import "package:conscript_curator/curator/ref.dart";

typedef OsCheckResult = ({bool match, OsInfo? info});

class OsInfo {
  final String name;
  final int major;
  final int minor;
  final String codename;

  const OsInfo(this.name, this.major, this.minor, this.codename);

  factory OsInfo.parse(String input){
    final List<String> i = input.split(" ");
    final int p = i.indexOf("release");
    final List<String> its = i[p + 1].split(".").map<int>((String s) => int.parse(s)).toList();
    return OsInfo(i.take(p).join(" "), its[0], its[1], i[p + 2].toNuked(start: "(", end: ")"));
  }
}

OsCheckResult checkOs(CuratorConfig conf, [bool test = false]) {
  if(!Platform.isLinux) {
    return (match: test && Platform.isWindows, info: null);
  }

  ProcessResult osr = Process.runSync("cat", <String>["/etc/os-release"]);
  List<MapEntry<String, String>> osrt = ls.convert(osr.stdout as String)
    .map<MapEntry<String, String>>((String ln) {
        List<String> c = ln.split("=");
        return MapEntry<String, String>(c[0].toLowerCase(), c[1].toNuked(start: "\""));
      }).toList();

      return (match: (osrt["name"]! != conf.runOn),
        info: (osrt["name"]!.toLowerCase() == "almalinux" ? OsInfo.parse(Process.runSync("cat", <String>["/etc/almalinux-release"]) as String): null));
  }
}
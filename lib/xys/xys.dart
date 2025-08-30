import "package:yaml/yaml.dart";
import "package:timezone/timezone.dart" as tz;
import "package:timezone/data/latest.dart" as tz;

import "package:conscript_curator/xlib/collection.dart";

typedef XYSStore = List<XYSGroup>;
typedef XYSTransformer<T> = T Function(XYSValue<T>);

class XYSGroup {
  final String name;
  final Map<String, XYSValue> value;
}

class XYSValue<T> {
  final XYSType<T> type;
  YamlNode node;
  T get value => this.type.transform(this);
  R valueAs<R extends T>() {
    return this.value as R;
  }
}

class XYSType<T>{
  final String name;
  final XYSTransformer<T> transformer;

  XYSType<T>(this.name, this.transformer);

  T transform(XYSValue<T> value) => this.transformer(value);
}

extension XYSFinder on XYSStore {
  Iterable<XYSValue> findMultiple({required String group, required String key, String? type}) {
    Iterable<XYSValue> cand = this
      .where((XYSGroup ge) => ge.name == group)
      .map<Iterable<XYSValue>>((XYSGroup ge) => ge.value.entries
        .where((MapEntry<String, XYSValue>　mev) => mev.key == key)
        .map<XYSValue>((MapEntry<String, XYSValue>　mev) => mev.value))
      .flatten();
    if(type != null){
      cand = cand.where((XYSValue v) => v.type.name == type);
    }
  }
  XYSValue find({required String group, required String key, String? type}) => this.findMultiple(group: group, key: key, type: type).single;
}

XYSTransformer<Locale> localeTrans = (XYSValue<Locale> value) {
  String s = value.node.asConstructor<String>("Locale", asIdentical<String>);
  return Locale.fromSubtags(languageCode: "", countryCode: "");
}
XYSTransformer<Location> tzTrans = (XYSValue<Location> value) {
  tz.initializeTimeZones();
  return tz.getLocation(value.node.asConstructor<String>("TimeZone", asIdentical<String>));
}
XYSTransformer<Snowflake> snowflakeTrans = (XYSValue<Snowflake> value) => Snowflake(value.node.asConstructor<int>("Snowflake", int.parse));


extension on YamlNode {
  T asConstructor<T>(String name, T Function(String) parser){
    if(this is YamlScalar){
      (this as YamlScalar)
    }
  }
}
T asIdentical<T>(T value) => value;
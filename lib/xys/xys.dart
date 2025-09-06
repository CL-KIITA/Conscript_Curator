import "dart:convert";

import "package:yaml/yaml.dart";
import "package:nyxx/nyxx.dart";
import "package:timezone/timezone.dart" as tz;
import "package:timezone/data/latest.dart" as tz;
import "package:intl/locale.dart";

import "package:conscript_curator/xlib/general.dart";
import "package:conscript_curator/xlib/collection.dart";

typedef XYSTransformer<T> = T Function(XYSValue<T>);
typedef IndexedLine = (int, String);

class XYSStore {
  final List<XYSGroup> _groups;
  
  XYSStore._(this._groups);
  XYSStore(List<XYSGroup> groups): this._(groups);
  XYSStore.empty(): this._groups = <XYSGroup>[];
  void add(XYSGroup group){
    this._groups.add(group);
  }
  void addYaml(String name, YamlNode yaml){
    this.add(XYSGroup.fromYaml(name, yaml));
  }
  factory XYSStore.parse(String source){
    // 1. split source to lines
    // 2. find identifiers surrounded by "[]" and accompanied by symbols in head, from each lines
    // 3. filter the lines which following to empty line or is located in first line
    List<String> lines = ls.convert(source);
    int wholeLen = lines.length;
    Iterable<int> voidLineNrs = lines.voidedLineNrs();
    Iterable<int> groupLineNrs = lines.matchPatLineNrs();
    Iterable<int> pragmaLineNrs = lines.matchPatLineNrs();
    Iterable<Range> groupLinesRanges = (begins: groupLineNrs, voideds: voidLineNrs).takeRange(wholeLen);
    Iterable<Range> pragmaLinesRanges = (begins: pragmaLineNrs, voideds: voidLineNrs).takeRange(wholeLen);
    
    return XYSStore(groupLinesRanges
      .map<Iterable<String>>((Range r) r.elements.map<String>((int ind) => lines[ind]))
      .map<XYSGroup>(XYSGroup.parseLines);

  }
}
extension LineIndexEx on Iterable<String> {
  Iterable<int> matchLineNrs(bool Function(String) test) => this.indexed
      .where((IndexedLine e) => test(e.$2))
      .map<int>((IndexedLine e) => e.$1);
  Iterable<int> voidedLineNrs() => this.matchLineNrs((String l) => l == "");
  Iterable<int> matchPatLineNrs(Pattern pattern) => this.matchLineNrs((String l) => l.contains(pattern));
}
extension LineRangeEx on ({Iterable<int> begins, Iterable<int> voideds}){
  Iterable<Range> takeRange(int wholeLength) {
    List<Range> r = <Range>[];
    
    for (final int begin in this.begins) {
      if (begin == 0 || this.voideds.contains(begin - 1)) {
        Iterable<int> afterBegins = this.begins.where((int i) => i > begin);
        
        if (afterBegins.isNotEmpty) {
          int nextBegin = afterBegins.reduce((int prev, int curr) => min<int>(prev, curr));
          
          for (int i = nextBegin - 1; i > begin; i--) {
            if (this.voideds.contains(i)) {
              continue;
            } else {
              r.add(Range(first: begin, last: i));
            }
          }
        } else {
          r.add(Range(first: begin, last: wholeLength - 1));
        }
      }
    }
    
    return r;
  }
}

enum XYSNSLand {
  standard, environment, user,
}

class XYSGroup {
  final String name;
  final XYSNSLand land;
  final Map<String, XYSValue> value;
  
  XYSGroup(this.name, this.land, this.value);
  factory XYSGroup.fromYaml(String name, YamlNode yaml){}
  factory XYSGroup.parse(String source)
    => XYSGroup.parseLines(ls.convert(source));
  factory XYSGroup.parseLines(Iterable<String> lines){
    // 1. assert that first line is identifier line
    // 2. take the identifier
    // 3. skip first line
    // 4. replace "--" on line top to "#"
    // 5. handle lines as yaml
    String identLine = lines.first;
    if (!) {
      
    }
    String identNative = identLine.substring(, );
    String temp = lines.skip(1).map<String>((String s) => s.replaceFirst(, "#")).join(nl);
    
  }
  
}

class XYSPragma {
  XYSPragma();
}

class XYSValue<T extends Object?, Y extends YamlNode> {
  final XYSType<T> type;
  final Y node;
  T get value => this.type.transform(this);
  R valueAs<R extends T>() {
    return this.value as R;
  }
}

class XYSType<T extends Object?, Y extends YamlNode>{
  final String name;
  final XYSTransformer<T> transformer;

  XYSType<T>(this.name, this.transformer);

  T transform(XYSValue<T, Y> value) => this.transformer(value);
}

class XYSProps {
  static const String stdGroupTop = "";
  static const String envGroupTop = "%";
  static const String userGroupTop = "#";
  static const String protoTop = "#";
  static const List<String> pragmaIdentWithSingle = const <String>["use"];
  static const List<String> pragmaIdentWithMulti = const <String>["proto"];
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

/**

group lines are consists by group line that trails one or more prop lines and separated by one or more empty lines

### keywords and syntaxes

`<pragma-line>` or `<pragma-lines>`

- `#proto <proto-name> <proto-define-block>` : define protocols
- `#use <proto-name> from <proto-uri>` : load protocols from uri

`<group-line>`

- `[<group-name>]` : group identifier in standard-land
- `[%<group-name>]` : group identifier in environment-land
- `[#<group-name>]` : group identifier in user-land

`<prop-line>`

- `<key>: <value>`

`<key>`

- all yaml-valid string without quotation-marks and spaces

`<value>`

- all yaml-valid value
- `@<type-name> <value>`: type annotation
- `<constructor-name> (<values>)*` constructor
- `!!` : a value, that is not prepared yet
*/
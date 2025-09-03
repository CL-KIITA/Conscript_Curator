import "package:nyxx/nyxx.dart";
import "package:gsheets/gsheets.dart";
import "package:intl/locale.dart";
import "package:sealed_languages/sealed_languages.dart"

import "package:conscript_curator/xlib/general.dart";
import "package:conscript_curator/curator/kernel.dart";
import "package:conscript_curator/curator/sheet.dart";
import "package:conscript_curator/curator/massage.dart";

class CXSRecord {
  final String example;
  final String lang;
  final String? translated;
  final String? contributor;
  
  CXSRecord({
    required this.example,
    Locale? lang,
    this.translated,
    this.contributor}):
    this.lang = lang ?? CXSRecord.defaultLang;
  
  List<EmbedFieldBuilder> get fields {
    List<EmbedFieldBuilder> fs = <EmbedFieldBuilder>[
      EmbedFieldBuilder(name: Paren.guil.cover("例文"), value: this.example, isInline: true),
      EmbedFieldBuilder(name: Paren.guil.cover("言語"), value: NaturalLanguage.fromCode(this.lang.languageCode).namesNative.first, isInline: true)];
    
    if (this.translated != null) {
      fs.add(EmbedFieldBuilder(name: Paren.guil.cover("翻訳"), value: this.translated, isInline: false));
    }
    
    if (this.contributor != null) {
      fs.add(EmbedFieldBuilder(name: Paren.guil.cover("提供"), value: this.contributor, isInline: this.translated != null));
    }
    return fs;
  }
  
  static Future<CXSRecord> fetch(CuratorSystem system) async {
    return CXSRecord.beta;
  }
  
  static CXSRecord get beta = CXSRecord(
    example: "愛・希望　君の言葉を　この胸に$nl　今日を明日を　歩みゆく",
  　lang: ,
  　contributor: "佐藤 陽花");
  static Locale defaultLang => Locale.parse("ja");
}
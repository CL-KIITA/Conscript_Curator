import "dart:convert";

const LineSplitter ls = LineSplitter();

const String nl = "\n";
const String quot = "\"";
const String dash = "'";

class Paren {
  final String open;
  final String close;
  
  const Paren(this.open, this.close);
  const Paren.sym(String symbol):
    this.open = symbol,
    this.close = symbol;
  
  static const curl = const Paren("{", "}");
  static const square = const Paren("[", "]");
  static const quot = const Paren.sym(quot);
  static const angle = const Paren("<", ">");
  static const round = const Paren("(", ")");
}

extension StringNuked on String {
  String toNuked({String start = "", String? end}){
    if(this.startsWith(start) && this.endsWith(end ?? start)){
      return this.substring(start.length, this.length - end.length);
    }
    throw FormatException("the string must starts \"$start\" and ends \"$end\", but input is not.", this);
  }
}

T asIdentical<T>(T value) => value;
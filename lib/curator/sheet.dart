import "package:gsheets/gsheets.dart";

import "package:conscript_curator/curator/ref.dart";
import "package:conscript_curator/curator/kernel.dart";

extension GSheetsSheets on CuratorSystem {
  Future<Spreadsheet> formSS => this.secrets.gSheets.spreadsheet(this.config.formId);
  Future<Spreadsheet> dbSS => this.secrets.gSheets.spreadsheet(this.config.dbId);
  Future<Worksheet> get formSheet async {
    Spreadsheet ss = await this.formSS;
    return ss.worksheetByIndex(0)!;
  }
  Future<Worksheet> get dbSheet async {
    Spreadsheet ss = await this.dbSS;
    return ss.worksheetByTitle(this.config.sheetName)!;
  }
}
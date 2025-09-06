import "package:gsheets/gsheets.dart";

import "package:conscript_curator/xlib/collection.dart";
import "package:conscript_curator/curator/ref.dart";
import "package:conscript_curator/curator/kernel.dart";

/**
 * - `name`: label name for display or as identifier of label records
 * - `pos`: integer of label position
 *   - zero or positive: 0 indexed column for A, B, C,...
 *   - negative: non existence with canonical value `-1`
 */
typedef SheetLabel = ({String name, int pos});

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
extension on Worksheet {
  Future<List<List<Cell>>> loadLines({
    Iterable<SheetLabel>? labels
    Range? colRange,
    Range? range
  }) async {
    final bool noLabel = labels == null || labels.isEmpty;
    int rowCount = this.rowCount;
    int columnCount = this.columnCount;
    if (range !== null) {
      if (0 > range.count || range.count > rowCount) {
        throw RangeError.range(range.count, 0, rowCount);
      }
    }
    if (noLabel) {
      if (range == null) {
        throw RangeError("either `labels` or `range` is required");
      }
    }
    WorksheetAsCells wsas = this.cells;
    if (!noLabel) {
      List<Cell> labelRow = await wsas.row(1,
      fromColumn: 1,
      length: labels?.length ?? colRange?.count ?? throw 0);
      if (!(labels!.every((SheetLabel l) => labelRow[l.pos] == l.name))) {
        throw FormatException("at least one of specified labels are not exist");
      }
    }
    
    List<List<Cell>> dataRows = await wsas.allRows(
      fromRow: (noLabel ? 0 : 1) + (range?.first ?? 1),
      fromColumn: 1
      length: labels?.length ?? colRange?.length ?? throw 0,
      count: count: range?.count ?? -1
    );
    
    if (noLabel) {
      return dataRows;
    } else {
      return dataRows
        .map<List<Cell>>((List<Cell> row)
          => labels
            .map<Cell>((SheetLabel l)
              => row[l.pos])
            .toList())
        .toList();
    }
  }
  Future<Iterable<E>> getRecords<E>({
    required E Function(List<Cell>) builder,
    Iterable<SheetLabel>? labels
    Range? range
  }) async {
    return await this.loadLines(labels: labels, range: range);
      .map<E>((List<Cell> row) => builder(row));
  }
}
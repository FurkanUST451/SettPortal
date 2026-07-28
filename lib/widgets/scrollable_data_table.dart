import 'package:flutter/material.dart';

/// A [DataTable] that scrolls both horizontally (when the window is
/// narrower than the table's natural width) and vertically (when there are
/// more rows than fit). Plain `SingleChildScrollView(child: DataTable(...))`
/// only scrolls vertically, so a DataTable wider than the viewport throws a
/// render overflow the moment the window is resized smaller.
class ScrollableDataTable extends StatelessWidget {
  final List<DataColumn> columns;
  final List<DataRow> rows;

  /// Whether to show the leading checkbox column. Only meaningful when rows
  /// set `selected`/`onSelectChanged` for real multi-select (Kullanıcılar,
  /// İçerik Moderasyonu) — leave false for list-and-open screens
  /// (Konuşmalar, Audit Log) where there's no bulk action to perform.
  final bool showCheckboxColumn;

  const ScrollableDataTable({
    super.key,
    required this.columns,
    required this.rows,
    this.showCheckboxColumn = false,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: ConstrainedBox(
            constraints: BoxConstraints(minWidth: constraints.maxWidth),
            child: SingleChildScrollView(
              child: DataTable(
                showCheckboxColumn: showCheckboxColumn,
                columns: columns,
                rows: rows,
              ),
            ),
          ),
        );
      },
    );
  }
}

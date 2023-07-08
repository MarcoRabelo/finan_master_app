import 'package:finan_master_app/infra/data_sources/database_local/database_operation.dart';
import 'package:finan_master_app/infra/data_sources/database_local/i_database_batch.dart';

abstract interface class IDatabaseLocal {
  IDatabaseBatch batch();

  Future<int> insert(String table, Map<String, dynamic> values);

  Future<int> update(String table, Map<String, dynamic> values, {String? where, List<dynamic>? whereArgs});

  Future<int> delete(String table, {String? where, List<dynamic>? whereArgs});

  Future<void> execute(String sql, [List<dynamic>? arguments]);

  Future<dynamic> raw(String sql, DatabaseOperation operation, [List<dynamic>? arguments]);

  Future<List<Map<String, dynamic>>> query(
    String table, {
    bool? distinct,
    List<String>? columns,
    String? where,
    List<dynamic>? whereArgs,
    String? groupBy,
    String? having,
    String? orderBy,
    int? limit,
    int? offset,
  });
}

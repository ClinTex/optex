export const idlFactory = ({ IDL }) => {
  const Result = IDL.Record({
    'errorCode' : IDL.Nat,
    'errorText' : IDL.Text,
    'errored' : IDL.Bool,
  });
  const ImmutableFieldDefinition = IDL.Record({
    'fieldName' : IDL.Text,
    'fieldType' : IDL.Text,
  });
  const ImmutableDataSource = IDL.Record({
    'data' : IDL.Vec(IDL.Vec(IDL.Text)),
    'dataSourceName' : IDL.Text,
    'fieldDefinitions' : IDL.Vec(ImmutableFieldDefinition),
  });
  const TableFieldInfo = IDL.Record({
    'fieldName' : IDL.Text,
    'fieldType' : IDL.Int,
  });
  const TableInfo = IDL.Record({
    'tableName' : IDL.Text,
    'fieldDefinitions' : IDL.Vec(TableFieldInfo),
    'recordCount' : IDL.Nat,
  });
  const DatabaseInfo = IDL.Record({
    'tables' : IDL.Vec(TableInfo),
    'databaseName' : IDL.Text,
  });
  const TableFragmentField = IDL.Record({
    'fieldName' : IDL.Text,
    'fieldType' : IDL.Int,
  });
  const TableFragment = IDL.Record({
    'total' : IDL.Int,
    'data' : IDL.Vec(IDL.Vec(IDL.Text)),
    'count' : IDL.Int,
    'fieldDefinitions' : IDL.Vec(TableFragmentField),
  });
  return IDL.Service({
    'addTableData' : IDL.Func(
        [IDL.Text, IDL.Text, IDL.Vec(IDL.Vec(IDL.Text))],
        [Result],
        [],
      ),
    'createDataSource' : IDL.Func([ImmutableDataSource], [], []),
    'createDatabase' : IDL.Func([IDL.Text], [Result], []),
    'createTable' : IDL.Func(
        [IDL.Text, IDL.Text, IDL.Vec(TableFieldInfo)],
        [Result],
        [],
      ),
    'getDatabaseInfo' : IDL.Func([IDL.Text], [DatabaseInfo], ['query']),
    'getTableData' : IDL.Func(
        [IDL.Text, IDL.Text, IDL.Nat, IDL.Nat],
        [TableFragment],
        ['query'],
      ),
    'hasDatabase' : IDL.Func([IDL.Text], [IDL.Bool], ['query']),
    'hasTable' : IDL.Func([IDL.Text, IDL.Text], [IDL.Bool], ['query']),
    'listDataSourceNames' : IDL.Func([], [IDL.Vec(IDL.Text)], ['query']),
    'listDataSources' : IDL.Func([], [IDL.Vec(ImmutableDataSource)], ['query']),
    'listDatabases' : IDL.Func([], [IDL.Vec(DatabaseInfo)], ['query']),
    'removeDatabase' : IDL.Func([IDL.Text], [Result], []),
    'removeTable' : IDL.Func([IDL.Text, IDL.Text], [Result], []),
    'test' : IDL.Func([], [TableFragment], []),
    'test2' : IDL.Func([], [IDL.Text], ['query']),
  });
};
export const init = ({ IDL }) => { return []; };

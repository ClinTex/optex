export const idlFactory = ({ IDL }) => {
  const Result = IDL.Record({
    'errorCode' : IDL.Nat,
    'resultIds' : IDL.Vec(IDL.Vec(IDL.Text)),
    'errorText' : IDL.Text,
    'errored' : IDL.Bool,
  });
  const TableFieldInfo = IDL.Record({
    'fieldName' : IDL.Text,
    'fieldType' : IDL.Int,
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
  const TableInfo = IDL.Record({
    'tableName' : IDL.Text,
    'fieldDefinitions' : IDL.Vec(TableFieldInfo),
    'recordCount' : IDL.Nat,
  });
  const DatabaseInfo = IDL.Record({
    'tables' : IDL.Vec(TableInfo),
    'databaseName' : IDL.Text,
  });
  return IDL.Service({
    'addTableData' : IDL.Func(
        [IDL.Text, IDL.Text, IDL.Vec(IDL.Vec(IDL.Text))],
        [Result],
        [],
      ),
    'createDatabase' : IDL.Func([IDL.Text], [Result], []),
    'createTable' : IDL.Func(
        [IDL.Text, IDL.Text, IDL.Vec(TableFieldInfo)],
        [Result],
        [],
      ),
    'getAllTableData' : IDL.Func(
        [IDL.Text, IDL.Text],
        [TableFragment],
        ['query'],
      ),
    'getDatabaseInfo' : IDL.Func([IDL.Text], [DatabaseInfo], ['query']),
    'getTableInfo' : IDL.Func([IDL.Text, IDL.Text], [TableInfo], ['query']),
    'hasDatabase' : IDL.Func([IDL.Text], [IDL.Bool], ['query']),
    'hasTable' : IDL.Func([IDL.Text, IDL.Text], [IDL.Bool], ['query']),
    'listDatabases' : IDL.Func([], [IDL.Vec(DatabaseInfo)], ['query']),
    'removeDatabase' : IDL.Func([IDL.Text], [Result], []),
    'removeTable' : IDL.Func([IDL.Text, IDL.Text], [Result], []),
    'removeTableData' : IDL.Func(
        [IDL.Text, IDL.Text, IDL.Vec(IDL.Text)],
        [Result],
        [],
      ),
    'updateTableData' : IDL.Func(
        [IDL.Text, IDL.Text, IDL.Text, IDL.Vec(IDL.Text)],
        [Result],
        [],
      ),
  });
};
export const init = ({ IDL }) => { return []; };

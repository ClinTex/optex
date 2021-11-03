export const idlFactory = ({ IDL }) => {
  const Result = IDL.Record({
    'errorCode' : IDL.Nat,
    'errorText' : IDL.Text,
    'errored' : IDL.Bool,
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
  return IDL.Service({
    'addTableData' : IDL.Func(
        [IDL.Text, IDL.Text, IDL.Vec(IDL.Vec(IDL.Text))],
        [Result],
        [],
      ),
    'applyTableTransform' : IDL.Func(
        [IDL.Text, IDL.Text, IDL.Text, IDL.Vec(IDL.Vec(IDL.Text))],
        [TableFragment],
        ['query'],
      ),
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
    'getTableInfo' : IDL.Func([IDL.Text, IDL.Text], [TableInfo], ['query']),
    'hasDatabase' : IDL.Func([IDL.Text], [IDL.Bool], ['query']),
    'hasTable' : IDL.Func([IDL.Text, IDL.Text], [IDL.Bool], ['query']),
    'listDatabases' : IDL.Func([], [IDL.Vec(DatabaseInfo)], ['query']),
    'removeDatabase' : IDL.Func([IDL.Text], [Result], []),
    'removeTable' : IDL.Func([IDL.Text, IDL.Text], [Result], []),
    'updateTableData' : IDL.Func(
        [IDL.Text, IDL.Text, IDL.Text, IDL.Text, IDL.Vec(IDL.Text)],
        [Result],
        [],
      ),
  });
};
export const init = ({ IDL }) => { return []; };

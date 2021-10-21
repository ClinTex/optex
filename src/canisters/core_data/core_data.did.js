export const idlFactory = ({ IDL }) => {
  const ImmutableFieldDefinition = IDL.Record({
    'fieldName' : IDL.Text,
    'fieldType' : IDL.Text,
  });
  const ImmutableDataSource = IDL.Record({
    'data' : IDL.Vec(IDL.Vec(IDL.Text)),
    'dataSourceName' : IDL.Text,
    'fieldDefinitions' : IDL.Vec(ImmutableFieldDefinition),
  });
  return IDL.Service({
    'createDataSource' : IDL.Func([ImmutableDataSource], [], []),
    'listDataSourceNames' : IDL.Func([], [IDL.Vec(IDL.Text)], ['query']),
    'listDataSources' : IDL.Func([], [IDL.Vec(ImmutableDataSource)], ['query']),
  });
};
export const init = ({ IDL }) => { return []; };

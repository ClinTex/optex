import type { Principal } from '@dfinity/principal';
export interface ImmutableDataSource {
  'data' : Array<Array<string>>,
  'dataSourceName' : string,
  'fieldDefinitions' : Array<ImmutableFieldDefinition>,
}
export interface ImmutableFieldDefinition {
  'fieldName' : string,
  'fieldType' : string,
}
export interface _SERVICE {
  'createDataSource' : (arg_0: ImmutableDataSource) => Promise<undefined>,
  'listDataSourceNames' : () => Promise<Array<string>>,
  'listDataSources' : () => Promise<Array<ImmutableDataSource>>,
}

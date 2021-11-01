import type { Principal } from '@dfinity/principal';
export interface DatabaseInfo {
  'tables' : Array<TableInfo>,
  'databaseName' : string,
}
export interface ImmutableDataSource {
  'data' : Array<Array<string>>,
  'dataSourceName' : string,
  'fieldDefinitions' : Array<ImmutableFieldDefinition>,
}
export interface ImmutableFieldDefinition {
  'fieldName' : string,
  'fieldType' : string,
}
export interface Result {
  'errorCode' : bigint,
  'errorText' : string,
  'errored' : boolean,
}
export interface TableFieldInfo { 'fieldName' : string, 'fieldType' : bigint }
export interface TableFragment {
  'total' : bigint,
  'data' : Array<Array<string>>,
  'count' : bigint,
  'fieldDefinitions' : Array<TableFragmentField>,
}
export interface TableFragmentField {
  'fieldName' : string,
  'fieldType' : bigint,
}
export interface TableInfo {
  'tableName' : string,
  'fieldDefinitions' : Array<TableFieldInfo>,
  'recordCount' : bigint,
}
export interface _SERVICE {
  'addTableData' : (
      arg_0: string,
      arg_1: string,
      arg_2: Array<Array<string>>,
    ) => Promise<Result>,
  'createDataSource' : (arg_0: ImmutableDataSource) => Promise<undefined>,
  'createDatabase' : (arg_0: string) => Promise<Result>,
  'createTable' : (
      arg_0: string,
      arg_1: string,
      arg_2: Array<TableFieldInfo>,
    ) => Promise<Result>,
  'getDatabaseInfo' : (arg_0: string) => Promise<DatabaseInfo>,
  'getTableData' : (
      arg_0: string,
      arg_1: string,
      arg_2: bigint,
      arg_3: bigint,
    ) => Promise<TableFragment>,
  'hasDatabase' : (arg_0: string) => Promise<boolean>,
  'hasTable' : (arg_0: string, arg_1: string) => Promise<boolean>,
  'listDataSourceNames' : () => Promise<Array<string>>,
  'listDataSources' : () => Promise<Array<ImmutableDataSource>>,
  'listDatabases' : () => Promise<Array<DatabaseInfo>>,
  'removeDatabase' : (arg_0: string) => Promise<Result>,
  'removeTable' : (arg_0: string, arg_1: string) => Promise<Result>,
  'test' : () => Promise<TableFragment>,
  'test2' : () => Promise<string>,
}

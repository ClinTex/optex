import type { Principal } from '@dfinity/principal';
export interface DatabaseInfo {
  'tables' : Array<TableInfo>,
  'databaseName' : string,
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
  'applyTableTransform' : (
      arg_0: string,
      arg_1: string,
      arg_2: string,
      arg_3: Array<Array<string>>,
    ) => Promise<TableFragment>,
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
  'getTableInfo' : (arg_0: string, arg_1: string) => Promise<TableInfo>,
  'hasDatabase' : (arg_0: string) => Promise<boolean>,
  'hasTable' : (arg_0: string, arg_1: string) => Promise<boolean>,
  'listDatabases' : () => Promise<Array<DatabaseInfo>>,
  'removeDatabase' : (arg_0: string) => Promise<Result>,
  'removeTable' : (arg_0: string, arg_1: string) => Promise<Result>,
  'updateTableData' : (
      arg_0: string,
      arg_1: string,
      arg_2: string,
      arg_3: string,
      arg_4: Array<string>,
    ) => Promise<Result>,
}

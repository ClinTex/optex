import Text     "mo:base/Text";
import Map      "mo:base/TrieMap";
import Array    "mo:base/Array";
import Buffer   "mo:base/Buffer";
import Int      "mo:base/Int";
import Nat32    "mo:base/Nat32";

import Debug    "mo:base/Debug";

module {
    ////////////////////////////////////////////////////////////////////////////////////////////////
    // Types
    ////////////////////////////////////////////////////////////////////////////////////////////////
    public module ErrorCode {
        public let AlreadyExists = 1001;
        public let DoesNotExist = 1002;
    };

    public module FieldType {
        public let Unknown              = 0;
        public let String               = 1;
        public let Number               = 2;
        public let AutoIncrementNumber  = 3;
        public let Boolean              = 4;

        public func debugPrint(value:Int):Text {
            if (value == Unknown) {
                return "unknown";
            };
            if (value == String) {
                return "string";
            };
            if (value == Number) {
                return "number";
            };
            if (value == AutoIncrementNumber) {
                return "number (auto increment)";
            };
            if (value == Boolean) {
                return "boolean";
            };
            return "unspecified";
        }
    };

    public type FieldDefinition = {
        var fieldName:Text;
        var fieldType:Int;
    };

    ////////////////////////////////////////////////////////////////////////////////////////////////
    // Immutable types
    ////////////////////////////////////////////////////////////////////////////////////////////////
    public type DatabaseInfo = {
        databaseName:Text;
        tables:[TableInfo];
    };

    public type TableInfo = {
        tableName:Text;
        fieldDefinitions:[TableFieldInfo];
        recordCount:Nat;
    };

    public type TableFieldInfo = {
        fieldName:Text;
        fieldType:Int;
    };

    ////////////////////////////////////////////////////////////////////////////////////////////////
    // DatabaseManager
    ////////////////////////////////////////////////////////////////////////////////////////////////
    public class DatabaseManager() {
        public var databases = Map.TrieMap<Text, Database>(Text.equal, Text.hash);

        public func createDatabase(name:Text):Database {
            var db = Database(name);
            databases.put(name, db);
            return db;
        };

        public func removeDatabase(name:Text):?Database {
            databases.remove(name);
        };

        public func listDatabaseNames():[Text] {
            var names:[Text] = [];
            for (key in databases.keys()) {
                names := Array.append(names, [key]);
            };
            return names;
        };

        public func getDatabase(name:Text):?Database {
            return databases.get(name);
        };

        public func getDatabaseInfo(name:Text):DatabaseInfo {
            switch(databases.get(name)) {
                case null {
                    return {
                        databaseName = "";
                        tables = [];
                    };
                };
                case (?db) {
                    return db.getInfo();
                };
            };
        };

        public func existsDatabase(name:Text):Bool {
            switch(databases.get(name)) {
                case null return false;
                case (?database) return true;
            };
        };

        public func getDatabaseTable(databaseName:Text, tableName:Text):?Table {
            switch(getDatabase(databaseName)) {
                case null { };
                case (?db) {
                    return db.getTable(tableName);
                };
            };

            return null;
        };
    };

    ////////////////////////////////////////////////////////////////////////////////////////////////
    // Database
    ////////////////////////////////////////////////////////////////////////////////////////////////
    public class Database(databaseName:Text) {
        var name:Text = databaseName;
        var tables = Map.TrieMap<Text, Table>(Text.equal, Text.hash);

        public func getName():Text {
            return databaseName;
        };

        public func listTableNames():[Text] {
            var names:[Text] = [];
            for (key in tables.keys()) {
                names := Array.append(names, [key]);
            };
            return names;
        };

        public func createTable(name:Text, fieldDefinitions:[TableFieldInfo]):Table {
            var table = Table(name);
            for (fd in fieldDefinitions.vals()) {
                table.getSchema().defineField(fd.fieldName, fd.fieldType);
            };
            tables.put(name, table);
            return table;
        };

        public func getTable(name:Text):?Table {
            return tables.get(name);
        };

        public func existsTable(name:Text):Bool {
            switch(tables.get(name)) {
                case null return false;
                case (?table) return true;
            };
        };

        public func removeTable(name:Text):?Table {
            tables.remove(name);
        };

        public func getInfo():DatabaseInfo {
            var tableInfos:[TableInfo] = [];
            for (t in tables.vals()) {
                tableInfos := Array.append(tableInfos, [t.getInfo()]);
            };
            return {
                databaseName = getName();
                tables = tableInfos;
            };
        };

        public func debugPrint() {
            Debug.print("" # name # ": ");
            for (table in tables.vals()) {
                table.debugPrint();
            }
        };
    };

    ////////////////////////////////////////////////////////////////////////////////////////////////
    // Table Schema
    ////////////////////////////////////////////////////////////////////////////////////////////////
    public class TableSchema() {
        public var fieldDefinitions:[FieldDefinition] = [];

        public func defineField(fieldName:Text, fieldType:Int) {
            if (isFieldDefined(fieldName) == false) {
                fieldDefinitions := Array.append(fieldDefinitions, [ { var fieldName = fieldName; var fieldType = fieldType } ]);
            };
        };

        public func isFieldDefined(fieldName:Text):Bool {
            for (f in fieldDefinitions.vals()) {
                if (f.fieldName == fieldName) {
                    return true;
                };
            };
            return false;
        };

        public func fieldIndex(fieldName:Text):Int {
            var n:Nat = 0;
            for (f in fieldDefinitions.vals()) {
                if (f.fieldName == fieldName) {
                    return n;
                };
                n := n + 1;
            };
            return -1;
        };

        public func debugPrint() {
            Debug.print("    field defs:");
            for (f in fieldDefinitions.vals()) {
                Debug.print("      " # f.fieldName # ": " # FieldType.debugPrint(f.fieldType));
            };
        };
    };

    ////////////////////////////////////////////////////////////////////////////////////////////////
    // Table
    ////////////////////////////////////////////////////////////////////////////////////////////////
    public class Table(tableName:Text) {
        var name:Text = tableName;
        public var schema:TableSchema = TableSchema();
        var data = Map.TrieMap<Text, [Text]>(Text.equal, Text.hash);
        var autoIncrement = Map.TrieMap<Text, Nat32>(Text.equal, Text.hash);

        public func getName():Text {
            return name;
        };

        public func getSchema():TableSchema {
            return schema;
        };

        private func getNextAutoNumber(fieldName:Text):Nat32 {
            var autoNumber:Nat32 = 0;
            switch (autoIncrement.get(fieldName)) {
                case null { };
                case (?val) {
                    autoNumber := val;
                };
            };

            autoNumber := autoNumber + 1;
            autoIncrement.put(fieldName, autoNumber);

            return autoNumber;
        };

        public func addRow(values:[Text]):[Text] {
            var recordString = "";
            var finalValues:[Text] = [];
            var resultIds:[Text] = [];

            var n:Nat = 0;
            for (fd in schema.fieldDefinitions.vals()) {
                var v:Text = "";
                if (fd.fieldType == FieldType.AutoIncrementNumber) {
                    var autoNumber:Nat32 = getNextAutoNumber(fd.fieldName);
                    v := Nat32.toText(autoNumber);
                    resultIds := Array.append(resultIds, [v]);
                } else {
                    v := values[n];
                };
                n := n + 1;
                recordString := recordString # "_" # v;
                finalValues := Array.append(finalValues, [v]);
            };
            
            var hash:Text = Nat32.toText(Text.hash(recordString));
            finalValues := Array.append(finalValues, [hash]);
            data.put(hash, finalValues);

            return resultIds;
        };

        public func addRows(rows:[[Text]]):[[Text]] {
            var resultIds:[[Text]] = [];
            for (r in rows.vals()) {
                var rowIds = addRow(r);
                resultIds := Array.append(resultIds, [rowIds]);
            };
            return resultIds;
        };

        public func getAllRows():TableFragment {
            if (data.size() == 0) {
                return EmptyTableFragment;
            };

            var fieldDefinitions:[TableFragmentField] = [];
            for (fd in schema.fieldDefinitions.vals()) {
                fieldDefinitions := Array.append(fieldDefinitions, [{ fieldName = fd.fieldName; fieldType = fd.fieldType; }]);
            };

            var fragmentData:[[Text]] = [];
            var count:Int = 0;
            for (row in data.vals()) {
                fragmentData := Array.append(fragmentData, [row]);
                count := count + 1;
            };

            var f:TableFragment = {
                fieldDefinitions = fieldDefinitions;
                total = data.size();
                count = count;
                data = fragmentData;
            };
            return f;
        };

        public func getInfo():TableInfo {
            var fieldDefinitions:[TableFieldInfo] = [];
            for (fd in schema.fieldDefinitions.vals()) {
                fieldDefinitions := Array.append(fieldDefinitions, [{fieldName = fd.fieldName; fieldType = fd.fieldType;}]);
            };
            return  {
                fieldDefinitions = fieldDefinitions;
                tableName = getName();
                recordCount = data.size();
            };
        };

        public func updateRow(hash:Text, newValues:[Text]) {
            var recordString = "";
            var finalValues:[Text] = [];

            var currentValues:[Text] = [];
            switch (data.get(hash)) {
                case null { };
                case (?val) {
                    currentValues := val;
                };
            };

            var n:Nat = 0;
            for (fd in schema.fieldDefinitions.vals()) {
                var v:Text = "";
                v := newValues[n];
                n := n + 1;
                recordString := recordString # "_" # v;
                finalValues := Array.append(finalValues, [v]);
            };

            data.delete(hash);

            var newHash:Text = Nat32.toText(Text.hash(recordString));
            finalValues := Array.append(finalValues, [newHash]);
            data.put(newHash, finalValues);
        };

        public func deleteRow(hash:Text) {
            data.delete(hash);
        };

        public func deleteRows(hash:[Text]) {
            for (h in hash.vals()) {
                deleteRow(h);
            };
        };

        public func debugPrint() {
            Debug.print("  " # name # ": ");
            schema.debugPrint();
            Debug.print("    total rows: " # Int.toText(data.size()));
        };
    };

    ////////////////////////////////////////////////////////////////////////////////////////////////
    // Table Fragment
    ////////////////////////////////////////////////////////////////////////////////////////////////
    public type TableFragmentField = {
        fieldName:Text;
        fieldType:Int;
    };

    public type TableFragment = {
        fieldDefinitions:[TableFragmentField];
        data:[[Text]];
        total:Int;
        count:Int;
    };

    public let EmptyTableFragment:TableFragment = {
        fieldDefinitions:[TableFragmentField] = [];
        data:[[Text]] = [];
        total:Int = 0;
        count:Int = 0;
    };
};

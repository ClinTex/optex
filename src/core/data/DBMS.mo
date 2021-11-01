import Text "mo:base/Text";
import Map "mo:base/HashMap";
import Array "mo:base/Array";
import Int "mo:base/Int";

import Debug "mo:base/Debug";

module {
    ////////////////////////////////////////////////////////////////////////////////////////////////
    // Types
    ////////////////////////////////////////////////////////////////////////////////////////////////
    public module ErrorCode {
        public let AlreadyExists = 1001;
        public let DoesNotExist = 1002;
    };

    public module FieldType {
        public let Unknown = 0;
        public let String = 1;
        public let Number = 2;
        public let Boolean = 3;

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
        public var databases = Map.HashMap<Text, Database>(0, Text.equal, Text.hash);

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
    };

    ////////////////////////////////////////////////////////////////////////////////////////////////
    // Database
    ////////////////////////////////////////////////////////////////////////////////////////////////
    public class Database(databaseName:Text) {
        var name:Text = databaseName;
        var tables = Map.HashMap<Text, Table>(0, Text.equal, Text.hash);

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
        var schema:TableSchema = TableSchema();
        var data:[[Text]] = [];

        public func getName():Text {
            return name;
        };

        public func getSchema():TableSchema {
            return schema;
        };

        public func addRow(values:[Text]) {
            data := Array.append(data, [values]);
        };

        public func addRows(rows:[[Text]]) {
            for (r in rows.vals()) {
                addRow(r);
            };
        };

        public func getRow(index:Nat):[Text] {
            return data[index];
        };

        public func getPage(page:Nat, pageSize:Nat):TableFragment {
            var start:Nat = (page - 1) * pageSize;
            var end:Nat = start + (page * pageSize);
            return getRows(start, end);
        };

        public func getRows(start:Nat, end:Nat):TableFragment {
            var actualEnd:Nat = end;
            if (actualEnd > Int.abs(data.size() - 1)) {
                actualEnd := Int.abs(data.size() - 1);
            };

            var fieldDefinitions:[TableFragmentField] = [];
            for (fd in schema.fieldDefinitions.vals()) {
                fieldDefinitions := Array.append(fieldDefinitions, [{ fieldName = fd.fieldName; fieldType = fd.fieldType; }]);
            };

            var n = start;
            var fragmentData:[[Text]] = [];
            var count:Int = 0;
            while (n <= actualEnd) {
                fragmentData := Array.append(fragmentData, [data[n]]);
                n := n + 1;
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

        public func findRows(fieldName:Text, fieldValue:Text):TableFragment {
            var fieldDefinitions:[TableFragmentField] = [];
            for (fd in schema.fieldDefinitions.vals()) {
                fieldDefinitions := Array.append(fieldDefinitions, [{ fieldName = fd.fieldName; fieldType = fd.fieldType; }]);
            };

            var fragmentData:[[Text]] = [];
            var count:Int = 0;
            var fieldIndex = schema.fieldIndex(fieldName);
            var x = fieldIndex;
            if (fieldIndex > -1) {
                for (d in data.vals()) {
                    if (d[Int.abs(x)] == fieldValue) {
                        fragmentData := Array.append(fragmentData, [d]);
                    };
                };
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
};
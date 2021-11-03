import Text  "mo:base/Text";
import Map   "mo:base/HashMap";
import Array "mo:base/Array";
import Int   "mo:base/Int";
import Nat   "mo:base/Nat";

import Types      "../types";
import DBMS       "DBMS";
import Transforms "Transforms";
import Debug "mo:base/Debug";

actor Data {
    let DatabaseManager = DBMS.DatabaseManager();

    ////////////////////////////////////////////////////////////////////////////////////////////////
    // Databases
    ////////////////////////////////////////////////////////////////////////////////////////////////
    public query func listDatabases():async [DBMS.DatabaseInfo] {
        var dbs:[DBMS.DatabaseInfo] = [];
        for (db in DatabaseManager.databases.vals()) {
            dbs := Array.append(dbs, [db.getInfo()]);
        };
        return dbs;
    };

    public shared(msg) func createDatabase(databaseName:Text):async Types.Result {
        if (DatabaseManager.existsDatabase(databaseName) == true) {
            return {
                errored = true;
                errorCode = DBMS.ErrorCode.AlreadyExists;
                errorText = "database '" # databaseName # "' already exists";
            };
        };

        var db = DatabaseManager.createDatabase(databaseName);

        return {
            errored = false;
            errorText = "";
            errorCode = 0;
        };
    };

    public shared(msg) func removeDatabase(databaseName:Text):async Types.Result {
        if (DatabaseManager.existsDatabase(databaseName) == false) {
            return {
                errored = true;
                errorCode = DBMS.ErrorCode.DoesNotExist;
                errorText = "database '" # databaseName # "' does not exist";
            };
        };

        var db = DatabaseManager.removeDatabase(databaseName);

        return {
            errored = false;
            errorText = "";
            errorCode = 0;
        };
    };

    public query func hasDatabase(databaseName:Text):async Bool {
        return DatabaseManager.existsDatabase(databaseName);
    };

    public query func getDatabaseInfo(databaseName:Text):async DBMS.DatabaseInfo {
        return DatabaseManager.getDatabaseInfo(databaseName);
    };

    ////////////////////////////////////////////////////////////////////////////////////////////////
    // Tables
    ////////////////////////////////////////////////////////////////////////////////////////////////
    public shared(msg) func createTable(databaseName:Text, tableName:Text, fieldDefinitions:[DBMS.TableFieldInfo]):async Types.Result {
        switch(DatabaseManager.getDatabase(databaseName)) {
            case null {
                return {
                    errored = true;
                    errorCode = DBMS.ErrorCode.DoesNotExist;
                    errorText = "database '" # databaseName # "' does not exist";
                };
            };
            case (?db) {
                if (db.existsTable(tableName) == true) {
                    return {
                        errored = true;
                        errorCode = DBMS.ErrorCode.AlreadyExists;
                        errorText = "table '" # tableName # "' already exists";
                    };
                };
                var table = db.createTable(tableName, fieldDefinitions);
                return {
                    errored = false;
                    errorText = "";
                    errorCode = 0;
                };
            };
        };
    };

    public shared(msg) func removeTable(databaseName:Text, tableName:Text):async Types.Result {
        switch(DatabaseManager.getDatabase(databaseName)) {
            case null {
                return {
                    errored = true;
                    errorCode = DBMS.ErrorCode.DoesNotExist;
                    errorText = "database '" # databaseName # "' does not exist";
                };
            };
            case (?db) {
                if (db.existsTable(tableName) == false) {
                    return {
                        errored = true;
                        errorCode = DBMS.ErrorCode.DoesNotExist;
                        errorText = "table '" # tableName # "' does not exist";
                    };
                };
                var table = db.removeTable(tableName);
                return {
                    errored = false;
                    errorText = "";
                    errorCode = 0;
                };
            };
        };
    };

    public query func hasTable(databaseName:Text, tableName:Text):async Bool {
        switch(DatabaseManager.getDatabase(databaseName)) {
            case null {
                return false;
            };
            case (?db) {
                return db.existsTable(tableName);
            };
        };
    };

    public query func getTableInfo(databaseName:Text, tableName:Text):async DBMS.TableInfo {
        switch(DatabaseManager.getDatabase(databaseName)) {
            case null {
                return {
                    tableName = "";
                    fieldDefinitions = [];
                    recordCount = 0;
                };
            };
            case (?db) {
                switch (db.getTable(tableName)) {
                    case null {
                        return {
                            tableName = "";
                            fieldDefinitions = [];
                            recordCount = 0;
                        };
                    };
                    case (?table) {
                        return table.getInfo();
                    };
                };
            }
        };
        return {
            tableName = "";
            fieldDefinitions = [];
            recordCount = 0;
        };
    };

    ////////////////////////////////////////////////////////////////////////////////////////////////
    // Data
    ////////////////////////////////////////////////////////////////////////////////////////////////
    public shared(msg) func addTableData(databaseName:Text, tableName:Text, data:[[Text]]):async Types.Result {
        switch(DatabaseManager.getDatabase(databaseName)) {
            case null {
                return {
                    errored = true;
                    errorCode = DBMS.ErrorCode.DoesNotExist;
                    errorText = "database '" # databaseName # "' does not exist";
                };
            };
            case (?db) {
                switch(db.getTable(tableName)) {
                    case null {
                        return {
                            errored = true;
                            errorCode = DBMS.ErrorCode.DoesNotExist;
                            errorText = "table '" # tableName # "' does not exist";
                        };
                    };

                    case (?table) {
                        table.addRows(data);

                        return {
                            errored = false;
                            errorText = "";
                            errorCode = 0;
                        };
                    };
                };
            };
        };
    };

    public query func getTableData(databaseName:Text, tableName:Text, start:Nat, end:Nat):async DBMS.TableFragment {
        switch(DatabaseManager.getDatabase(databaseName)) {
            case null {
                return {
                    fieldDefinitions = [];
                    data = [];
                    total = 0;
                    count = 0; 
                };
            };
            case (?db) {
                switch(db.getTable(tableName)) {
                    case null {
                        return {
                            fieldDefinitions = [];
                            data = [];
                            total = 0;
                            count = 0; 
                        };
                    };

                    case (?table) {
                        return table.getRows(start, end);
                    };
                };
            };
        };
    };

    public shared(msg) func updateTableData(databaseName:Text, tableName:Text, fieldName:Text, fieldValue:Text, newData:[Text]):async Types.Result {
        switch (DatabaseManager.getDatabaseTable(databaseName, tableName)) {
            case null { };
            case (?table) {
                table.updateData(fieldName, fieldValue, newData);
                return {
                    errored = false;
                    errorText = "";
                    errorCode = 0;
                };
            };
        };

        return {
            errored = true;
            errorText = "Could not update data";
            errorCode = 2000;
        };
    };

    ////////////////////////////////////////////////////////////////////////////////////////////////
    // Transformations
    ////////////////////////////////////////////////////////////////////////////////////////////////
    public query func applyTableTransform(databaseName:Text, tableName:Text, transformId:Text, parameters:[[Text]]):async DBMS.TableFragment {
        switch (DatabaseManager.getDatabaseTable(databaseName, tableName)) {
            case null { };
            case (?table) {
                return Transforms.Create(transformId)(table, parameters);
            };
        };

        return DBMS.EmptyTableFragment;
    };
};

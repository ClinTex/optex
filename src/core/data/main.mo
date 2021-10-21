import Text  "mo:base/Text";
import Map   "mo:base/HashMap";
import Array "mo:base/Array";

import Types "../types";

actor Data {
    let dataSources = Map.HashMap<Text, Types.DataSource>(0, Text.equal, Text.hash);

    public shared(msg) func createDataSource(dataSource:Types.ImmutableDataSource):async() {
        dataSources.put(dataSource.dataSourceName, mutableDataSource(dataSource));
    };

    public query func listDataSourceNames():async [Text] {
        var names:[Text] = [];
        for (key in dataSources.keys()) {
            names := Array.append(names, [key]);
        };
        return names;
    };

    public query func listDataSources():async [Types.ImmutableDataSource] {
        var list:[Types.ImmutableDataSource] = [];
        for (ds in dataSources.vals()) {
            list := Array.append(list, [immutableDataSource(ds)]);
        };
        return list;
    };

    private func mutableFieldDefinition(fieldDefinition:Types.ImmutableFieldDefinition):Types.FieldDefinition {
        return {
            var fieldName = fieldDefinition.fieldName;
            var fieldType = fieldDefinition.fieldType;
        }
    };

    private func mutableDataSource(dataSource:Types.ImmutableDataSource):Types.DataSource {
        // convert field definitions to mutable
        var fieldDefinitions:[Types.FieldDefinition] = [];
        for (f in dataSource.fieldDefinitions.vals()) {
            fieldDefinitions := Array.append<Types.FieldDefinition>(fieldDefinitions, [mutableFieldDefinition(f)]);
        };

        // convert data to mutable
        var data:[[var Text]] = [];
        for (row in dataSource.data.vals()) {
            var temp:[var Text] = Array.thaw(row);
            data := Array.append<[var Text]>(data, [temp]);
        };

        return {
            var dataSourceName = dataSource.dataSourceName;
            var fieldDefinitions = fieldDefinitions;
            var data = data;
        };
    };

    private func immutableFieldDefinition(fieldDefinition:Types.FieldDefinition):Types.ImmutableFieldDefinition {
        return {
            fieldName = fieldDefinition.fieldName;
            fieldType = fieldDefinition.fieldType;
        }
    };

    private func immutableDataSource(dataSource:Types.DataSource):Types.ImmutableDataSource {
        // convert field definitions to immutable
        var fieldDefinitions:[Types.ImmutableFieldDefinition] = [];
        for (f in dataSource.fieldDefinitions.vals()) {
            fieldDefinitions := Array.append<Types.ImmutableFieldDefinition>(fieldDefinitions, [immutableFieldDefinition(f)]);
        };

        // convert data to immutable
        var data:[[Text]] = [];
        for (row in dataSource.data.vals()) {
            var temp:[Text] = Array.freeze(row);
            data := Array.append<[Text]>(data, [temp]);
        };

        return {
            dataSourceName = dataSource.dataSourceName;
            fieldDefinitions = fieldDefinitions;
            data = data;
        };
    }
}

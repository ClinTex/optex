import Map   "mo:base/HashMap";
import Text  "mo:base/Text";
import Int   "mo:base/Int";
import Nat   "mo:base/Nat";
import Array "mo:base/Array";

import DBMS  "DBMS";

module {
    public let Create = func(transformId:Text):(table:DBMS.Table, parameters:[[Text]]) -> (DBMS.TableFragment) {
        if (transformId == "count-unique") {
            return CountUniqueFieldValues;
        };
        return Empty;
    };

    public let Empty = func(table:DBMS.Table, parameters:[[Text]]):DBMS.TableFragment {
        return DBMS.EmptyTableFragment;
    };

    ////////////////////////////////////////////////////////////////////////////////////////////////
    // CountUniqueFieldValues
    ////////////////////////////////////////////////////////////////////////////////////////////////
    public let CountUniqueFieldValues = func(table:DBMS.Table, parameters:[[Text]]):DBMS.TableFragment {
        var data:[[Text]] = [];
        var fieldDefinitions:[DBMS.TableFragmentField] = [];
        var count = 0;
        var fieldName = extractParameterValue("fieldName", parameters);
        var fieldIndex = table.getSchema().fieldIndex(fieldName);
        var resultMap = Map.HashMap<Text, Nat>(0, Text.equal, Text.hash);

        for (row in table.data.vals()) {
            var rowValue = row[Int.abs(fieldIndex)];
            var currentCount = resultMap.get(rowValue);
            var newCount = 0;
            switch (currentCount) {
                case null {
                    newCount := 1;
                };
                case (?actual) {
                    newCount := actual + 1;
                };
            };
            resultMap.put(rowValue, newCount);
        };

        for (key in resultMap.keys()) {
            var value = resultMap.get(key);
            switch (value) {
                case null {};
                case (?actual) {
                    var row:[Text] = [key, Nat.toText(actual)];
                    data := Array.append(data, [row]);
                };
            };
        };

        return {
            fieldDefinitions = fieldDefinitions;
            data = data;
            total = count;
            count = count;
        };
    };

    ////////////////////////////////////////////////////////////////////////////////////////////////
    // Util
    ////////////////////////////////////////////////////////////////////////////////////////////////
    public func extractParameterValue(name:Text, parameters:[[Text]]):Text {
        for (pair in parameters.vals()) {
            if (pair[0] == name) {
                return pair[1];
            };
        };
        return "";
    };
};
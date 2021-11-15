import Map   "mo:base/HashMap";
import Text  "mo:base/Text";
import Int   "mo:base/Int";
import Nat   "mo:base/Nat";
import Array "mo:base/Array";
import Prim  "mo:⛔";
import Nat32 "mo:base/Nat32";
import Char  "mo:base/Char";

import DBMS  "DBMS";

module {
    public let Create = func(transformId:Text):(table:DBMS.Table, parameters:[[Text]]) -> (DBMS.TableFragment) {
        if (transformId == "count-unique") {
            return CountUniqueFieldValues;
        };
        if (transformId == "unique") {
            return CountUniqueFieldValues;
        };
        if (transformId == "group-by") {
            return GroupTableByField;
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
    // GroupTableBy
    ////////////////////////////////////////////////////////////////////////////////////////////////
    public let GroupTableByField = func(table:DBMS.Table, parameters:[[Text]]):DBMS.TableFragment {
        var data:[[Text]] = [];
        var fieldDefinitions:[DBMS.TableFragmentField] = [];
        for (fd in table.schema.fieldDefinitions.vals()) {
            fieldDefinitions := Array.append(fieldDefinitions, [{ fieldName = fd.fieldName; fieldType = fd.fieldType; }]);
        };

        var count = 0;
        var fieldName = extractParameterValue("fieldName", parameters);
        var fieldIndex = table.getSchema().fieldIndex(fieldName);
        var resultMap = Map.HashMap<Text, [Text]>(0, Text.equal, Text.hash);

        for (row in table.data.vals()) {
            var groupValue = row[Int.abs(fieldIndex)];
            switch(resultMap.get(groupValue)) {
                case null {
                    resultMap.put(groupValue, row);
                };
                case (?existing) {
                    var i = 0;
                    var newRow:[Text] = [];
                    for (existingValue in existing.vals()) {
                        var fieldType = table.schema.fieldDefinitions[i].fieldType;
                        var newValue = row[i];
                        if (fieldType == DBMS.FieldType.Number) {
                            var parsedExistingValue = parseInt(existingValue);
                            var parsedNewValue = parseInt(newValue);
                            var sum = parsedExistingValue + parsedNewValue;
                            newRow := Array.append(newRow, [Int.toText(sum)]);
                        } else {
                            newRow := Array.append(newRow, [newValue]);
                        };
                        i := i + 1;
                    };
                    resultMap.put(groupValue, newRow);
                };
            };
        };

        for (key in resultMap.keys()) {
            var value = resultMap.get(key);
            switch (value) {
                case null {};
                case (?actual) {
                    data := Array.append(data, [actual]);
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

    public func parseInt(text:Text):Nat {
        var i:Int = text.size() - 1;
        var factor:Nat = 1;
        var answer:Nat = 0;
        while (i >= 0) {
            var charIndex = 0;
            var c:Char = 'X';
            for (ch in text.chars()) {
                if (charIndex == i) {
                    c := ch;
                };
                charIndex := charIndex + 1;
            };
            if (Char.isDigit(c) == false) {
                return 0;
            };
            var v = Nat32.toNat(Prim.charToNat32(c) - Prim.charToNat32('0'));

            answer := answer + (v * factor);
            factor := factor * 10;

            i := i - 1;
        };

        return answer;
    };
};
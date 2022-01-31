package core.data;

import core.data.GenericTable;
import core.data.dao.IDataObject;
import core.data.utils.ConversionUtils;
import js.lib.Promise;

class GenericData implements IDataObject {
    public var table:GenericTable = null;
    
    private var data:Array<String> = [];
    
    public function new() {
    }
    
    public function fromArray(data:Array<Any>):Void {
        this.data = [];
        for (d in data) {
            this.data.push(ConversionUtils.toString(d));
        }
    }
    
    public function toArray():Array<String> {
        return data;
    }
    
    public function getFieldValue(fieldName:String):Any {
        var fieldIndex = table.getFieldIndex(fieldName);
        if (fieldIndex == -1) {
            return null;
        }
        
        var fieldDef = table.info.fieldDefinitions[fieldIndex];
        var fieldValue = data[fieldIndex];
        var convertedValue = ConversionUtils.fromString(fieldValue, fieldDef.fieldType);
        
        return convertedValue;
    }
    
    public function update():Promise<Bool> {
        return new Promise((resolve, reject) -> {
            resolve(true);
        });
    }
    
    public function add():Promise<Bool> {
        return new Promise((resolve, reject) -> {
            resolve(true);
        });
    }
}
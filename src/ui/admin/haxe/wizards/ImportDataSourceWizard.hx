package wizards;

import views.DataView;
import core.data.DataSource;
import haxe.ui.data.ArrayDataSource;
import js.lib.Promise;
import core.data.parsers.DataParser;
import core.data.parsers.CSVDataParser;

@:build(haxe.ui.ComponentBuilder.build("assets/wizards/import-datasource.xml"))
class ImportDataSourceWizard extends Wizard {
    private var _parser:DataParser;

    public function new() {
        super();
    }

    private override function onPageChanged() {
        switch (currentPage.id) {
            case "defineData":
                var fields = _parser.getFieldDefinitions();
                var ds = new ArrayDataSource<Dynamic>();
                for (f in fields) {
                    ds.add({
                        fieldEnabled: true,
                        fieldName: f.fieldName,
                        fieldType: f.fieldType
                    });
                }
                trace(fields);
                fieldDefinitionsTable.dataSource = ds;
            case "summary":
                summaryDataSourceName.text = dataSourceName.text;
                summaryFields.text = "" + _parser.getFieldDefinitions().length;
                summaryRecords.text = "" + _parser.getData().length;
            case _:    
        }
    }

    private override function onNext():Promise<Bool> {
        return new Promise((resolve, reject) -> {
            switch (currentPage.id) {
                case "selectType":
                    selectCSVFileButton.readContents().then(function(contents) {
                        _parser = new CSVDataParser();
                        _parser.parse(contents);
                        resolve(true);
                    });
                case _:
                    resolve(true);
            }
        });
    }

    private override function onFinish():Promise<Bool> {
        return new Promise((resolve, reject) -> {
            var ds = new DataSource();
            ds.name = summaryDataSourceName.text;
            for (f in _parser.getFieldDefinitions()) {
                ds.defineField(f.fieldName, f.fieldType);
            }
            ds.setData(_parser.getData());
            ds.commit().then(function(r) {
                resolve(true);
                DataView.instance.refresh(ds.name);
            });
        });
    }
}
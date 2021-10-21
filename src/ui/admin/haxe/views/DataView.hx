package views;

import haxe.ui.containers.TableView;
import js.lib.Reflect;
import haxe.ui.components.Column;
import haxe.ui.containers.Header;
import haxe.ui.events.UIEvent;
import wizards.ImportDataSourceWizard;
import haxe.ui.data.ArrayDataSource;
import haxe.ui.containers.VBox;
import haxe.ui.events.MouseEvent;
import core.data.CoreData;
import core.data.DataSourceManager;
import core.data.DataSource;

using StringTools;

@:build(haxe.ui.ComponentBuilder.build("assets/views/data.xml"))
class DataView extends VBox {
    public static var instance:DataView;

    public function new() {
        super();
        instance = this;
        refresh();
    }

    public function refresh(itemToSelect:String = null) {
        DataSourceManager.instance.refreshDataSources().then(function(result) {
            for (ds in result) {
                trace(ds.name + " => " + ds.rowCount);
            }
            populateUI(itemToSelect);
        });
    }

    private function populateUI(itemToSelect:String = null) {
        var indexToSelect = 0;
        var dataSources = new ArrayDataSource<Dynamic>();
        var n = 0;
        for (ds in DataSourceManager.instance.dataSources) {
            dataSources.add({
                name: ds.name,
                type: "static",
                fields: ds.fieldDefinitionCount,
                rows: ds.rowCount,
                dataSource: ds
            });
            if (itemToSelect != null && ds.name == itemToSelect) {
                indexToSelect = n;
            }
            n++;
        }

        dataSourceSelector.dataSource = dataSources;
        dataSourceSelector.selectedIndex = indexToSelect;
    }

    @:bind(addDataSourceButton, MouseEvent.CLICK)
    private function onAddDataSourceButton(e:MouseEvent) {
        var s = new ImportDataSourceWizard();
        s.show();
    }

    private var _table:TableView = null;
    @:bind(dataSourceSelector, UIEvent.CHANGE)
    private function onDataSourceSelectorChange(e:UIEvent) {
        if (dataSourceSelector.selectedItem == null) {
            return;
        }

        if (_table != null) {
            detailsContainer.removeComponent(_table);
        }

        _table = new TableView();
        _table.percentWidth = 100;
        _table.percentHeight = 100;

        var ds:DataSource = dataSourceSelector.selectedItem.dataSource;

        var header = new Header();
        header.percentWidth = 100;
        var pp = 100 / ds.fieldDefinitionCount;
        for (fd in ds.fieldDefinitions) {
            var column = new Column();
            column.id = fd.fieldName.replace(" ", "_");
            column.text = fd.fieldName;
            column.percentWidth = pp;
            header.addComponent(column);
        }

        _table.addComponent(header);

        var source = new ArrayDataSource<Dynamic>();
        for (r in ds.rows()) {
            var item = {};
            for (fd in ds.fieldDefinitions) {
                Reflect.setField(item, fd.fieldName.replace(" ", "_"), r.value(fd.fieldName));
            }
            source.add(item);
            trace(item);
        }
        _table.dataSource = source;
        detailsContainer.addComponent(_table);
    }








/*

    @:bind(createDataSource, MouseEvent.CLICK)
    private function onCreateDataSource(e:MouseEvent) {
        var ds = new DataSource();
        ds.name = "MyNewDataSource";
        ds.update().then(function(r) {
            trace("updated");
        });
    }

    @:bind(listDataSources, MouseEvent.CLICK)
    private function onListDataSources(e:MouseEvent) {
        CoreData.listDataSources().then(function(r) {
            trace(r);
        });
    }

    @:bind(testWizard, MouseEvent.CLICK)
    private function onTestWizard(e:MouseEvent) {
        var s = new ImportDataSourceWizard();
        s.show();
    }

    @:bind(test, MouseEvent.CLICK)
    private function onTest(e:MouseEvent) {
        var ds = new DataSource();
        ds.name = "MyOtherNewDataSource";
        ds.defineField("firstName", FieldType.String);
        ds.defineField("lastName", FieldType.String);
        ds.defineField("age", FieldType.Number);
        ds.defineField("male", FieldType.Boolean);

        ds.addRow("Ian", "Harrigan", 101, true);

        ds.row(0).value("firstName", "bob");

        for (row in ds.rows()) {
            trace("firstName = " + row.value("firstName"));
            trace("lastName = " + row.value("lastName"));
            trace("age = " + row.value("age"));
            trace("male = " + row.value("male"));
            trace(row);
        }

        trace(ds.row(0).value("firstName") == "bob");
        trace(ds.row(0).value("age") > 100);
        trace(ds.row(0).value("age") + 1);
        trace(ds.row(0).value("male") == true);

        ds.commit().then(function(r) {
            trace("commited");
        });
    }
    */
}

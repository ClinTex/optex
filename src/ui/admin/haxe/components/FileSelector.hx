package components;

import js.lib.Promise;
import haxe.ui.components.Label;
import js.html.FileReader;
import haxe.ui.components.Button;
import js.Browser;
import js.html.InputElement;
import haxe.ui.containers.HBox;

class FileSelector extends HBox {
    private var _fileInput:InputElement;
    private var _label:Label;
    private var _button:Button;

    public function new() {
        super();

        _label = new Label();
        _label.verticalAlign = "center";
        _label.text = "No file selected";
        addComponent(_label);

        _button = new Button();
        addComponent(_button);
        _button.onClick = function(_) {
            _fileInput.click();
        }
    }

    private var _file:Dynamic = null;
    private override function onReady() {
        super.onReady();

        _fileInput = Browser.document.createInputElement();
        _fileInput.type = "file";
        _fileInput.style.display = "none";
        this.element.appendChild(_fileInput);
        _fileInput.onchange = function(e) {
            _file = e.target.files[0]; 
            _label.text = _file.name;
        }
    }

    public function readContents():Promise<Dynamic> {
        return new Promise((resolve, reject) -> {
            if (_file == null) {
                resolve(null);
            } else {
                var reader = new FileReader();
                reader.readAsText(_file,'UTF-8');
                reader.onload = function(readerEvent) {
                    var content = readerEvent.target.result; // this is the content!
                    resolve(content);
                }
            }
        });
    }

    private override function set_text(value:String):String {
        super.set_text(value);
        _button.text = value;
        return value;
    }
}
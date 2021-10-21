package wizards;

import js.lib.Promise;
import haxe.ui.components.Button;
import haxe.ui.Toolkit;
import haxe.ui.core.Component;
import haxe.ui.containers.dialogs.Dialog;

class Wizard extends Dialog {
    public var currentPage:Component = null;

    private var _pages:Array<Component> = [];
    private var _currentPageIndex:Int = 0;

    private var recenter:Bool = true;

    private var _originalTitle:String;
    private var _cancelButton:Button;
    private var _prevButton:Button;
    private var _nextButton:Button;
    private var _finishButton:Button;

    public function new() {
        super();

        buttons = DialogButton.CANCEL | "Previous" | "Next" | "Finish";
    }

    public function prevPage() {
        _currentPageIndex--;
        if (_currentPageIndex < 0) {
            _currentPageIndex = 0;
            return;
        }

        applyPage();
    }

    public function nextPage() {
        _currentPageIndex++;
        if (_currentPageIndex > _pages.length - 1) {
            _currentPageIndex--;
            return;
        }

        applyPage();
    }

    private function applyPage() {
        if (currentPage != null) {
            currentPage.hide();
        }
        currentPage = _pages[_currentPageIndex];
        currentPage.show();

        if (currentPage.text != null) {
            this.title = _originalTitle + " - " + currentPage.text;
        }

        if (_prevButton != null && _nextButton != null && _finishButton != null) {
            if (_currentPageIndex == 0) {
                _prevButton.hide();
                _nextButton.show();
                _finishButton.hide();
            } else if (_currentPageIndex == _pages.length - 1) {
                _prevButton.show();
                _nextButton.hide();
                _finishButton.show();
            } else {
                _prevButton.show();
                _nextButton.show();
                _finishButton.hide();
            }
        }

        if (recenter) {
            Toolkit.callLater(function() {
                centerDialogComponent(cast(this, Dialog));
            });
        }
    }

    public override function onReady() {
        super.onReady();
        _originalTitle = this.title;

        _prevButton = findComponent("previous", Button);
        _nextButton = findComponent("next", Button);
        _finishButton = findComponent("finish", Button);
        applyPage();
    }

    public override function addComponent(child:Component):Component {
        if (child.hasClass("dialog-container") == false) {
            child.hide();
            _pages.push(child);
        }
        return super.addComponent(child);
    }

    private override function validateDialog(button, fn:Bool->Void) {
        if (button == DialogButton.CANCEL) {
            fn(true);
            return;
        } else if (button == DialogButton.CLOSE) {
            fn(true);
            return;
        }

        if (button == "Previous") {
            onPrev().then(function(r) {
                if (r == true) {
                    prevPage();
                    onPageChanged();
                }
            });
        } else if (button == "Next") {
            onNext().then(function(r) {
                if (r == true) {
                    nextPage();
                    onPageChanged();
                }
            });
        } else if (button == "Finish") {
            onFinish().then(function(r) {
                fn(r);
            });
            return;
        }
        fn(false);
    }

    private function onPrev():Promise<Bool> {
        return new Promise((resolve, reject) -> {
            resolve(true);
        });
    }

    private function onNext():Promise<Bool> {
        return new Promise((resolve, reject) -> {
            resolve(true);
        });
    }

    private function onFinish():Promise<Bool> {
        return new Promise((resolve, reject) -> {
            resolve(true);
        });
    }

    private function onPageChanged() {

    }
}
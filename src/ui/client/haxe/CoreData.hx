package;

@:native("core_data")
extern class CoreData {
    static function size():js.lib.Promise<Int>;
    static function addContact(firstName:String, lastName:String, emailAddress:String):js.lib.Promise<Dynamic>;
    static function listContacts():js.lib.Promise<Array<Dynamic>>;
    static function removeContact(emailAddress:String):js.lib.Promise<Dynamic>;
}
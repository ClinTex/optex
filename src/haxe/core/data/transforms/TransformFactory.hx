package core.data.transforms;

using StringTools;

class TransformFactory {
    public static function getTransform(id:String):ITransform {
        var id = id.replace("-", "").replace("_", "");

        switch (id) {
            case "groupby":
                return new GroupBy();
            case "unique" | "countunique":
                return new CountUnique();
            case "average" | "avg":
                return new Average();
            case "filterby":
                return new FilterBy();
            case "addrow":
                return new AddRow();
            case "setfield":
                return new SetField();
        }
        return null;
    }
}
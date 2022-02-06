package core.util.color;

using StringTools;

class ColorCalculatorFactory {
    public static function getColorCalculator(id:String):IColorCalculator {
        var id = id.replace("-", "").replace("_", "").toLowerCase();

        switch (id) {
            case "range":
                return new RangeColorCalculator();
        }

        return null;
    }
}
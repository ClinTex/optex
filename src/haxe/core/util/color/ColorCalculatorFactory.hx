package core.util.color;

using StringTools;

class ColorCalculatorFactory {
    public static function getColorCalculator(s:String):IColorCalculator {
        if (s == null) {
            return null;
        }
        var s = s.replace("-", "").replace("_", "").toLowerCase();
        var details = new FunctionDetails(s);

        var inst:IColorCalculator = null;

        switch (details.name) {
            case "range":
                inst = new RangeColorCalculator();
        }

        if (inst != null) {
            inst.configure(details.params);
        }

        return inst;
    }
}
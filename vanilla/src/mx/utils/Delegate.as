class mx.utils.Delegate extends Object
{
    var func:Function;
	
    function Delegate(f)
    {
        super();
        func = f;
    }
	
    static function create(obj, func:Function)
    {
        var _loc2 = function ()
        {
            var _loc2 = arguments.callee.target;
            var _loc3 = arguments.callee.func;
            return (_loc3.apply(_loc2, arguments));
        };
        _loc2.target = obj;
        _loc2.func = func;
        return _loc2;
    }
	
    function createDelegate(obj)
    {
        return create(obj, func);
    }
}

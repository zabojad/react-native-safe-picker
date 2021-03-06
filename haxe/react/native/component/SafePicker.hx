package react.native.component;

import react.ReactComponent;
import react.ReactMacro.jsx;

import react.native.component.props.PickerProps;

@:jsRequire('react-native-safe-picker','default')
extern class RNSafePicker extends ReactComponentOfProps<PickerProps> {
    function isScrolling():js.Promise<Array<Bool>>;
    function isScrollingSynchronous():Array<Bool>;
}

typedef SafePickerState={
    scrolling:Bool
}
class SafePicker extends ReactComponentOf<PickerProps,SafePickerState> {
    function new(p){
        super(p);
        this.state = {scrolling:false};
#if safePickerSync
        trace('init SafePicker in sync mode');
#else
        trace('init SafePicker in async mode');
#end
    }
    var _r:RNSafePicker;
    function onRef(r){
        if(r==null) return;
        _r=r;
    }
#if safePickerSync
    override function shouldComponentUpdate(np:PickerProps,ns:SafePickerState):Bool{
        var ret:Array<Bool> = _r.isScrollingSynchronous();
        if (ret!=null) return !ret[0];
        else return true;
    }
#else
    override function componentWillReceiveProps(np:PickerProps){
        _r.isScrolling().then(function(v:Array<Bool>){ setState({scrolling:v[0]}); });
    }
    override function shouldComponentUpdate(np:PickerProps,ns:SafePickerState):Bool{
        return !ns.scrolling;
    }
#end
    override function render(){
        return jsx('
            <RNSafePicker {...props} ref={onRef} />
        ');
    }
}

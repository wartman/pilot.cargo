package pilot.cargo;

import tink.core.Callback;
import tink.state.Observable;
import pilot.Widget;
import pilot.VNode;

using pilot.Differ;

@:autoBuild(pilot.macro.WidgetBuilder.build({ stateful: false }))
class ReactiveWidget implements Widget {
  
  var _pilot_link:CallbackLink;
  var _pilot_observable:Observable<VNode>;
  var _pilot_vnode:VNode;

  public function build():VNode {
    throw 'abstract';
    return null;
  }

  public function render():VNode {
    if (_pilot_observable == null) {
      _pilot_observable = Observable.auto(build);
      _pilot_link = _pilot_observable.bind({ direct: true }, vn -> {
        if (_pilot_vnode == null) {
          _pilot_vnode = vn;
          _pilot_vnode.hooks.detach = () -> {
            _pilot_link.dissolve();
            _pilot_vnode = null;
            _pilot_observable = null;
          };
          return;
        }
        if (_pilot_vnode.node == null || _pilot_vnode == vn) return;
        _pilot_vnode.subPatch(vn);
      }); 
    }
    return _pilot_vnode;
  }

}

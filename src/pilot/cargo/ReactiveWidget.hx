package pilot.cargo;

import tink.core.Callback;
import tink.state.Observable;
import pilot.Widget;
import pilot.VNode;

using pilot.Differ;

@:autoBuild(pilot.macro.WidgetBuilder.build({ stateful: false }))
class ReactiveWidget implements Widget {
  
  @:noCompletion var _pilot_link:CallbackLink;
  @:noCompletion var _pilot_observable:Observable<VNode>;
  @:noCompletion var _pilot_vnode:VNode;

  public function build():VNode {
    throw 'abstract';
    return null;
  }

  public function render():VNode {
    if (_pilot_observable == null) {
      _pilot_observable = Observable.auto(build);
      _pilot_vnode = _pilot_observable.value;
      _pilot_vnode.hooks.detach = () -> {
        _pilot_link.dissolve();
        _pilot_vnode = null;
        _pilot_observable = null;
      };
      _pilot_link = _pilot_observable.bind(vn -> {
        _pilot_vnode.subPatch(vn);
      });
    }
    return _pilot_vnode;
  }

}

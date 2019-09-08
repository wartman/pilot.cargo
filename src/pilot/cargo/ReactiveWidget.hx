package pilot.cargo;

#if !pilot_cargo_constant
  import tink.core.Callback;
  import tink.state.Observable;

  using pilot.Differ;
#end

import pilot.Widget;
import pilot.VNode;


@:autoBuild(pilot.macro.WidgetBuilder.build({ stateful: false }))
class ReactiveWidget implements Widget {

  public function build():VNode {
    throw 'abstract';
    return null;
  }

  #if pilot_cargo_constant

    public function render():VNode {
      return build();
    }

  #else
  
    @:noCompletion var _pilot_link:CallbackLink;
    @:noCompletion var _pilot_vnode:VNode;
    @:noCompletion var _pilot_observable:Observable<VNode>;

    public function render():VNode {
      if (_pilot_observable == null) {
        _pilot_observable = Observable.auto(build);
        _pilot_vnode = _pilot_observable.value;
        var detach = _pilot_vnode.hooks.detach;
        _pilot_vnode.hooks.detach = () -> {
          if (detach != null) detach();
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

  #end

}

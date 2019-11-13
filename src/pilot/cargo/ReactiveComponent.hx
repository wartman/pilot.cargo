package pilot.cargo;

#if !pilot_cargo_constant
  import tink.core.Callback;
  import tink.state.Observable;
#end
import pilot.core.Context;
import pilot.Component;
import pilot.PureComponent;

@:coreComponent
class ReactiveComponent extends Component {

  #if !pilot_cargo_constant

    @:noCompletion var _pilot_link:CallbackLink;
    @:noCompletion var _pilot_observable:Observable<PureComponent>;

    override function _pilot_update(attrs:Dynamic, context:Context) {
      _pilot_context = context;
      _pilot_setProperties(attrs, context);
      _pilot_observable = Observable.auto(render);
      if (_pilot_link != null) _pilot_link.dissolve();
      _pilot_link = _pilot_observable.bind({ direct: true }, rendered -> {
        if (_pilot_wire == null && componentShouldRender(attrs)) {
          _pilot_doInitialRender(rendered, context);
        } else if (componentShouldRender(attrs)) {
          _pilot_doDiffRender(rendered, context);
        }
      });
    }

    override function _pilot_dispose() {
      if (_pilot_link != null) _pilot_link.dissolve();
      _pilot_observable = null;
      super._pilot_dispose();
    }

  #end

}

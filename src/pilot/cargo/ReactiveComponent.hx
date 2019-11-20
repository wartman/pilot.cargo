package pilot.cargo;

#if !pilot_cargo_constant
  import tink.core.Callback;
  import tink.state.Observable;
  import pilot.core.Context;
  import pilot.RenderResult;
#end
import pilot.Component;

@:coreComponent
class ReactiveComponent extends Component {

  #if !pilot_cargo_constant

    #if (js && debug && !nodejs)
      static final BEING_OBSERVED = '_pilot_BEING_OBSERVED';
    #end

    @:noCompletion var _pilot_link:CallbackLink;
    @:noCompletion var _pilot_observable:Observable<RenderResult>;

    override function _pilot_update(attrs:Dynamic, context:Context) {
      #if (js && debug && !nodejs)
        if (_pilot_context == null) {
          _pilot_context = context.copy();
          if (_pilot_context.get(BEING_OBSERVED) == true) {
            js.Browser.window.console.warn(
              'A ReactiveComponent is being used inside another '
              + 'ReactiveComponent. Consider only using ReactiveComponents '
              + 'at the highest level possible, otherwise you may see components '
              + 'render several times per Observable update.'
            );
          }
          _pilot_context.set(BEING_OBSERVED, true);
        }
      #else
        _pilot_context = context;
      #end
      _pilot_setProperties(attrs, context);
      if (_pilot_wire == null) _pilot_doInits();
      _pilot_observable = Observable.auto(render);
      if (_pilot_link != null) _pilot_link.dissolve();
      _pilot_link = _pilot_observable.bind({ direct: true }, rendered -> {
        if (_pilot_wire == null && _pilot_shouldRender(attrs)) {
          _pilot_doInitialRender(rendered, context);
        } else if (_pilot_shouldRender(attrs)) {
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

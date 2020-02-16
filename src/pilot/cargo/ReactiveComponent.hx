package pilot.cargo;

#if !pilot_cargo_constant
  import tink.core.Callback;
  import tink.state.Observable;
  import pilot.Context;
  import pilot.VNode;
  import pilot.Later;
#end
import pilot.Component;

@:coreComponent
class ReactiveComponent extends Component {

  #if !pilot_cargo_constant

    #if (js && debug && !nodejs)
      static final BEING_OBSERVED = '_pilot_BEING_OBSERVED';
    #end

    @:noCompletion var __link:CallbackLink;
    @:noCompletion var __observable:Observable<VNode>;

    @:noCompletion override function __update(
      attrs:Dynamic, 
      children:Array<VNode>, 
      context:Context,
      later:Later
    ) {
      if (!__alive) {
        throw 'Cannot update a component that has not been inserted';
      }
      
      #if (js && debug && !nodejs)
        if (__context == null) {
          __context = context.copy();
          if (__context.get(BEING_OBSERVED) == true) {
            js.Browser.window.console.warn(
              'A ReactiveComponent is being used inside another '
              + 'ReactiveComponent. Consider only using ReactiveComponents '
              + 'at the highest level possible, otherwise you may see components '
              + 'render several times per Observable update.'
            );
          }
          __context.set(BEING_OBSERVED, true);
        }
      #else
        __context = context;
      #end
      __updateAttributes(attrs, context);

      if (!__initialized) {
        __initialized = true;
        __doInits();
        __observable = Observable.auto(render);
      }
      if (__link != null) __link.dissolve();
      
      var currentRender:Bool = true;
      __link = __observable.bind(rendered -> {
        if (currentRender) {
          currentRender = false;
          return;
        }
        var later = new Later();
        var cursor = __getCursor();
        var previousLength = __nodes.length;
        __nodes = __updateChildren(switch rendered {
          case VFragment(children): children;
          case vn: [ vn ];
        }, __context, later);
        __setChildren(__nodes, cursor, previousLength);
        later.add(__doEffects);
        later.dispatch();
      });

      __nodes = __updateChildren(switch __observable.value {
        case VFragment(children): children;
        case vn: [ vn ];
      }, __context, later);
      later.add(__doEffects);
    }

    @:noCompletion override function __dispose() {
      if (__link != null) __link.dissolve();
      __observable = null;
      super.__dispose();
    }

  #end

}

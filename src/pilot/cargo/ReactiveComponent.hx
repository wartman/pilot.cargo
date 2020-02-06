package pilot.cargo;

#if !pilot_cargo_constant
  import tink.core.Callback;
  import tink.state.Observable;
  import pilot.Context;
  import pilot.VNode;
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

    @:noCompletion override function __update(attrs:Dynamic, children:Array<VNode>, context:Context) {
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
      
      __link = __observable.bind({ direct: true }, rendered -> {
        __cursor = new Cursor(__parent.__getReal(), __getFirstNode());
        __updateChildren(switch rendered {
          case VFragment(children): children;
          case vn: [ vn ];
        }, __context);
        Util.later(__doEffects);
        __cursor = null;
      });
    }

    @:noCompletion override function __dispose() {
      if (__link != null) __link.dissolve();
      __observable = null;
      super.__dispose();
    }

  #end

}

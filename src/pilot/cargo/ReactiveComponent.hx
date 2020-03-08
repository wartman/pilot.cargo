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

    @:noCompletion var __link:CallbackLink;
    @:noCompletion var __observableRender:Observable<Array<VNode>>;

    override function __setup(parent:Wire<Dynamic>, context:Context) {
      super.__setup(parent, context);

      __onDisposal.addOnce(_ -> {
        if (__link != null) __link.cancel();
        __link == null;
        __observableRender = null;
      });

      // Todo: benchmark this mess and make sure it's not forcing more renders
      //       than we actually need.
      __observableRender = Observable.auto(() -> switch render() {
        case null | VFragment([]): [ VNode.VNative(TextType, '', []) ];
        case VFragment(children): children;
        case vn: [ vn ];
      });

      var first = false;
      __link = __observableRender.bind(_ -> {
        // trace('Updated ${Type.getClassName(Type.getClass(this))}');
        if (first) {
          first = false;
          return null;
        }
        __requestUpdate({});
        return null;
      });
    }

    override function __getRendered():Array<VNode> {
      if (__observableRender == null) return [ VNode.VNative(TextType, '', []) ];
      return __observableRender.value;
    }

  #end

}

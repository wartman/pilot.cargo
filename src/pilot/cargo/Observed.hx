package pilot.cargo;

#if !pilot_cargo_constant
  import tink.state.Observable;

  using tink.CoreApi;
#end

final class Observed extends Component {
  
  @:attribute var wrap:()->VNode;

  #if !pilot_cargo_constant

  var observableRender:Observable<VNode>;
  var link:CallbackLink;

  override function render() {
    if (observableRender == null) {
      observableRender = Observable.auto(wrap);
      link = observableRender.bind(_ -> __requestUpdate());
    }
    return observableRender.value;
  }

  @:dispose
  function removeLink() {
    if (link != null) link.cancel();
  }

  #else

  override function render() {
    return wrap();
  }

  #end

}

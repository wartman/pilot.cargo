package pilot.cargo;

import tink.state.Observable;

using tink.CoreApi;

final class Observed extends Component {
  
  @:attribute var wrap:()->VNode;
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

}

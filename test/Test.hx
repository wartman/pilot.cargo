import js.Browser;
import pilot.Component;
import pilot.platform.dom.Dom;
import pilot.Cargo;
import pilot.cargo.Model;

class Test {

  public static function main() {
    var model = new TestModel({ title: 'ok' });
    trace(model.toJson());
    Dom.mount(
      Browser.document.getElementById('root'),
      Pilot.html(<div>
        <TestComponent model={model} />
      </div>)
    );
  }

}

class TestModel implements Model {

  @:prop(mutable) var title:String;
  @:prop @:optional var foo:Array<String>;

  @:computed var fullTitle:String = 'foo ' + title;

  @:transition
  public function setTitle(title:String) {
    trace('transition');
    return { title: title };
  }

}

class TestComponent extends Component {

  @:attribute var model:TestModel;
  
  override function render() return Cargo.observeHtml(<>
    <input type="text" value={model.title} onChange={e -> {
      var value = e.target.value;
      model.title = value;
    }} />
    <div onClick={_ -> model.title = 'bar'}>
      {model.fullTitle}
    </div>
  </>);

}

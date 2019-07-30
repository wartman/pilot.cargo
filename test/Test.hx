import pilot.*;
import pilot.cargo.*;

using pilot.Differ;

class Test {

  public static function main() {
    var model = new TestModel({ title: 'ok' });
    var widget = new TestWidget({ model: model });
    var node = js.Browser.document.getElementById('root');
    node.patch(widget);
  }

}

class TestModel implements Model {

  @:prop(mutable = true) var title:String;
  @:prop @:optional var foo:Array<String>;

  @:computed var fullTitle:String = 'foo ' + title;

  @:transition
  public function setTitle(title:String) {
    return { title: title };
  }

}

class TestWidget extends ReactiveWidget {

  @:prop var model:TestModel;

  override function build():VNode {
    return new VNode({
      name: 'div',
      props: {
        onClick: _ -> model.title = 'bar'
      },
      children: [
        model.fullTitle
      ]
    });
  }

}

import task.data.*;
import task.ui.core.App;

using pilot.Differ;
using haxe.Json;

class TaskApp {

  public static function main() {
    var store = new Store({
      title: 'Tasks',
      tasks: [ new Task({ title: 'foo', content: 'Must foo' }) ]
    });

    // This is here just for testing until I get off my butt and
    // make real tests
    trace(store.toJson().stringify(null, '  '));
    trace(Store.fromJson(store.toJson()));

    var app = new App({ store: store });
    js.Browser.document.getElementById('root').patch(app);
  }

}

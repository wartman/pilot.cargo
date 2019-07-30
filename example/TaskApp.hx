import task.data.*;
import task.ui.core.App;

using pilot.Differ;

class TaskApp {

  public static function main() {
    var store = new Store({
      title: 'Tasks',
      tasks: [ new Task({ title: 'foo', content: 'Must foo' }) ]
    });
    var app = new App({ store: store });
    js.Browser.document.getElementById('root').patch(app);
  }

}

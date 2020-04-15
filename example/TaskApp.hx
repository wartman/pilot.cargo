import js.Browser;
import task.data.*;
import task.ui.core.App;
import pilot.wings.PortalProvider;
import pilot.platform.dom.Dom;

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

    Dom.mount(
      Browser.document.getElementById('root'),
      Pilot.html(
        // Note: providers don't seem to work well
        //       inside ReactiveComponents. Should work on that.
        <PortalProvider>
          <App store={store} />  
        </PortalProvider>
      )
    );
  }

}

package task.ui.core;

import pilot.cargo.ReactiveComponent;
import task.ui.task.*;
import task.data.*;

class App extends ReactiveComponent {

  @:attribute var store:Store;
  
  @:init function testInit() {
    trace('Init was called on ReactiveComponent');
  }

  @:effect function testEffect() {
    trace('Effect was called on ReactiveComponent');
  }

  override function render() return html(<>
    @if (store.addingTask) {
      <TaskEditor
        requestClose={() -> store.addingTask = false}
        save={data -> {
          store.addingTask = false;
          store.addTask(new Task({
            title: data.title,
            content: data.content
          }));
        }}
      />;
    }
    <h1>{store.title}</h1>
    <span>{Std.string(store.remainingTasks)} of {Std.string(store.totalTasks)} remaining</span>
    <button
      onClick={() -> store.addingTask = true}
    >Add task</button>
    <ul>
      @for (task in store.activeTasks) {
        <TaskItem task={task} store={store} />;
      }
    </ul>
  </>);

}

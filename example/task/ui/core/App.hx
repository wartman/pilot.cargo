package task.ui.core;

import pilot.Component;
import pilot.Cargo;
import task.ui.task.*;
import task.data.*;

class App extends Component {

  @:attribute var store:Store;

  override function render() return Cargo.observeHtml(<>
    @if (store.addingTask) <TaskEditor
      requestClose={() -> store.addingTask = false}
      save={data -> {
        store.addingTask = false;
        store.addTask(new Task({
          title: data.title,
          content: data.content
        }));
      }}
    />
    <h1>{store.title}</h1>
    <span>{Std.string(store.remainingTasks)} of {Std.string(store.totalTasks)} remaining</span>
    <button
      onClick={() -> store.addingTask = true}
    >Add task</button>
    <ul>
      @for (task in store.activeTasks) <TaskItem task={task} store={store} />
    </ul>
  </>);

}

package task.ui.task;

import pilot.Component;
import pilot.cargo.Observed;
import task.data.*;

class TaskItem extends Component {
  
  @:attribute var task:Task;
  @:attribute var store:Store;

  override function render() return Observed.node({
    wrap: () -> html(<li>
      <h3>{task.title}</h3>
      <p>{task.content}</p>
      <button onClick={ _ -> task.completed = !task.completed }>
        { if (task.completed) 'Mark Pending' else 'Mark Completed' }
      </button>
      <button onClick={ _ -> task.editing = true }>
        Edit
      </button>
      <button onClick={ _ -> store.removeTask(task) }>
        Remove
      </button>
      @if (task.editing) <TaskEditor
        content={task.content}
        title={task.title}
        requestClose={ () -> task.editing = false }
        save={ data -> task.update(data.title, data.content) }
      />
    </li>)
  });
  
}

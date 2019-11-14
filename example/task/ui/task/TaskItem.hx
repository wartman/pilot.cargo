package task.ui.task;

// import pilot.Component;
import pilot.cargo.ReactiveComponent;
import task.data.*;

class TaskItem extends ReactiveComponent {
  
  @:attribute var task:Task;
  @:attribute var store:Store;

  override function render() return html(
    <li>
      <h3>{task.title}</h3>
      <p>{task.content}</p>
      <button onClick={_ -> task.completed = !task.completed}>
        <if {task.completed}>Mark Pending<else>Mark Completed</if>
      </button>
      <button onClick={_ -> {
        task.editing = true;
      }}>
        Edit
      </button>
      <button onClick={_ -> store.removeTask(task)}>
        Remove
      </button>
      <if {task.editing}>
        <TaskEditor
          content={task.content}
          title={task.title}
          requestClose={() -> task.editing = false}
          save={data -> {
            task.editing = false;
            task.update(data.title, data.content);
          }}
        />
      </if>
    </li>
  );
  
}

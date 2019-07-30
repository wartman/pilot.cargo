package task.data;

import pilot.cargo.Model;

class Store implements Model {
  
  @:prop var title:String;
  @:prop(mutable = true) @:optional var subTitle:String;
  @:prop var tasks:Array<Task>;
  @:prop(mutable = true) var addingTask:Bool = false;
  @:prop(mutable = true) var status:TaskStatus = TaskStatus.All;
  @:computed var siteTitle:String = if (subTitle == null) title else '${title} | ${subTitle}';
  @:computed var activeTasks:Array<Task> = switch status {
    case All: tasks;
    case Completed: tasks.filter(t -> t.completed);
    case Pending: tasks.filter(t -> !t.completed);
  };
  @:computed var remainingTasks:Int = tasks.filter(t -> !t.completed).length;
  @:computed var totalTasks:Int = tasks.length;

  @:transition
  public function addTask(task:Task) {
    return { tasks: tasks.copy().concat([ task ]) };
  }

  @:transition 
  public function removeTask(task:Task) {
    return { tasks: tasks.filter(t -> t != task) }; 
  }

}

package task.ui.core;

import pilot.VNode;
import pilot.wings.*;
import pilot.wings.PortalTarget;
import pilot.cargo.ReactiveWidget;
import task.data.*;
import task.ui.task.*;

class App extends ReactiveWidget {

  @:prop var store:Store;

  override function build():VNode {
    return new Box({
      children: [
        new PortalTarget({ id: new PortalTargetId('default') }),
        if (store.addingTask) new TaskEditor({
          requestClose: () -> store.addingTask = false,
          save: (props) -> {
            store.addingTask = false;
            store.addTask(new Task({
              title: props.title,
              content: props.content
            }));
          } 
        }) else null,
        VNode.h('h1', {}, [ store.title ]),
        VNode.h('span', {}, [ '${store.remainingTasks} of ${store.totalTasks} remaining' ]),
        new Button({
          onClick: _ -> store.addingTask = true,
          children: [ 'Add task' ]
        }),
        VNode.h('ul', {}, [ for (task in store.activeTasks) new TaskItem({ task: task, store: store }) ])
      ]
    });
  }

}

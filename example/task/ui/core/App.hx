package task.ui.core;

import pilot.wings.PortalTarget;
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
    <PortalTarget id={Config.modalTarget} />
    <if {store.addingTask}>
      <TaskEditor
        requestClose={() -> store.addingTask = false}
        save={data -> {
          store.addingTask = false;
          store.addTask(new Task({
            title: data.title,
            content: data.content
          }));
        }}
      />
    </if>
    <h1>{store.title}</h1>
    <span>{Std.string(store.remainingTasks)} of {Std.string(store.totalTasks)} remaining</span>
    <button
      onClick={() -> store.addingTask = true}
    >Add task</button>
    <ul>
      <for {task in store.activeTasks}>
        <TaskItem task={task} store={store} />
      </for>
    </ul>
  </>);

}

// import pilot.VNode;
// import pilot.wings.*;
// import pilot.wings.PortalTarget;
// import pilot.cargo.ReactiveWidget;
// import task.data.*;
// import task.ui.task.*;

// class App extends ReactiveWidget {

//   @:prop var store:Store;

//   override function build():VNode {
//     return new Box({
//       children: [
//         new PortalTarget({ id: new PortalTargetId('default') }),
//         if (store.addingTask) new TaskEditor({
//           requestClose: () -> store.addingTask = false,
//           save: (props) -> {
//             store.addingTask = false;
//             store.addTask(new Task({
//               title: props.title,
//               content: props.content
//             }));
//           } 
//         }) else null,
//         VNode.h('h1', {}, [ store.title ]),
//         VNode.h('span', {}, [ '${store.remainingTasks} of ${store.totalTasks} remaining' ]),
//         new Button({
//           onClick: _ -> store.addingTask = true,
//           children: [ 'Add task' ]
//         }),
//         VNode.h('ul', {}, [ for (task in store.activeTasks) new TaskItem({ task: task, store: store }) ])
//       ]
//     });
//   }

// }

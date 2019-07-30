package task.ui.task;

import pilot.VNode;
import pilot.wings.*;
import task.data.*;

abstract TaskItem(VNode) to VNode {
  
  public inline function new(props:{
    task:Task,
    store:Store
  }) {
    this = new VNode({
      name: 'li',
      props: {},
      children: [
        VNode.h('h3', {}, [ props.task.title ]),
        VNode.h('p', {}, [ props.task.content ]),
        new Button({
          onClick: _ -> props.task.completed = !props.task.completed,
          children: [
            if (props.task.completed)
              'Mark Pending'
            else
              'Mark Completed'
          ]
        }),
        new Button({
          onClick: _ -> props.task.editing = true,
          children: [ 'Edit' ]
        }),
        new Button({
          onClick: _ -> props.store.removeTask(props.task),
          children: [ 'Remove' ]
        }),
        if (props.task.editing) new TaskEditor({
          content: props.task.content,
          title: props.task.title,
          requestClose: () -> props.task.editing = false,
          save: value -> {
            props.task.editing = false;
            props.task.update(props.task.title, value);
          }
        }) else null
      ]
    });
  }

}

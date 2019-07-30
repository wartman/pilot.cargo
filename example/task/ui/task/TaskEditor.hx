package task.ui.task;

import pilot.Style;
import pilot.VNode;
import pilot.wings.*;

abstract TaskEditor(VNode) to VNode {
  
  public inline function new(props:{
    ?title:String,
    ?content:String,
    requestClose:()->Void,
    save:(content:String)->Void,
  }) {
    this = new Modal({
      overlayStyle: Style.create({
        background: 'rgba(0, 0, 0, 0.4)',
      }),
      target: 'default',
      title: props.title == null ? 'New Task' : 'Edit ${props.title}',
      requestClose: props.requestClose,
      child: new Box({
        children: [
          VNode.h('input', { 
            type: 'text',
            value: props.content != null ? props.content : '',
            onKeydown: e -> {
              var input:js.html.InputElement = cast e.target;
              var keyboardEvent:js.html.KeyboardEvent = cast e;
              if (keyboardEvent.key == 'Enter') {
                props.save(input.value);
              }
            }
          }),
          // todo: buttons etc. This may need to be a StatelessWidget?
        ]
      })
    });
  }

}
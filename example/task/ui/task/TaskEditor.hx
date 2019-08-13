package task.ui.task;

import pilot.Style;
import pilot.VNode;
import pilot.wings.*;
import pilot.wings.PortalTarget;

abstract TaskEditor(VNode) to VNode {
  
  public function new(props:{
    ?title:String,
    ?content:String,
    requestClose:()->Void,
    save:({title:String, content:String})->Void,
  }) {
    var data = {
      title: props.title,
      content: props.content
    };

    this = new Modal({
      overlayStyle: Style.create({
        background: 'rgba(0, 0, 0, 0.4)',
      }),
      modalStyle: Style.create({
        background: '#ffffff',
        width: '70%',
      }),
      target: new PortalTargetId('default'),
      requestClose: props.requestClose,
      header: new ModalHeader({
        title: props.title == null ? 'New Task' : 'Edit ${props.title}',
        requestClose: props.requestClose,
      }),
      child: new Box({
        children: [
          new Input({
            type: Text,
            name: 'title',
            value: props.title,
            placeholder: 'Title',
            onChange: value -> data.title = value,
            onCommit: value -> {
              data.title = value;
              props.save(data);
            }
          }),
          new Input({
            type: Text,
            name: 'content',
            value: props.content != null ? props.content : '',
            placeholder: 'Content',
            onChange: value -> data.content = value,
            onCommit: value -> {
              data.content = value;
              props.save(data);
            }
          }),
          new Box({
            children: [
              new Button({
                onClick: _ -> {
                  props.requestClose();
                },
                children: [ 'Cancel' ]
              }),
              new Button({
                onClick: _ -> {
                  props.save(data);
                  props.requestClose();
                },
                children: [ 'Save' ]
              }),
            ]
          })
        ]
      })
    });
  }

}
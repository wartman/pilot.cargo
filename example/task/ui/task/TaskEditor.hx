package task.ui.task;

import pilot.Component;
import pilot.wings.*;

class TaskEditor extends Component {
  
  @:attribute var title:String = '';
  @:attribute var content:String = '';
  @:attribute var save:({title:String, content:String})->Void;
  @:attribute var requestClose:()->Void;
  var data:{title:String, content:String};

  @:init function setup() {
    data = {
      title: title,
      content: content
    };
  }

  override function render() return html(
    <Modal
      requestClose={requestClose}
      overlayStyle@style={
        background: rgba(0, 0, 0, 0.4);
      }
      modalStyle@style={
        background: #ffffff;
        width: 70%;
      }
    >
      <div>
        <input type="text" id="title" value={data.title} onChange={e -> {
          var value = (e.target:js.html.InputElement).value;
          data.title = value;
        }} />
        <textarea id="content" onChange={e -> {
          var value = (e.target:js.html.TextAreaElement).value;
          data.content = value;
        }}>{data.content}</textarea>
        <button onClick={_ -> {
          save(data);
          requestClose();
        }}>Save</button>
        <button onClick={_ -> requestClose()}>Cancel</button>
      </div>
    </Modal>
  );

}

// import pilot.Style;
// import pilot.VNode;
// import pilot.wings.*;
// import pilot.wings.PortalTarget;

// abstract TaskEditor(VNode) to VNode {
  
//   public function new(props:{
//     ?title:String,
//     ?content:String,
//     requestClose:()->Void,
//     save:({title:String, content:String})->Void,
//   }) {
//     var data = {
//       title: props.title,
//       content: props.content
//     };

//     this = new Modal({
//       overlayStyle: Style.create({
//         background: 'rgba(0, 0, 0, 0.4)',
//       }),
//       modalStyle: Style.create({
//         background: '#ffffff',
//         width: '70%',
//       }),
//       target: new PortalTargetId('default'),
//       requestClose: props.requestClose,
//       header: new ModalHeader({
//         title: props.title == null ? 'New Task' : 'Edit ${props.title}',
//         requestClose: props.requestClose,
//       }),
//       child: new Box({
//         children: [
//           new Input({
//             type: Text,
//             name: 'title',
//             value: props.title,
//             placeholder: 'Title',
//             onChange: value -> data.title = value,
//             onCommit: value -> {
//               data.title = value;
//               props.save(data);
//             }
//           }),
//           new Input({
//             type: Text,
//             name: 'content',
//             value: props.content != null ? props.content : '',
//             placeholder: 'Content',
//             onChange: value -> data.content = value,
//             onCommit: value -> {
//               data.content = value;
//               props.save(data);
//             }
//           }),
//           new Box({
//             children: [
//               new Button({
//                 onClick: _ -> {
//                   props.requestClose();
//                 },
//                 children: [ 'Cancel' ]
//               }),
//               new Button({
//                 onClick: _ -> {
//                   props.save(data);
//                   props.requestClose();
//                 },
//                 children: [ 'Save' ]
//               }),
//             ]
//           })
//         ]
//       })
//     });
//   }

// }
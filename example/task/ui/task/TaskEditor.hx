package task.ui.task;

import pilot.Component;
import pilot.wings.*;

class TaskEditor extends Component {
  
  @:attribute var title:String = '';
  @:attribute var content:String = '';
  @:attribute var save:({title:String, content:String})->Void;
  @:attribute var requestClose:()->Void;
  var data:{title:String, content:String};

  @:init 
  function setup() {
    data = {
      title: title,
      content: content
    };
  }

  override function render() return html(
    <Modal
      requestClose={requestClose}
      overlayStyle={css('
        background: rgba(0, 0, 0, 0.4);
      ')}
      modalStyle={css('
        background: #ffffff;
        width: 70%;
      ')}
    >
      <div>
        <input type="text" id="title" value={data.title} onChange={e -> {
          #if (js && !nodejs)
            var value = (e.target:js.html.InputElement).value;
            data.title = value;
          #end
        }} />
        <textarea id="content" onChange={e -> {
          #if (js && !nodejs)
            var value = (e.target:js.html.TextAreaElement).value;
            data.content = value;
          #end
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

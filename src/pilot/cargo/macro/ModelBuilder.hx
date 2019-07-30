#if macro
package pilot.cargo.macro;

import haxe.macro.Expr;
import haxe.macro.Context;

using Lambda;

class ModelBuilder {

  static final propsMeta = [ ':prop', ':property' ];
  static final transitionMeta = [ ':transition' ];
  static final computedMeta = [ ':computed' ];
  static final optional = { name: ':optional', pos: (macro null).pos };

  // This is a rather naive and questionable implementation.
  // Check the `coconut.data` project and use that as the basis for this
  // implementation going forward.
  public static function build() {
    var fields = Context.getBuildFields();
    var props:Array<Field> = [];
    var conFields:Array<Field> = [];
    var patchFields:Array<Field> = [];
    var newFields:Array<Field> = [];
    var initializers:Array<Expr> = [];
    var lateInitializers:Array<Expr> = [];

    function mk(name:String, t:ComplexType, isOptional:Bool):Field return {
      name: name,
      kind: FVar(t, null),
      access: [ APublic ],
      meta: isOptional ? [ optional ] : [],
      pos: (macro null).pos
    };

    for (f in fields) switch (f.kind) {
      case FVar(t, e) if (f.meta.exists(m -> propsMeta.has(m.name))):
        if (t == null) {
          Context.error('An explicit type is required', f.pos);
        } else {
          var mutable = false;
          var meta = f.meta.find(m -> propsMeta.has(m.name));
          for (p in meta.params) switch p {
            case macro $option = $value: switch option.expr {
              case EConst(CIdent(s)): switch s {
                case 'mutable': switch value {
                  case macro false: mutable = false;
                  case macro true: mutable = true;
                  default: Context.error('`mutable` must be Bool', value.pos);
                }
                default:
                  Context.error('Currently only `mutable` is allowed here', option.pos);
              }
              default:
                Context.error('Only a = b expressions allowed here', p.pos);
            }
            default:
              Context.error('Only a = b expressions allowed here', meta.pos);
          }

          f.kind = FProp('get', mutable ? 'set' : 'never', t, null);
          f.access = [ APublic ];
          var name = f.name;
          var isOptional = f.meta.exists(m -> m.name == ':optional');
          var getName = 'get_${name}';

          if (e != null) {
            initializers.push(macro _pilot_props.$name = props.$name == null ? new tink.state.State($e) : new tink.state.State(props.$name));
          } else if (isOptional) {
            initializers.push(macro _pilot_props.$name = props.$name == null ? new tink.state.State(null) : new tink.state.State(props.$name));
          } else {
            initializers.push(macro _pilot_props.$name = new tink.state.State(props.$name));
          }

          props.push(mk(name, macro:tink.state.State<$t>, isOptional));
          conFields.push(mk(name, t, isOptional || e != null));
          patchFields.push(mk(name, t, true));

          newFields = newFields.concat((macro class {
            @:noCompletion function $getName():$t return _pilot_props.$name.value;
          }).fields);

          if (mutable) {
            var setName = 'set_${name}';
            newFields = newFields.concat((macro class {
              @:noCompletion function $setName(value:$t):$t {
                _pilot_props.$name.set(value);
                return value; 
              }
            }).fields);
          }
        }
      
      case FVar(t, e) if (f.meta.exists(m -> computedMeta.has(m.name))):
        if (t == null) {
          Context.error('An explicit type is required', f.pos);
        } else if (e == null) {
          Context.error('An expression is required here', f.pos);
        } else {
          f.kind = FProp('get', 'never', t, null);
          f.access = [ APublic ];

          var name = f.name;
          var meta = f.meta.find(m -> computedMeta.has(m.name));
          var getName = 'get_${name}';
          var initializer = macro @:pos(e.pos) function ():$t return ${e};
          
          props.push(mk(name, macro:tink.state.Observable<$t>, true));
          initializers.push(macro _pilot_props.$name = tink.state.Observable.auto(${initializer}));

          newFields = newFields.concat((macro class {
            @:noCompletion function $getName():$t return _pilot_props.$name.value;
          }).fields);
        }
        
      case FFun(func):
        
        if (f.meta.exists(m -> m.name == ':init')) {
          var name = f.name;
          initializers.push(macro this.$name());
        }

      default:
    }

    var patch = TAnonymous(patchFields);

    for (f in fields) switch (f.kind) {
      case FFun(func):
        if (f.meta.exists(m -> transitionMeta.has(m.name))) {
          var name = f.name;
          if (func.ret != null) {
            Context.error('Do not manually set a return type for transitions', f.pos);
          }
          func.ret = macro:Void;
          var e = func.expr;
          func.expr = macro {
            var closure:()->$patch = () -> ${e};
            _pilot_update(closure());
          };
          f.kind = FFun(func);
        }
      default:
    }

    var propsVar = TAnonymous(props);
    var conArg = TAnonymous(conFields);
    var sparse = TAnonymous([ for (f in patchFields) {
      meta: [ optional ],
      name: f.name,
      pos: f.pos,
      kind: FVar(
        switch f.kind { 
          case FProp(_, _, t, _): macro : pilot.cargo.Ref<$t>;
          case FVar(t): macro : pilot.cargo.Ref<$t>; 
          default: throw 'assert'; 
        }
      )
    } ]);
    
    var updates:Array<Expr> = [];
    for (f in patchFields) {
      var name = f.name;
      updates.push(macro if (delta.$name != null) _pilot_props.$name.set(delta.$name));
    }

    newFields = newFields.concat((macro class {

      var _pilot_props:$propsVar;

      public function new(props:$conArg) {
        _pilot_props = cast {};
        $b{initializers};
        $b{lateInitializers};
      }

      @:noCompletion function _pilot_update(delta:$patch) {
        var sparse = new haxe.DynamicAccess<pilot.cargo.Ref<Any>>();
        var delta:haxe.DynamicAccess<Any> = cast delta;
        
        for (k in delta.keys()) {
          sparse[k] = pilot.cargo.Ref.to(delta[k]);
        }

        var delta:$sparse = cast sparse;
        $b{updates};
      }

      // public function toObject():$patch {
      //   var props:$patch = cast {};
      //   $b{[ for (prop in patchFields) {
      //     var name = prop.name;
      //     macro props.$name = _pilot_props.$name.value;
      //   } ]}
      //   return props;
      // }

    }).fields);

    return fields.concat(newFields);
  }

}
#end

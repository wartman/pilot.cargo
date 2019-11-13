package pilot.cargo;

#if !macro

@:autoBuild(pilot.cargo.Model.build())
interface Model {}

#else

import haxe.macro.Expr;
import haxe.macro.Context;

using Lambda;
using haxe.macro.Tools;

class Model {

  static final propsMeta = [ ':prop', ':property' ];
  static final transitionMeta = [ ':transition' ];
  static final computedMeta = [ ':computed' ];
  static final optional = { name: ':optional', pos: (macro null).pos };

  // This is a rather naive and questionable implementation.
  // Check the `coconut.data` project and use that as the basis for this
  // implementation going forward.
  public static function build() {
    var cls = Context.getLocalClass().get();
    var typePath:TypePath = { pack: cls.pack, name: cls.name };
    var isConstantTarget = Context.defined('pilot-cargo-constant');
    var fields = Context.getBuildFields();
    var props:Array<Field> = [];
    var conFields:Array<Field> = [];
    var patchFields:Array<Field> = [];
    var jsonFields:Array<ObjectField> = [];
    var fromJsonFields:Array<ObjectField> = [];
    var newFields:Array<Field> = [];
    var initializers:Array<ObjectField> = [];
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
          var isConstant = false;
          var meta = f.meta.find(m -> propsMeta.has(m.name));
          for (p in meta.params) switch p {
            case macro $option = $value: switch option.expr {
              case EConst(CIdent(s)): switch s {
                case 'mutable': switch value {
                  case macro false: mutable = false;
                  case macro true: mutable = true;
                  default: Context.error('`mutable` must be Bool', value.pos);
                }
                case 'constant': switch value {
                  case macro false: isConstant = false;
                  case macro true: isConstant = true;
                  default: Context.error('`constant` must be Bool', value.pos);
                }
                default:
                  Context.error('Currently only `mutable` or `constant` is allowed here', option.pos);
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

          if (isConstant || isConstantTarget) {
            if (e != null) {
              initializers.push({
                field: name,
                expr: macro @:pos(f.pos) props.$name == null ? $e : props.$name,
              });
            } else {
              initializers.push({
                field: name,
                expr: macro props.$name
              });
            }
          } else {
            if (e != null) {
              initializers.push({
                field: name,
                expr: macro props.$name == null ? new tink.state.State($e) : new tink.state.State(props.$name)
              });
            } else if (isOptional) {
              initializers.push({
                field: name,
                expr: macro props.$name == null ? new tink.state.State(null) : new tink.state.State(props.$name)
              });
            } else {
              initializers.push({
                field: name,
                expr: macro new tink.state.State(props.$name)
              });
            }
          }

          if (isConstant || isConstantTarget) {
            props.push(mk(name, t, isOptional));
            newFields = newFields.concat((macro class {
              @:noCompletion function $getName():$t return _pilot_props.$name;
            }).fields);
          } else {
            props.push(mk(name, macro:tink.state.State<$t>, isOptional));
            newFields = newFields.concat((macro class {
              @:noCompletion function $getName():$t return _pilot_props.$name.value;
            }).fields);
          }
          conFields.push(mk(name, t, isOptional || e != null));
          if (!isConstant) patchFields.push(mk(name, t, true));

          if (mutable) {
            if (isConstant) {
              Context.error('Constant props cannot be mutable', f.pos);
            } else {
              var setName = 'set_${name}';
              if (isConstantTarget) {
                newFields = newFields.concat((macro class {
                  @:noCompletion function $setName(value:$t):$t {
                    _pilot_props.$name = value;
                    return value; 
                  }
                }).fields);
              } else {
                newFields = newFields.concat((macro class {
                  @:noCompletion function $setName(value:$t):$t {
                    _pilot_props.$name.set(value);
                    return value; 
                  }
                }).fields);
              }
            }
          }

          switch t {
            case macro:Array<$t> if (t.toType().unify(Context.getType('pilot.cargo.Model'))):
              var cls = t.toType().getClass();
              var path = cls.pack.concat([ cls.name ]);
              jsonFields.push({
                field: name,
                expr: macro this.$name != null 
                  ? this.$name.map(i -> i.toJson())
                  : null
              });
              fromJsonFields.push({
                field: name,
                expr: macro props.$name != null
                  ? (props.$name:Array<Dynamic>).map(props -> $p{path}.fromJson(props))
                  : null
              });
            case t if (t.toType().unify(Context.getType('pilot.cargo.Model'))):
              var cls = t.toType().getClass();
              var path = cls.pack.concat([ cls.name ]);
              jsonFields.push({
                field: name,
                expr: macro this.$name != null 
                  ? this.$name.toJson()
                  : null
              });
              fromJsonFields.push({
                field: name,
                expr: macro props.$name != null
                  ? $p{path}.fromJson(props.$name)
                  : null
              });
            default:
              jsonFields.push({
                field: name,
                expr: macro this.$name
              });
              fromJsonFields.push({
                field: name,
                expr: macro props.$name
              });
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
          
          if (isConstantTarget) {
            props.push(mk(name, t, true));
            lateInitializers.push(macro _pilot_props.$name = ${initializer}());
            newFields = newFields.concat((macro class {
              @:noCompletion function $getName():$t return _pilot_props.$name;
            }).fields);
          } else {
            props.push(mk(name, macro:tink.state.Observable<$t>, true));
            initializers.push({
              field: name,
              expr: macro tink.state.Observable.auto(${initializer})
            });
            newFields = newFields.concat((macro class {
              @:noCompletion function $getName():$t return _pilot_props.$name.value;
            }).fields);
          }
        }
        
      case FFun(func):
        
        if (f.meta.exists(m -> m.name == ':init')) {
          var name = f.name;
          lateInitializers.push(macro this.$name());
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
      if (isConstantTarget) {
        updates.push(macro if (delta.$name != null) _pilot_props.$name = delta.$name);
      } else {
        updates.push(macro if (delta.$name != null) _pilot_props.$name.set(delta.$name));
      }
    }

    newFields = newFields.concat((macro class {

      var _pilot_props:$propsVar;

      public function new(props:$conArg) {
        _pilot_props = ${ {
          expr: EObjectDecl(initializers),
          pos: cls.pos
        } };
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

      public function toJson():{} {
        return ${ {
          expr: EObjectDecl(jsonFields),
          pos: cls.pos
        } };
      }

      public static function fromJson(props:Dynamic) {
        return new $typePath(${ {
          expr: EObjectDecl(fromJsonFields),
          pos: cls.pos
        } });
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

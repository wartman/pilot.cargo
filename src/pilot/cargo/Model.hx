package pilot.cargo;

#if !macro

@:autoBuild(pilot.cargo.Model.build())
interface Model {}

#else

import haxe.macro.Expr;
import haxe.macro.Context;
import pilot.builder.ClassBuilder;

using Lambda;
using haxe.macro.Tools;

class Model {

  static final PROPS_NAME = '__props';
  static final INCOMING_PROPS_NAME = '__props';
  static final OPTIONAL_META = { name: ':optional', pos: (macro null).pos };

  static function mk(name:String, t:ComplexType, isOptional:Bool):Field return {
    name: name,
    kind: FVar(t, null),
    access: [ APublic ],
    meta: isOptional ? [ OPTIONAL_META ] : [],
    pos: (macro null).pos
  };

  public static function build() {
    var cls = Context.getLocalClass().get();
    var fields = Context.getBuildFields();
    var typePath:TypePath = { pack: cls.pack, name: cls.name };
    var builder = new ClassBuilder(fields, cls);
    var isConstantTarget = Context.defined('pilot-cargo-constant');
    var props:Array<Field> = [];
    var conFields:Array<Field> = [];
    var patchFields:Array<Field> = [];
    var jsonFields:Array<ObjectField> = [];
    var fromJsonFields:Array<ObjectField> = [];
    var initializers:Array<ObjectField> = [];
    var lateInitializers:Array<Expr> = [];
    var updates:Array<Expr> = [];
    var incoming = macro $i{INCOMING_PROPS_NAME};

    builder.addFieldBuilder({
      name: ':prop',
      hook: Normal,
      similarNames: [
        ':property', 'prop'
      ],
      options: [
        { name: 'mutable', optional: true },
        { name: 'constant', optional: true },
        { name: 'optional', optional: true }
      ],
      multiple: false,
      build: function (options:{
        mutable:Bool,
        optional:Bool,
        constant:Bool
      }, cls, field) switch field.kind {
        case FVar(t, e):
          var name = field.name;
          var getName = 'get_${name}';
          var setName = 'set_${name}';
          var isConstant = options.constant != null ? options.constant : false;
          var isOptional = options.optional != null 
            ? options.optional 
            : field.meta.exists(m -> m.name == ':optional')
              ? true
              : e != null;
          var isMutable = options.mutable != null ? options.mutable : false;
          
          if (isMutable && isConstant) {
            Context.error('Constant props cannot be mutable', field.pos);
          }

          field.kind = FProp('get', isMutable ? 'set' : 'never', t, null);
          field.access = [ APublic ];
          
          conFields.push(mk(name, t, isOptional || e != null));
          if (!isConstant) patchFields.push(mk(name, t, true));

          if (isConstant || isConstantTarget) {
            props.push(mk(name, t, isOptional));

            builder.add((macro class {
              function $getName():$t return this.$PROPS_NAME.$name;
            }).fields);

            if (isMutable) {
              // Note: this will only run for normal props in a
              //       constant target.
              builder.add((macro class {
                function $setName(value) {
                  this.$PROPS_NAME.$name = value;
                  return value;
                }
              }).fields);
            }

            if (e != null) {
              initializers.push({
                field: name,
                expr: macro @:pos(field.pos) $incoming.$name == null
                  ? ${e}
                  : $incoming.$name
              });
            } else {
              initializers.push({
                field: name,
                expr: macro @:pos(field.pos) $incoming.$name
              });
            }
          } else {
            props.push(mk(name, macro:tink.state.State<$t>, isOptional));
            
            builder.add((macro class {
              function $getName():$t return this.$PROPS_NAME.$name.value;
            }).fields);

            if (isMutable) {
              builder.add((macro class {
                function $setName(value) {
                  this.$PROPS_NAME.$name.set(value);
                  return value;
                }
              }).fields);
            }

            if (e != null) {
              initializers.push({
                field: name,
                expr: macro @:pos(field.pos) $incoming.$name == null
                  ? new tink.state.State($e)
                  : new tink.state.State($incoming.$name) 
              });
            } else if (isOptional) {
              initializers.push({
                field: name,
                expr: macro @:pos(field.pos) $incoming.$name == null
                  ? new tink.state.State(null)
                  : new tink.state.State($incoming.$name) 
              });
            } else {
              initializers.push({
                field: name,
                expr: macro @:pos(field.pos) new tink.state.State($incoming.$name) 
              });
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
                expr: macro $incoming.$name != null
                  ? ($incoming.$name:Array<Dynamic>).map($INCOMING_PROPS_NAME -> $p{path}.fromJson($incoming))
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
                expr: macro $incoming.$name != null
                  ? $p{path}.fromJson($incoming.$name)
                  : null
              });
            default:
              jsonFields.push({
                field: name,
                expr: macro this.$name
              });
              fromJsonFields.push({
                field: name,
                expr: macro $incoming.$name
              });
          }

        default:
          Context.error('@:prop can only be used on vars', field.pos);
      }
    });

    builder.addFieldBuilder({
      name: ':computed',
      hook: After,
      similarNames: [ ":compted" ],
      options: [],
      multiple: false,
      build: function (options:{}, cls, field) switch field.kind {
        case FVar(t, e):
          if (t == null) {
            Context.error('An explicit type is required', field.pos);
          } else if (e == null) {
            Context.error('An expression is required here', field.pos);
          }

          field.kind = FProp('get', 'never', t, null);
          field.access = [ APublic ];

          var name = field.name;
          var getName = 'get_${name}';
          var initializer = macro @:pos(e.pos) function ():$t return $e;

          if (isConstantTarget) {
            props.push(mk(name, t, true));
            var cacheName = '__cache_${name}';
            builder.add((macro class {
              @:noCompletion var $cacheName:$t = null;
              function $getName():$t {
                if (this.$cacheName == null) {
                  this.$cacheName = ${e};
                }
                return this.$cacheName;
              }
            }).fields);
            updates.push(macro this.$cacheName = null);
          } else {
            props.push(mk(name, macro:tink.state.Observable<$t>, true));
            initializers.push({
              field: name,
              expr: macro tink.state.Observable.auto(${initializer})
            });
            builder.add((macro class {
              function $getName():$t return this.$PROPS_NAME.$name.value;
            }).fields);
          }

        default:
          Context.error('@:computed can only be used on vars', field.pos);
      }
    });

    builder.addFieldBuilder({
      name: ':init',
      hook: After,
      similarNames: [
        'init', ':initializer'
      ],
      options: [],
      multiple: false,
      build: function (options:{}, cls, field) switch field.kind {
        case FFun(func):
          var name = field.name;
          lateInitializers.push(macro this.$name());
        default:
          Context.error('@:init can only be used on methods', field.pos);
      }
    });
    
    builder.addFieldBuilder({
      name: ':transition',
      hook: After,
      similarNames: [
        'transition', ':transtion'
      ],
      options: [],
      multiple: false,
      build: function (options:{}, cls, field) switch field.kind {
        case FFun(func):
          var patch = TAnonymous(patchFields);
          var name = field.name;

          if (func.ret != null) {
            Context.error('Do not manually set a return type for transitions', field.pos);
          }
          func.ret = macro:Void;
          var e = func.expr;
          func.expr = macro {
            var closure:()->$patch = () -> ${e};
            __update(closure());
          };

          field.kind = FFun(func);
        default:
          Context.error('@:transition can only be used on methods', field.pos);
      }
    });

    builder.run();

    var patch = TAnonymous(patchFields);
    var propsVar = TAnonymous(props);
    var conArg = TAnonymous(conFields);
    var sparse = TAnonymous([ for (f in patchFields) {
      meta: [ OPTIONAL_META ],
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

    for (f in patchFields) {
      var name = f.name;
      if (isConstantTarget) {
        updates.push(macro if (delta.$name != null) this.$PROPS_NAME.$name = delta.$name);
      } else {
        updates.push(macro if (delta.$name != null) this.$PROPS_NAME.$name.set(delta.$name));
      }
    }

    builder.add((macro class {

      var $PROPS_NAME:$propsVar;

      public function new($INCOMING_PROPS_NAME:$conArg) {
        this.$PROPS_NAME = ${ {
          expr: EObjectDecl(initializers),
          pos: cls.pos
        } };
        $b{lateInitializers};
      }

      function __update(delta:$patch) {
        var sparse = new haxe.DynamicAccess<pilot.cargo.Ref<Any>>();
        var delta:haxe.DynamicAccess<Any> = cast delta;
        
        for (k in delta.keys()) {
          sparse[k] = pilot.cargo.Ref.to(delta[k]);
        }

        var delta:$sparse = cast sparse;
        $b{updates};
      }

      public function toJson():Dynamic {
        return ${ {
          expr: EObjectDecl(jsonFields),
          pos: cls.pos
        } };
      }

      public static function fromJson($INCOMING_PROPS_NAME:Dynamic) {
        return new $typePath(${ {
          expr: EObjectDecl(fromJsonFields),
          pos: cls.pos
        } });
      }

    }).fields);

    return builder.export();
  }

}

#end

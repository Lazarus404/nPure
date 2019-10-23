;=================================================================================================================================
;       @Title : nPure
;      @Author : Jahred Love
; @Description : PureBasic Interface script For creating Neko ndll extension libraries using the PureBasic language 
;   @Copyright : Jahred Love 2008
;=================================================================================================================================

Enumeration
   #VAL_INT      = $FF
   #VAL_NULL      = 0
   #VAL_FLOAT      = 1
   #VAL_BOOL      = 2
   #VAL_STRING      = 3
   #VAL_OBJECT      = 4
   #VAL_ARRAY      = 5
   #VAL_FUNCTION   = 6
   #VAL_ABSTRACT   = 7
   #VAL_PRIMITIVE   = 6 | 8
   #VAL_JITFUN      = 6 | 16
   #VAL_32_BITS   = $FFFFFFFF
EndEnumeration

Structure _value
    t.l
EndStructure

Structure vstring
    t.l
    c.b
EndStructure

Structure vfloat
    t.l
    f.d
EndStructure

Structure varray
    t.l
    ptr.l
EndStructure

Structure pbarray
    l.l[0]
EndStructure

Structure vfunction
    t.l
	  nargs.l
	  *addr.l
	  env._value
	  *module.l
EndStructure

Structure vabstract
    t.l
	  *kind.vkind
	  *data.l
EndStructure

Structure vkind
    __zero.l
EndStructure

Structure vobject
	t.l
	*table.l
	*proto.vobject
EndStructure

Global val_null.l, val_false.l, val_true.l
Global *kind1.vkind, *kind2.vkind

; Change this to the name of the neko dynamic library on your system
; The ndll should search in the local directory, and if not available, then the OS system directory
Global nekolib.s = "neko.dll"

PrototypeC.l alloc_double_prototype(value.d)
PrototypeC.l alloc_int_prototype(value.l)
PrototypeC.l alloc_string_prototype(value.s)
PrototypeC.l alloc_value_prototype(*value._value)
PrototypeC.l alloc_func_prototype( ignore1.l, *f._value, *args._value, *nargs._value, ignore2.l )
PrototypeC.l alloc_make_func_prototype( *f.l, nargs.l, name.s )
PrototypeC.l alloc_abstract_prototype( *kind.vkind, *obj.l )
PrototypeC.l alloc_field_prototype( *obj.vobject, field.l )
PrototypeC.l alloc_add_field_prototype( *obj.vobject, field.l, *dat._value )

;------------------------------------------------------------------------------------------------------------------------------
; Helper functions
;------------------------------------------------------------------------------------------------------------------------------
Procedure.l val_array_ptr( *arr.varray )
    ProcedureReturn @*arr\ptr
EndProcedure

Procedure.l val_array_size( *arr.varray )
    ProcedureReturn *arr\t >> 3
EndProcedure

Procedure.l val_fun_nargs( *f.vfunction )
    ProcedureReturn *f\nargs
EndProcedure

;------------------------------------------------------------------------------------------------------------------------------
; Allocation functions
;------------------------------------------------------------------------------------------------------------------------------
Procedure.l alloc_string( string$ )
    Protected *int._value
    If OpenLibrary(1, nekolib)
        *int = CallCFunction(1, "neko_alloc_string", string$)
        CloseLibrary(1)
    EndIf
    ProcedureReturn *int
EndProcedure

Procedure.l alloc_int( integer.l )
    Protected *int._value
    *int = integer << 1 | 1
    ProcedureReturn *int
EndProcedure

Procedure.l alloc_float( flt.d )
    Protected *int._value
    If OpenLibrary(1, nekolib)
        func.alloc_double_prototype = GetFunction(1, "neko_alloc_float")
        If func <> 0
            *int = func(flt)
        EndIf
        CloseLibrary(1)
    EndIf
    ProcedureReturn *int
EndProcedure

Procedure.l alloc_array( size.l )
    Protected *array.varray
    If OpenLibrary(1, nekolib)
        func.alloc_int_prototype = GetFunction(1, "neko_alloc_array")
        If func <> 0
            *array = func(size)
        EndIf
        CloseLibrary(1)
    EndIf
    ProcedureReturn *array
EndProcedure

Procedure.l alloc_abstract( *kind.vkind, *obj.l )
    Protected *abstract.vabstract
    If OpenLibrary(1, nekolib)
        func.alloc_abstract_prototype = GetFunction(1, "neko_alloc_abstract")
        If func <> 0
            *abstract = func(*kind, *obj)
        EndIf
        CloseLibrary(1)
    EndIf
    ProcedureReturn *abstract
EndProcedure

Procedure.l alloc_function( *f.l, nargs.l, name.s )
    Protected *int._value
    If OpenLibrary(1, nekolib)
        func.alloc_make_func_prototype = GetFunction(1, "neko_alloc_function")
        If func <> 0
            *int = func( *f, nargs, name )
        EndIf
        CloseLibrary(1)
    EndIf
    ProcedureReturn *int
EndProcedure

Procedure.l alloc_field( *obj.vobject, field.l, *dat._value )
    If OpenLibrary(1, nekolib)
        func.alloc_add_field_prototype = GetFunction(1, "neko_alloc_field")
        If func <> 0
            func( *obj, field, *dat )
        EndIf
        CloseLibrary(1)
    EndIf
    ProcedureReturn 0
EndProcedure

;------------------------------------------------------------------------------------------------------------------------------
; Error handling
;------------------------------------------------------------------------------------------------------------------------------

Procedure.l throw_error( message.s )
    Protected *msg.vstring = alloc_string( message )
    If OpenLibrary(1, nekolib)
        func.alloc_value_prototype = GetFunction(1, "neko_val_throw")
        If func <> 0
            func( *msg )
        EndIf
        CloseLibrary(1)
    EndIf
    ProcedureReturn 1
EndProcedure

;------------------------------------------------------------------------------------------------------------------------------
; Data retrieval functions
;------------------------------------------------------------------------------------------------------------------------------
Procedure.s val_string( *int._value )
    Protected *vs.vstring
    *vs = *int
    ProcedureReturn PeekS(@*vs\c)
EndProcedure

Procedure.l val_int( *int._value )
    Protected *vi.l
    *vi = *int
    ProcedureReturn *vi>>1
EndProcedure

Procedure.d val_float( *int._value )
    Protected *vf.vfloat
    *vf = *int
    ProcedureReturn *vf\f
EndProcedure

Procedure.l val_array( *arr.varray )
    *pba.pbarray = val_array_ptr( *arr )
    ProcedureReturn *pba
EndProcedure

Procedure.l val_data( *abstract.vabstract )
    *obj.l = *abstract\data
    ProcedureReturn *obj
EndProcedure

Procedure.l val_kind( *abstract.vabstract )
    *kind.vkind = *abstract\kind
    ProcedureReturn *kind
EndProcedure

Procedure.l val_id( name.s )
    Protected id.l
    If OpenLibrary(1, nekolib)
        func.alloc_string_prototype = GetFunction(1, "neko_val_id")
        If func <> 0
            id = func(name)
        EndIf
        CloseLibrary(1)
    EndIf
    ProcedureReturn id
EndProcedure

Procedure.l val_field( *obj.vobject, field.l )
    Protected *dat.l
    If OpenLibrary(1, nekolib)
        func.alloc_field_prototype = GetFunction(1, "neko_val_field")
        If func <> 0
            *dat = func(*obj, field)
        EndIf
        CloseLibrary(1)
    EndIf
    ProcedureReturn *dat
EndProcedure

;------------------------------------------------------------------------------------------------------------------------------
; Type checking functions
;------------------------------------------------------------------------------------------------------------------------------
Procedure.l val_is_int( *int._value )
    If *int & 1 <> 0
        ProcedureReturn #True
    Else
        ProcedureReturn #False
    EndIf
EndProcedure

Procedure.l val_is_string( *int._value )
    Protected ret.l = #False
    If val_is_int( *int ) = #False
        If *int\t & 7 = #VAL_STRING
            ret = #True
        EndIf
    EndIf
    ProcedureReturn ret
EndProcedure

Procedure.l val_is_float( *flt._value )
    Protected ret.l = #False
    If val_is_int( *flt ) = #False
        If *flt\t = #VAL_FLOAT
            ret = #True
        EndIf
    EndIf
    ProcedureReturn ret
EndProcedure

Procedure.l val_is_object( *obj._value )
    Protected ret.l = #False
    If val_is_int( *obj ) = #False
        If *obj\t = #VAL_OBJECT
            ret = #True
        EndIf
    EndIf
    ProcedureReturn ret
EndProcedure

Procedure.l val_is_function( *fun._value )
    Protected ret.l = #False
    If val_is_int( *fun ) = #False
        If *fun\t & 7 = #VAL_FUNCTION
            ret = #True
        EndIf
    EndIf
    ProcedureReturn ret
EndProcedure

Procedure.l val_is_abstract( *abs._value )
    Protected ret.l = #False
    If val_is_int( *abs ) = #False
        If *abs\t = #VAL_ABSTRACT
            ret = #True
        EndIf
    EndIf
    ProcedureReturn ret
EndProcedure

Procedure.l val_is_array( *arr._value )
    Protected ret.l = #False
    If val_is_int( *arr ) = #False
        If *arr\t & 7 = #VAL_ARRAY
            ret = #True
        EndIf
    EndIf
    ProcedureReturn ret
EndProcedure

Procedure.l val_is_bool( *bln._value )
    Protected ret.l = #False
    If *bln = val_false Or *bln = val_true
        ret = #True
    EndIf
    ProcedureReturn ret
EndProcedure

Procedure.l val_is_null( *val._value )
    Protected ret.l = #False
    If *val = val_null
        ret = #True
    EndIf
    ProcedureReturn ret
EndProcedure

Procedure.l val_check( *val._value, type.l )
    If type = #VAL_STRING And Not val_is_string( *val )
        throw_error( "type is not a string" )
    ElseIf type = #VAL_FLOAT And Not val_is_float( *val )
        throw_error( "type is not a float" )
    ElseIf type = #VAL_INT And Not val_is_int( *val )
        throw_error( "type is not an int" )
    ElseIf type = #VAL_ARRAY And Not val_is_array( *val )
        throw_error( "type is not an array" )
    ElseIf type = #VAL_OBJECT And Not val_is_object( *val )
        throw_error( "type is not an object" )
    ElseIf type = #VAL_FUNCTION And Not val_is_function( *val )
        throw_error( "type is not a function" )
    ElseIf type = #VAL_ABSTRACT And Not val_is_abstract( *val )
        throw_error( "type is not an abstract" )
    ElseIf type = #VAL_NULL And Not val_is_null( *val )
        throw_error( "type is not null" )
    ElseIf type = #VAL_BOOL And Not val_is_bool( *val )
        throw_error( "type is not a boolean" )
    EndIf
    ProcedureReturn #True
EndProcedure

;------------------------------------------------------------------------------------------------------------------------------
; Object functions
;------------------------------------------------------------------------------------------------------------------------------
Procedure.l val_callEx( *f._value, *args.varray )
    Protected *int._value
    If OpenLibrary(1, nekolib)
        func.alloc_func_prototype = GetFunction(1, "neko_val_callEx")
        If func <> 0
            *int = func( nil, *f, val_array_ptr( *args ), val_array_size( *args ), nil )
        EndIf
        CloseLibrary(1)
    EndIf
    ProcedureReturn *int
EndProcedure




;------------------------------------------------------------------------------------------------------------------------------
; Initialize from haXe script
;------------------------------------------------------------------------------------------------------------------------------
ProcedureCDLL.l initialize( vtrue.l, vfalse.l, vnull.l )
    val_true = vtrue
    val_false = vfalse
    val_null = vnull
    ProcedureReturn val_null
EndProcedure

ProcedureCDLL.l initialize__3()
    ProcedureReturn @initialize()
EndProcedure
; IDE Options = PureBasic 5.71 LTS (Linux - x64)
; ExecutableFormat = Shared .so
; CursorPosition = 327
; Folding = ------
; UseMainFile = nPure.pb
; Executable = nPure.ndll.dll
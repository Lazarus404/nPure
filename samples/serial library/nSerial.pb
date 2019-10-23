IncludeFile "../../nPure/nPure.pb"

; Note the parameters. This is how functions with more than 5 parameters are handled
ProcedureCDLL.l open_serial_port( *args.pbarray, nargs.l )
    If nargs < 9
        ProcedureReturn val_null
    EndIf
    
    val_check( *args\l[0], #VAL_INT ) ; serial port
    val_check( *args\l[1], #VAL_STRING ) ; serial port name
    val_check( *args\l[2], #VAL_INT ) ; baud
    val_check( *args\l[3], #VAL_INT ) ; parity
    val_check( *args\l[4], #VAL_INT ) ; data
    val_check( *args\l[5], #VAL_INT ) ; stop
    val_check( *args\l[6], #VAL_INT ) ; handshake
    val_check( *args\l[7], #VAL_INT ) ; input_size
    val_check( *args\l[8], #VAL_INT ) ; output_size
    
    If OpenSerialPort( val_int( *args\l[0] ), val_string( *args\l[1] ), val_int( *args\l[2] ), val_int( *args\l[3] ), val_int( *args\l[4] ), val_int( *args\l[5] ), val_int( *args\l[6] ), val_int( *args\l[7] ), val_int( *args\l[8] ) )
        ProcedureReturn val_true
    Else
        ProcedureReturn val_false
    EndIf
EndProcedure

; replaces DEFINE_PRIM_MULT for open_serial_port
ProcedureCDLL.l open_serial_port__MULT()
    ProcedureReturn @open_serial_port()
EndProcedure

ProcedureCDLL.l close_serial_port( *portnum._value )
    val_check( *portnum, #VAL_INT )
    If Not IsSerialPort( val_int( *portnum ) )
        ProcedureReturn val_false
    EndIf
    CloseSerialPort( val_int( *portnum ) )
    ProcedureReturn val_true
EndProcedure

; replace DEFINE_PRIM for close_serial_port... note the "number of parameters" specifier at the end of the method name...
ProcedureCDLL.l close_serial_port__1()
    ProcedureReturn @close_serial_port()
EndProcedure

ProcedureCDLL.l is_serial_port( *portnum._value )
    val_check( *portnum, #VAL_INT )
    If Not IsSerialPort( val_int( *portnum ) )
        ProcedureReturn val_false
    EndIf
    ProcedureReturn val_true
EndProcedure

ProcedureCDLL.l is_serial_port__1()
    ProcedureReturn @is_serial_port()
EndProcedure

ProcedureCDLL.l available_serial_port_input( *portnum._value )
    val_check( *portnum, #VAL_INT )
    If Not IsSerialPort( val_int( *portnum ) )
        ProcedureReturn val_false
    EndIf
    Protected bytes.l = AvailableSerialPortInput( val_int( *portnum ) )
    ProcedureReturn alloc_int( bytes )
EndProcedure

ProcedureCDLL.l available_serial_port_input__1()
    ProcedureReturn @available_serial_port_input()
EndProcedure

ProcedureCDLL.l available_serial_port_output( *portnum._value )
    val_check( *portnum, #VAL_INT )
    If Not IsSerialPort( val_int( *portnum ) )
        ProcedureReturn val_false
    EndIf
    Protected bytes.l = AvailableSerialPortOutput( val_int( *portnum ) )
    ProcedureReturn alloc_int( bytes )
EndProcedure

ProcedureCDLL.l available_serial_port_output__1()
    ProcedureReturn @available_serial_port_output()
EndProcedure
; IDE Options = PureBasic 4.20 (Windows - x86)
; ExecutableFormat = Shared Dll
; CursorPosition = 39
; Folding = --
; UseMainFile = nSerial.pb
; Executable = nSerial.ndll.dll
; DisableDebugger
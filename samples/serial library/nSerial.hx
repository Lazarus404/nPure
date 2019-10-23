class NSerial
{
	//Parity
	public static var PB_SerialPort_NoParity : Int = 0;
	public static var PB_SerialPort_EvenParity : Int = 2;
	public static var PB_SerialPort_MarkParity : Int = 3;
	public static var PB_SerialPort_OddParity : Int = 1;
	public static var PB_SerialPort_SpaceParity : Int = 4;

	//Handshake
	public static var PB_SerialPort_NoHandshake : Int = 0;
	public static var PB_SerialPort_RtsHandshake : Int = 1;
	public static var PB_SerialPort_RtsCtsHandshake : Int = 2;
	public static var PB_SerialPort_XonXoffHandshake : Int = 3;

	public static var currentPort : Int = 0;
	public var portNum : Int;

	public function new()
	{
		portNum = currentPort++;
		// this must be called for every ndll you create, before you can use the ndll. This is because, PB has no way
		// of knowing what the haXe true, false and null values are without being passed them first, as these values are
		// created in Neko at runtime
		_initialize( true, false, null );
	}

	public function openSerialPort( port : String, baud : Int, parity : Int, data : Int, stop : Int, handshake : Int, inputSize : Int, outputSize : Int ) : Bool
	{
		return _openSerialPort( portNum, neko.Lib.haxeToNeko( port ), baud, parity, data, stop, handshake, inputSize, outputSize );
	}

	public function closeSerialPort() : Void
	{
		_closeSerialPort( portNum );
	}

	public function isSerialPort() : Bool
	{
		return _isSerialPort( portNum );
	}

	public function availableSerialPortInput() : Int
	{
		return _availableSerialPortInput( portNum );
	}

	public function availableSerialPortOutput() : Int
	{
		return _availableSerialPortOutput( portNum );
	}

	public static var _openSerialPort = neko.Lib.load( "nSerial", "open_serial_port", -1 );
	public static var _closeSerialPort = neko.Lib.load( "nSerial", "close_serial_port", 1 );
	public static var _isSerialPort = neko.Lib.load( "nSerial", "is_serial_port", 1 );
	public static var _availableSerialPortInput = neko.Lib.load( "nSerial", "available_serial_port_input", 1 );
	public static var _availableSerialPortOutput = neko.Lib.load( "nSerial", "available_serial_port_output", 1 );
	public static var _initialize = neko.Lib.load( "nSerial", "initialize", 3 );
}
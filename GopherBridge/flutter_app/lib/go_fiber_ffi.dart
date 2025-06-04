import 'dart:ffi' as ffi;
import 'dart:io';

typedef StartServerFunc = ffi.Void Function();
typedef StartServer = void Function();

class GoFiberFFI {
  static final ffi.DynamicLibrary _lib = Platform.isAndroid
      ? ffi.DynamicLibrary.open("libgofiber.so")
      : throw UnsupportedError("Only Android supported");

  static final StartServer startServer = _lib
      .lookup<ffi.NativeFunction<StartServerFunc>>('StartServer')
      .asFunction();
}

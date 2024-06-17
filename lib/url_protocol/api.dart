import 'windows_protocol.dart' if (dart.library.js_interop) 'web_url_protocol.dart';

void registerProtocolHandler(
  String scheme, {
  String? executable,
  List<String>? arguments,
}) {
  WindowsProtocolHandler().register(
    scheme,
    executable: executable,
    arguments: arguments,
  );
}

void unregisterProtocolHandler(String scheme) {
  WindowsProtocolHandler().unregister(scheme);
}

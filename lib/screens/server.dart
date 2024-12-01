import 'dart:convert';
import 'dart:io';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as io;
import 'package:shelf_router/shelf_router.dart';

void main() async {
  final router = Router();

  router.post('/trigger', (Request request) async {
    final payload = await request.readAsString();
    if (payload.contains('location')) {
      return Response.ok(jsonEncode({'action': 'trigger_location'}),
          headers: {'Content-Type': 'application/json'});
    } else if (payload.contains('calls')) {
      return Response.ok(jsonEncode({'action': 'trigger_calls'}),
          headers: {'Content-Type': 'application/json'});
    } else {
      return Response.badRequest(body: 'Unknown action');
    }
  });

  final handler =
      const Pipeline().addMiddleware(logRequests()).addHandler(router);

  final server = await io.serve(handler, 'localhost', 8080);
  print('Server running on http://localhost:${server.port}');
}

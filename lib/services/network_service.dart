import 'dart:async';
import 'dart:convert';
import 'package:web_socket_channel/web_socket_channel.dart';
import '../models/game_models.dart';

enum NetworkState { disconnected, connecting, connected, error }

class NetworkService {
  WebSocketChannel? _channel;
  NetworkState _state = NetworkState.disconnected;
  final String serverUrl;
  
  final _messageController = StreamController<Map<String, dynamic>>.broadcast();
  Stream<Map<String, dynamic>> get messageStream => _messageController.stream;
  
  NetworkState get state => _state;
  
  NetworkService({this.serverUrl = 'ws://localhost:8080'});
  
  Future<void> connect() async {
    try {
      _state = NetworkState.connecting;
      _channel = WebSocketChannel.connect(Uri.parse(serverUrl));
      
      await _channel!.ready;
      _state = NetworkState.connected;
      
      _listenToMessages();
    } catch (e) {
      _state = NetworkState.error;
      rethrow;
    }
  }
  
  void _listenToMessages() {
    _channel!.stream.listen(
      (message) {
        if (message is String) {
          try {
            final data = jsonDecode(message) as Map<String, dynamic>;
            _messageController.add(data);
          } catch (e) {
            print('Error parsing message: $e');
          }
        }
      },
      onError: (error) {
        print('WebSocket error: $error');
        _state = NetworkState.error;
      },
      onDone: () {
        print('WebSocket connection closed');
        _state = NetworkState.disconnected;
      },
    );
  }
  
  void send(Map<String, dynamic> message) {
    if (_channel != null && _state == NetworkState.connected) {
      _channel!.sink.add(jsonEncode(message));
    }
  }
  
  void sendMessage(String type, Map<String, dynamic> data) {
    send({'type': type, ...data});
  }
  
  void joinGame(String playerId, String playerName) {
    sendMessage('join_game', {
      'playerId': playerId,
      'playerName': playerName,
    });
  }
  
  void movePlayer(String playerId, double x, double y) {
    sendMessage('move', {
      'playerId': playerId,
      'x': x,
      'y': y,
    });
  }
  
  void shoot(String playerId, double vx, double vy) {
    sendMessage('shoot', {
      'playerId': playerId,
      'vx': vx,
      'vy': vy,
    });
  }
  
  void disconnect() {
    _channel?.sink.close();
    _messageController.close();
    _state = NetworkState.disconnected;
  }
}

// Mock network service for offline testing
class MockNetworkService extends NetworkService {
  MockNetworkService() : super(serverUrl: 'mock');
  
  @override
  Future<void> connect() async {
    _state = NetworkState.connected;
    // Simulate receiving updates
    Timer.periodic(const Duration(milliseconds: 50), (_) {
      // Send mock player updates
    });
  }
  
  @override
  void send(Map<String, dynamic> message) {
    // Mock implementation - do nothing or log
    print('Mock sending: $message');
  }
}

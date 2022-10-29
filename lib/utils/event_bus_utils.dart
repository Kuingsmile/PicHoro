import 'package:event_bus/event_bus.dart';

EventBus eventBus = EventBus();

class AlbumRefreshEvent {
  bool albumKeepAlive = true;
  AlbumRefreshEvent({
    this.albumKeepAlive = true,
  });
}

class Connection {

  final int heartbeatInterval;
  final int heartbeatTimeout;
  final String url;

  Connection(this.url, {
    this.heartbeatInterval = 17500,
    this.heartbeatTimeout: 15000,
  });

}
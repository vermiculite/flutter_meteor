enum STATUS {
  connecting,
  connected,
  waiting,
  failed,
  offline,
}

class Status {
  STATUS status;

  Status({
    this.status = STATUS.connecting,
  });
}

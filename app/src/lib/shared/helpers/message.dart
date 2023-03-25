enum OutcomeStatus { ok, warning, error }

enum BehaviorActions { stop, start }

class Message {
  Message({
    required OutcomeStatus status,
    dynamic result,
    String? message,
    BehaviorActions? action,
  })  : _status = status,
        _result = result,
        _message = message,
        _action = action;

  OutcomeStatus _status;
  dynamic _result;

  String? _message;
  BehaviorActions? _action;

  OutcomeStatus get status => _status;
  dynamic get result => _result;
  String? get message => _message;
  BehaviorActions? get action => _action;
}

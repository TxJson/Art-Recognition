import 'package:art_app_fyp/shared/helpers/message.dart';

class ResponseError {
  static Message createError(String message, BehaviorActions? action) =>
      Message(status: OutcomeStatus.error, message: message, action: action);

  static Message noInterpreter() =>
      createError('Interpreter is null or deleted', null);

  static Message input(buffers) => createError(
      "Image Input and Tensor Input byte size does not match: $buffers\nInterpreter cannot run if the byte sizes do not match",
      BehaviorActions.stop);

  static Message output(buffers) => createError(
      "Output Tensors buffer size does not match: $buffers}\nInterpreter cannot run if the byte sizes do not match",
      BehaviorActions.stop);
}

class ResponseOk {
  static Message createOk(dynamic result) =>
      Message(status: OutcomeStatus.ok, result: result);
}

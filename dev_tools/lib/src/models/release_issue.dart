import 'package:meta/meta.dart';

@immutable
class ReleaseIssue {
  final String issueMessage;
  final StackTrace? stackTrace;

  const ReleaseIssue(this.issueMessage, {this.stackTrace});
}

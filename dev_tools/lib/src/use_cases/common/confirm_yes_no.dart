import 'dart:io';

class ConfirmYesNo {
  const ConfirmYesNo();

  Future<bool> call(String question) async {
    stdout.write('$question [y/n]: ');
    final response = (stdin.readLineSync() ?? '').trim().toLowerCase();
    return response == 'y' || response == 'yes';
  }
}

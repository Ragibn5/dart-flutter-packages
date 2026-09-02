class CommandNotFoundException implements Exception {
  final List<String> programs;

  const CommandNotFoundException(this.programs);

  @override
  String toString() {
    return "Command(s) not found: '${programs.map((e) => "'$e'").join(', ')}'"
        '                      Make sure they are installed.';
  }
}

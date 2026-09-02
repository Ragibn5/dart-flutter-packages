class ParseReleaseBranch {
  const ParseReleaseBranch();

  ({String packagePath, String version})? call(String branch) {
    const prefix = 'release/';
    if (!branch.startsWith(prefix)) return null;
    final rest = branch.substring(prefix.length);
    final match = RegExp(r'^(.+)-(\d+\.\d+\.\d+)$').firstMatch(rest);
    if (match == null) return null;
    return (packagePath: match.group(1)!, version: match.group(2)!);
  }
}

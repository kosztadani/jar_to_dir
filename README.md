# jar_to_dir.sh

`jar_to_dir.sh` is a bash script to recursively extract JAR, WAR and EAR files.

## Motivation

Use-cases:
- Extract an archive to be able to `grep` (or use similar tools) against its contents.
- Extracting two differing archives, to compare contents.

## Dependencies
- bash (https://www.gnu.org/software/bash)
- JDK (`jar` utility; https://docs.oracle.com/javase/8/docs/technotes/tools/unix/jar.html)
- find (https://www.gnu.org/software/findutils)

## Usage

```
Usage: jar_to_dir.sh [options] <path>
       jar_to_dir.sh [-m | --max-recurse <NUM>] [-1 | --once]
                     [-j | --jars] [-J | --no-jars]
                     [-w | --wars] [-W | --no-wars]
                     [-e | --ears] [-E | --no-ears]

Extract JAR/WAR/EAR files recursively.

  -h, --help               Print this help message
  -m, --max-recurse NUM    Maximum recursion depth (0 is infinite; default: 0)
  -1, --once               Equivalent to '--max-recurse 1'
  -j, --jars               Extract JAR files (default)
  -J, --no-jars            Don't extract JAR files
  -w, --wars               Extract WAR files (default)
  -W, --no-wars            Don't extract WAR files
  -e, --ears               Extract EAR files (default)
  -E, --no-ears            Don't extract EAR files
```

## Examples

```bash
# Unzip a particular file recursively.
jar_to_dir.sh /path/to/application.jar
jar_to_dir.sh /path/to/application.war

# Unzip only once
jar_to_dir.sh -1 /path/to/application.jar

# Unzip everything in a directory
jar_to_dir.sh /path/to/libs
```

## Copyright

No rights reserved, this work is released into the public domain.

For a full "license", see COPYING.txt.
(Creative Commons CC0 1.0 Universal license.)
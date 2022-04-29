# A example on how to use mimalloc in your Nim projects

This repository contains a single Nim file along with a .nims config file that makes it possible
to use mimalloc for Nim with ARC/ORC.

To compile with malloc, simply add `-d:mimalloc` to your compilation flags, or uncomment the relevant line in
the `main.nims` file.

There's also a `-d:mimallocDynamic` flag that makes the program link against mimalloc dynamically.

## Performance
Mimalloc is advertised as having great performance, and that is true. It's especially useful with 
ARC/ORC with threads because currently ARC/ORC can be slower for single-threaded allocation-heavy applications when compiled with `--threads:on` (see [bug #18146](https://github.com/nim-lang/Nim/issues/18146)).

Some results for the code in this benchmark (it's a traditional binarytrees benchmark). Checked with `hyperfine './src/main 18'` on a Ryzen 7 3700X machine:
| Command                                               | Time (min) |
|-------------------------------------------------------|------------|
| `-d:danger --mm:refc`                                 | 1.453 s    |
| `-d:danger --mm:refc --threads:on`                    | 1.513 s    |
| `-d:danger --mm:orc` (without Mimalloc)               | 683.0 ms   |
| `-d:danger --mm:orc --threads:on`  (without Mimalloc) | **1.368** s    |
| `-d:danger --mm:orc`  (with Mimalloc)                 | 562.0 ms   |
| `-d:danger --mm:orc --threads:on` (with Mimalloc)     | **597.6** ms   |

One advantage of linking Mimalloc statically is that with LTO the compiler can inline memory-allocation code from the allocator itself, resulting in even better performance:
| Command                                                     | Time (min) |
|-------------------------------------------------------------|------------|
| `-d:danger --mm:refc --threads:on -d:lto`                   | 1.424 s    |
| `-d:danger --mm:orc -d:lto` (without Mimalloc)              | 609.9 ms   |
| `-d:danger --mm:orc --threads:on -d:lto` (without Mimalloc) | **1.302** s    |
| `-d:danger --mm:orc -d:lto` (with Mimalloc)                 | 509.3 ms   |
| `-d:danger --mm:orc --threads:on -d:lto` (with Mimalloc)    | **514.2 ms**   |

## Mimalloc in this repository
This repository has mimalloc v2.0.6 checked out with all the extra files removed (e.g. the bin folder).
If you want to use another mimalloc version, remove the `mimalloc` folder and clone https://github.com/microsoft/mimalloc yourself.

## Licensing
Original code in this repository is licensed under the MIT license (see LICENSE).

The code in `main.nim` comes from [Programming Language Benchmarks](https://github.com/hanabi1224/Programming-Language-Benchmarks/).

Mimalloc itself is also MIT, so if you link with it statically you **must** retain its LICENSE file
(available in `src/mimalloc/LICENSE`) with your program's distribution in some way.

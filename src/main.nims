import std/os

switch("gc", "orc")

var useMalloc = defined(useMalloc)

when not defined(mimallocDynamic):
  switch("define", "useMalloc")
  useMalloc = true

  let
    mimallocPath = projectDir() / "mimalloc"
    mimallocStatic = "mimallocStatic=" & (mimallocPath / "src" / "static.c")
    mimallocIncludePath = "mimallocIncludePath=" & (mimallocPath / "include")

  # So we can compile mimalloc from the patched files
  switch("define", mimallocStatic)
  switch("define", mimallocIncludePath)

  # Mimalloc has a lot of asserts that we need to disable
  # because this isn't a debug build (I spent half an hour debugging this :( )
  # XXX: Maybe keep it enabled unless -d:release or -d:danger?
  switch("passC", "-DNDEBUG")

if useMalloc:
  {.hint: "Patching malloc.nim to use mimalloc".}
  patchFile("stdlib", "malloc", "patchedstd" / "mimalloc")

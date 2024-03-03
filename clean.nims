import std/os

for file in walkDirRec(thisDir()):
  if file.splitFile().ext == ".exe":
    rmFile file

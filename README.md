# Zig Open

Cross platform logic for opening paths with the System's default launcher and application.

## Installation

```
zig fetch --save git+https://github.com/Tired-Fox/zig-open#{commit,branch,tag}
```

```zig
// build.zig

pub fn build(b: *std.Build) void {
  // ...
  const open = b.dependency("zig-open", .{}).module("open")

  const exe_mod = b.createModule(.{
      .root_source_file = b.path("src/main.zig"),
      .target = target,
      .optimize = optimize,
  });

  exe_mode.addImport("open", open);
}
```

## Usage

```zig
const open = @import("zig-open");

pub fn main() !void {
  try open.that("https//example.com");
}
```

# Zig Open

Cross platform logic for opening paths with the System's default launcher and application.

## Installation

```
zig fetch --save git+https://github.com/Tired-Fox/zig-open#{commit,branch,tag}
```

## Usage

```zig
const open = @import("zig-open");

pub fn main() !void {
  try open.that("https//example.com");
}
```

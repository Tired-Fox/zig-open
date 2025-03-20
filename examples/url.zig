const open = @import("open");

pub fn main() !void {
    try open.that("https://example.com");
}

const std = @import("std");

/// Attempt to open the path in the default application
/// given the system launcher.
pub fn that(path: []const u8) !void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const allo = arena.allocator();

    switch (@import("builtin").os.tag) {
        .windows => {
            _ = std.process.Child.run(.{
                .allocator = allo,
                .argv = &.{
                    "cmd",
                    "/c",
                    "start",
                    "\"\"",
                    path
                }
            }) catch return error.NoWorkingLauncher;
        },
        .macos => {
            _ = std.process.Child.run(.{
                .allocator = allo,
                .argv = &.{
                    "/usr/bin/open",
                    path
                }
            }) catch return error.NoWorkingLauncher;
        },
        .linux => {
            inline for (.{
                .{ "xdg-open", path },
                .{ "gio", "open", path },
                .{ "gnome-open", path },
                .{ "kde-open", path },
            }) |args| {
                _ = std.process.Child.run(.{
                    .allocator = allo,
                    .argv = &args
                }) catch continue;
                break;
            } else {
                return error.NoWorkingLauncher;
            }
        },
        else => |platform| @compileError("unsupported platform: " ++ @tagName(platform))
    }
}

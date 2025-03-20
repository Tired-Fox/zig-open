const std = @import("std");

/// Attempt to open the path in the default application
/// given the system launcher.
pub fn that(path: []const u8) !void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const allo = arena.allocator();

    std.debug.print("{s}\n", .{path});

    switch (@import("builtin").os.tag) {
        .windows => {
            const size = std.mem.replacementSize(u8, path, "&", "^&");
            const target = try allo.alloc(u8, size);
            defer allo.free(target);
            _ = std.mem.replace(u8, path, "&", "^&", target);

            _ = std.process.Child.run(.{
                .allocator = allo,
                .argv = &.{
                    "cmd",
                    "/c",
                    "start",
                    "\"\"",
                    target
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

/// Attempt to open the path in the default application
/// given the system launcher.
pub fn with(app: []const u8, path: []const u8) !void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const allo = arena.allocator();

    switch (@import("builtin").os.tag) {
        .windows => {
            const size = std.mem.replacementSize(u8, path, "&", "^&");
            const target = try allo.alloc(u8, size);
            defer allo.free(target);
            _ = std.mem.replace(u8, path, "&", "^&", target);

            _ = std.process.Child.run(.{
                .allocator = allo,
                .argv = &.{
                    "cmd",
                    "/c",
                    "start",
                    "\"\"",
                    app,
                    path
                }
            }) catch return error.NoWorkingLauncher;
        },
        .macos => {
            _ = std.process.Child.run(.{
                .allocator = allo,
                .argv = &.{
                    "/usr/bin/open",
                    path,
                    "-a",
                    app
                }
            }) catch return error.NoWorkingLauncher;
        },
        .linux => {
            _ = std.process.Child.run(.{
                .allocator = allo,
                .argv = &.{
                    app,
                    path,
                }
            }) catch return error.NoWorkingLauncher;
        },
        else => |platform| @compileError("unsupported platform: " ++ @tagName(platform))
    }
}

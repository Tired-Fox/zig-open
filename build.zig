const std = @import("std");

const ModuleMap = std.meta.Tuple(&[_]type{ []const u8, *std.Build.Module });
const Example = struct {
    name: []const u8,
    path: []const u8,
};

const examples = [_]Example {
    .{ .name = "url", .path = "examples/url.zig",  },
};

pub fn addExample(
    b: *std.Build,
    target: std.Build.ResolvedTarget,
    optimize: std.builtin.OptimizeMode,
    comptime example: Example,
    modules: []const ModuleMap,
) void {
    const exe = b.addExecutable(.{
        .name = example.name,
        .root_source_file = b.path(example.path),
        .target = target,
        .optimize = optimize,
    });

    for (modules) |module| {
        exe.root_module.addImport(module[0], module[1]);
    }

    const ecmd = b.addRunArtifact(exe);
    ecmd.step.dependOn(b.getInstallStep());
    if (b.args) |args| {
        ecmd.addArgs(args);
    }

    const estep = b.step("example-" ++ example.name, "Run example-" ++ example.name);
    estep.dependOn(&ecmd.step);
}

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const module = b.addModule("open", .{
        .root_source_file = b.path("src/root.zig"),
        .target = target,
        .optimize = optimize,
    });

    const lib_unit_tests = b.addTest(.{ .root_module = module });
    const run_lib_unit_tests = b.addRunArtifact(lib_unit_tests);

    const test_step = b.step("test", "Run unit tests");
    test_step.dependOn(&run_lib_unit_tests.step);

    inline for (examples) |example| {
        addExample(b, target, optimize, example, &[_]ModuleMap{
            .{ "open", module }
        });
    }
}

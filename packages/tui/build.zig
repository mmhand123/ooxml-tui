const std = @import("std");

pub fn build(b: *std.Build) !void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});
    const mod = b.addModule("native", .{
        .root_source_file = b.path("src/native/root.zig"),
        .target = target,
        .optimize = optimize,
    });

    const lib = b.addLibrary(.{
        .name = "ooxml-tui",
        .root_module = mod,
        .linkage = .dynamic,
    });

    const install_dir = b.addInstallArtifact(lib, .{ .dest_dir = .{ .override = .{
        .custom = try std.fmt.allocPrint(b.allocator, "./dist/ooxml-tui", .{}),
    } } });

    const lib_check = b.addExecutable(.{
        .name = "check",
        .root_module = mod,
    });

    const check = b.step("check", "Check if the module compiles");

    check.dependOn(&lib_check.step);

    const build_step = b.step("build", "Build the module");
    build_step.dependOn(&install_dir.step);

    b.getInstallStep().dependOn(&install_dir.step);

    const mod_tests = b.addTest(.{
        .root_module = mod,
    });

    const run_mod_tests = b.addRunArtifact(mod_tests);

    const test_step = b.step("test", "Run tests");
    test_step.dependOn(&run_mod_tests.step);
}

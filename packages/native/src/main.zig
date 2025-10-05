const std = @import("std");

pub fn main() !void {
    try std.fs.File.stdout().writeAll("Hello, Native!\n");

    const dirname = std.fs.path.dirname(@src().file) orelse ".";

    const abs = try std.fs.path.resolve(std.heap.page_allocator, dirname);
    defer std.heap.page_allocator.free(abs);

    std.debug.print("dirname: {s}\n", .{abs});
}

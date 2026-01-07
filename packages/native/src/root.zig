//! By convention, root.zig is the root source file when making a library.
const std = @import("std");
const Allocator = std.mem.Allocator;
const zip = std.zip;
const fs = std.fs;

pub fn main() !void {
    const gpa = std.heap.page_allocator;
    const project_root = try projectRootAbs(gpa);
    const test_file_path = try std.fs.path.resolve(gpa, &.{ project_root, "tests", "fixtures", "single-file", "blank.docx" });

    // const dirname = std.fs.path.dirname(@src().file) orelse ".";
    //
    // const abs = try std.fs.path.resolve(std.heap.page_allocator, &.{ dirname, "..", "tests", "fixtures", "single-file", "blank.docx" });
    // defer std.heap.page_allocator.free(abs);
    //
    // std.debug.print("abs: {s}\n", .{abs});
    // std.debug.print("dirname: {s}\n", .{dirname});
    std.debug.print("self_dir: {s}\n", .{project_root});
    std.debug.print("test_file_path: {s}\n", .{test_file_path});

    try printZipTree(gpa, test_file_path);
}

pub fn bufferedPrint() !void {
    // Stdout is for the actual output of your application, for example if you
    // are implementing gzip, then only the compressed bytes should be sent to
    // stdout, not any debugging messages.
    var stdout_buffer: [1024]u8 = undefined;
    var stdout_writer = std.fs.File.stdout().writer(&stdout_buffer);
    const stdout = &stdout_writer.interface;

    try stdout.print("Run `zig build test` to run the tests.\n", .{});

    try stdout.flush(); // Don't forget to flush!
}

pub fn add(a: i32, b: i32) i32 {
    return a + b;
}

test "basic add functionality" {
    try std.testing.expect(add(3, 7) == 10);
}

fn projectRootAbs(alloc: std.mem.Allocator) ![]u8 {
    const self_path = @src().file; // may be "main.zig", "src/main.zig", or absolute
    //
    if (std.fs.path.isAbsolute(self_path)) {
        const d = std.fs.path.dirname(self_path) orelse "/";
        return std.fmt.allocPrint(alloc, "{s}", .{d});
    }

    const dir_rel = std.fs.path.dirname(self_path) orelse ".";
    const cwd = try std.process.getCwdAlloc(alloc);
    defer alloc.free(cwd);

    return std.fs.path.resolve(alloc, &.{ cwd, dir_rel });
}

pub fn printZipTree(allocator: Allocator, abs_zip_path: []const u8) !void {
    // open read-only
    var file = try std.fs.openFileAbsolute(abs_zip_path, .{ .mode = .read_only });
    defer file.close();

    // 0.15 reader: allocate a buffer (heap so the Reader stays valid the whole time)
    const buf = try allocator.alloc(u8, 64 * 1024);
    defer allocator.free(buf);
    var reader = file.reader(buf);

    // std.zip iterator over the file reader (stream is seekable via reader.seekTo)
    var it = try zip.Iterator.init(&reader);

    // collect names
    var names = std.ArrayList([]const u8).init(allocator);
    defer {
        for (names.items) |n| allocator.free(n);
        names.deinit();
    }

    // temp filename buffer (per entry) — length comes from Central Directory
    var name_buf: [std.fs.max_path_bytes]u8 = undefined;

    while (try it.next()) |entry| {
        // jump to filename in the central directory header and read it
        try reader.seekTo(entry.header_zip_offset + @sizeOf(zip.CentralDirectoryFileHeader));
        const name_len: usize = @intCast(entry.filename_len);
        const name_slice = name_buf[0..name_len];
        try reader.interface.readNoEof(name_slice);

        // own a copy
        const name_copy = try allocator.alloc(u8, name_slice.len);
        std.mem.copy(u8, name_copy, name_slice);

        try names.append(name_copy);
    }

    // sort for pretty output
    std.mem.sort([]const u8, names.items, {}, struct {
        fn lt(_: void, a: []const u8, b: []const u8) bool {
            return std.mem.lessThan(u8, a, b);
        }
    }.lt);

    // print a tree (dedupe parent dirs)
    var seen = std.StringHashMap(void).init(allocator);
    defer seen.deinit();

    for (names.items) |full| {
        // parents
        var start: usize = 0;
        while (true) {
            if (std.mem.indexOfScalarPos(u8, full, start, '/')) |idx| {
                const dir = full[0 .. idx + 1];
                if (!try seen.containsOrPut(dir, {})) printIndented(dir);
                start = idx + 1;
            } else break;
        }
        // file
        if (!std.mem.endsWith(u8, full, "/")) printIndented(full);
    }
}

fn printIndented(path: []const u8) void {
    var depth: usize = 0;
    for (path) |c| {
        if (c == '/') depth += 1;
    }

    var i: usize = 0;
    while (i < depth) : (i += 1) std.debug.print("  ", .{});

    const last = std.mem.lastIndexOfScalar(u8, path, '/') orelse 0;
    const base = if (last == 0) path else path[last + 1 ..];
    std.debug.print("{s}\n", .{base});
}

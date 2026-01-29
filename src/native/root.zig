const std = @import("std");
const Allocator = std.mem.Allocator;
const zip = std.zip;
const fs = std.fs;

// Pass in dir
// Walk dir and find all OOXML files
// Unzip to tmp (name = hash of full path?)
// Create struct for storing the file structure
//

const DocumentType = enum { docx, xlsx };

const Document = struct { type: DocumentType, tmp_path: []const u8 };

export fn hello() [*:0]const u8 {
    return "Hello from Zig!";
}

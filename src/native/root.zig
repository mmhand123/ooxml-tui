const std = @import("std");
const Allocator = std.mem.Allocator;
const zip = std.zip;
const fs = std.fs;

// Pass in dir
// Walk dir and find all OOXML files
// Unzip to tmp (name = hash of full path?)
// Create struct for storing the file structure

const DocumentType = enum { docx, xlsx };

const Document = struct { type: DocumentType, tmp_path: []const u8 };

var gpa = std.heap.GeneralPurposeAllocator(.{}){};
const globalAllocator = gpa.allocator();
var arena = std.heap.ArenaAllocator.init(globalAllocator);
const globalArena = arena.allocator();

export fn hello() [*:0]const u8 {
    return "Hello from Zig!";
}

const ExternalStruct = extern struct {
    x: u32,
    y: u32,
};

export fn helloStruct() ?*ExternalStruct {
    const hello_struct = globalAllocator.create(ExternalStruct) catch return null;

    hello_struct.x = 5;
    hello_struct.y = 10;

    errdefer globalAllocator.destroy(hello_struct);

    return hello_struct;
}

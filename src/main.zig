const std = @import("std");
const builtin = @import("builtin");
const http = std.http;
const Os = builtin.os;
const Arch = @import("builtin").cpu.arch;

const print = std.debug.print;

fn get_bun_releases() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const client = std.http.Client{ .allocator = gpa.allocator() };
    const request = try client.open(.{
        .method = .GET,
        .uri = std.Uri.parse("https://github.com/oven-sh/bun/releases")
    });
    defer request.deinit();


    print(request.response.content_disposition, .{});
}

pub fn get_architecture() ![]const u8  {
    const os = 
        if (Os.tag == .windows) "windows" 
        else if (Os.tag == .linux) "linux"
        else if (Os.tag.isDarwin()) "darwin";

    const arch = switch (Arch) {
        .x86_64 => "x64",
        .arm => "aarch64",
        else => @tagName(Arch),
    };

    return try std.fmt.allocPrint(std.heap.page_allocator, "{s}-{s}", .{os, arch});
}


pub fn main() !void {
    std.debug.print("test", .{});
    
    try get_bun_tags();
}

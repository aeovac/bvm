const std = @import("std");
const http = std.http;

const print = std.debug.print;

fn get_bun_releases() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();

    var client = std.http.Client{ .allocator = gpa.allocator() };
    defer client.deinit();

    var body = std.ArrayList(u8).init(gpa.allocator());
    defer body.deinit();

    _ = try client.fetch(.{
        .method = .GET,
        .location = .{
            .url = "https://api.github.com/repos/oven-sh/bun/releases"
        },
        .server_header_buffer = undefined,
        .response_storage = .{ .dynamic = &body }
    });

    print("Response: {s}\n", .{body.items});
}

pub fn main() !void {
    try get_bun_releases();
}

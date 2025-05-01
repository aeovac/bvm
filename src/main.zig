const std = @import("std");
const json = std.json;
const http = std.http;

const print = std.debug.print;

const BunReleasesFormat = struct {
    tag_name: []u8
};

fn getBunReleases(allocator: std.mem.Allocator) ![]u8 {
    var client = std.http.Client{ .allocator = allocator };
    defer client.deinit();
    
    var body = std.ArrayList(u8).init(allocator);
    defer body.deinit();

    const request = try client.fetch(.{
        .method = .GET,
        .location = .{
            .url = "https://api.github.com/repos/oven-sh/bun/releases",
        },
        .headers = .{
            .user_agent = .default
        },
        //.server_header_buffer = undefined,
        .response_storage = .{ .dynamic =  &body }
    });

    if (request.status != .ok) {
        print("HTTP error: {}\n", .{request.status});
        return error.HttpRequestFailed;
    }

    var response = try json.parseFromSlice(
        []BunReleasesFormat, 
        allocator, 
        body.items, 
        .{
            .ignore_unknown_fields = true
        }
    );
    defer response.deinit();

    if (response.value.len == 0) {
        print("No releases found.\n", .{});
        return error.NoReleasesFound;
    }
    
    return allocator.dupe(u8, response.value[0].tag_name);
}

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    var args = try std.process.argsWithAllocator(allocator);
    defer args.deinit();

    while (args.next()) |arg| {
        if (std.mem.eql(u8, arg, "--list") or std.mem.eql(u8, arg, "-l")) {
            print("List", .{});
            break;
        } else if(std.mem.eql(u8, arg, "--releases") or std.mem.eql(u8, arg, "-r")) {
            const releases = try getBunReleases(allocator);
            defer allocator.free(releases);

            print("Releases: {s}", .{releases});
            break;
        }
    }
}

const std = @import("std");
const vm = @import("vm.zig");

const print = std.debug.print;

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
            const releases = try vm.getBunReleases(allocator);
            defer allocator.free(releases);

            print("Releases: {s}", .{releases});
            break;
        }
    }
}
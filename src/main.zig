const std = @import("std");
const argparse = @import("argparse");

const ArgumentParser = argparse.ArgumentParser(.{
    .app_name = "fpng",
    .app_description = "Floating-point number generator.",
    .app_version = .{ .major = 0, .minor = 1, .patch = 0 },
}, &[_]argparse.AppOptionPositional{
    .{
        .option = .{
            .name = "constant",
            .short = "-c",
            .long = "--constant",
            .metavar = "N",
            .description = "Generate time series and fill it with a constant number N.",
            .takes = 1,
        },
    },
    .{
        .option = .{
            .name = "double_precision",
            .short = "-d",
            .long = "--double-precision",
            .description = "Use f64 instead of f32 for generating the time series.",
        },
    },
    .{
        .positional = .{
            .name = "length",
            .metavar = "LENGTH",
            .description = "Time series length.",
        },
    },
    .{
        .positional = .{
            .name = "output",
            .metavar = "OUTPUT",
            .description = "Output file name",
        },
    },
});

fn writeBytesNTimes(writer: anytype, bytes: []const u8, n: usize) !void {
    var i: usize = 0;
    while (i < n) : (i += 1) for (bytes) |byte| try writer.writeByte(byte);
}

pub fn main() anyerror!void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();

    var allocator = arena.allocator();

    var args = try ArgumentParser.parseArgumentsAllocator(allocator);

    const length = try std.fmt.parseInt(usize, args.length, 10);
    const output = args.output;

    var file = try std.fs.cwd().createFile(output, .{});
    defer file.close();

    const w = file.writer();

    if (args.constant.len > 0) {
        if (args.double_precision) {
            const constant = try std.fmt.parseFloat(f64, args.constant);
            var bytes = @bitCast([8]u8, constant);
            std.mem.reverse(u8, bytes[0..]);
            try writeBytesNTimes(w, bytes[0..], length);
        } else {
            const constant = try std.fmt.parseFloat(f32, args.constant);
            var bytes = @bitCast([4]u8, constant);
            std.mem.reverse(u8, bytes[0..]);
            try writeBytesNTimes(w, bytes[0..], length);
        }
    }
}

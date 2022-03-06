const std = @import("std");
const argparse = @import("argparse");

const BoxMuller = @import("box_muller.zig").BoxMuller;
const ArgumentParser = @import("argument_parser.zig").ArgumentParser;

const parsing_error = @import("error.zig").parsing_error;

fn writeNumberNTimesWithIncrementNoise(comptime T: type, writer: anytype, number: T, length: usize, inc: T, noise: anytype) !void {
    // Floating-point number size in bytes
    const sz = @typeInfo(T).Float.bits / 8;

    var i: usize = 0;
    var n = number;
    while (i < length) : (i += 1) {
        // Convert floating-point number to bytes
        var bytes = @bitCast([sz]u8, n + noise.generate());

        // Reverse bits because of endianness
        std.mem.reverse(u8, bytes[0..]);

        // Write bytes
        for (bytes) |byte| try writer.writeByte(byte);

        // Increment number
        n += inc;
    }
}

pub fn main() anyerror!void {
    // Allocator
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    var allocator = arena.allocator();

    // Get Arguments
    var args = ArgumentParser.parseArgumentsAllocator(allocator) catch return;
    defer ArgumentParser.deinitArgs(args);

    // Random number generator
    var prng = std.rand.DefaultPrng.init(blk: {
        var seed: u64 = undefined;
        if (args.seed.len > 0) {
            seed = try std.fmt.parseInt(u64, args.seed, 10);
        } else {
            try std.os.getrandom(std.mem.asBytes(&seed));
        }
        break :blk seed;
    });
    const random = prng.random();

    if (args.double_precision) {
        // Parameters
        const number = std.fmt.parseFloat(f64, args.number) catch return parsing_error(f64, args.number);
        const length = std.fmt.parseInt(usize, args.length, 10) catch return parsing_error(usize, args.length);
        const increment = std.fmt.parseFloat(f64, args.increment) catch return parsing_error(f64, args.increment);

        // Noise generator
        const mu = std.fmt.parseFloat(f64, args.mu) catch return parsing_error(f64, args.mu);
        const sigma = std.fmt.parseFloat(f64, args.sigma) catch return parsing_error(f64, args.sigma);
        var noise_genator = BoxMuller(f64).init(random, mu, sigma);

        // Output file
        var file = try std.fs.cwd().createFile(args.output, .{});
        defer file.close();

        // Generate time series
        try writeNumberNTimesWithIncrementNoise(f64, file.writer(), number, length, increment, &noise_genator);
    } else {
        // Parameters
        const number = std.fmt.parseFloat(f32, args.number) catch return parsing_error(f32, args.number);
        const length = std.fmt.parseInt(usize, args.length, 10) catch return parsing_error(usize, args.length);
        const increment = std.fmt.parseFloat(f32, args.increment) catch return parsing_error(f32, args.increment);

        // Noise generator
        const mu = std.fmt.parseFloat(f32, args.mu) catch return parsing_error(f32, args.mu);
        const sigma = std.fmt.parseFloat(f32, args.sigma) catch return parsing_error(f32, args.sigma);
        var noise_genator = BoxMuller(f32).init(random, mu, sigma);

        // Output file
        var file = try std.fs.cwd().createFile(args.output, .{});
        defer file.close();

        // Generate time series
        try writeNumberNTimesWithIncrementNoise(f32, file.writer(), number, length, increment, &noise_genator);
    }
}

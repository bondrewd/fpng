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

    // Arguments
    var args = try ArgumentParser.parseArgumentsAllocator(allocator);

    // Typecast arguments
    const length = std.fmt.parseInt(usize, args.length, 10) catch return parsing_error(usize, args.length);
    const mu_str = if (args.mu.len > 0) args.mu else "0.0";
    const sigma_str = if (args.sigma.len > 0) args.sigma else "0.0";
    const number_str = if (args.number.len > 0) args.number else "0.0";
    const increment_str = if (args.increment.len > 0) args.increment else "0.0";

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
        // Box-Muller
        const mu = std.fmt.parseFloat(f64, mu_str) catch return parsing_error(f64, mu_str);
        const sigma = std.fmt.parseFloat(f64, sigma_str) catch return parsing_error(f64, sigma_str);

        var noise_genator = BoxMuller(f64).init(random, mu, sigma);

        // Parameters
        const number = std.fmt.parseFloat(f64, number_str) catch return parsing_error(f64, number_str);
        const increment = std.fmt.parseFloat(f64, increment_str) catch return parsing_error(f64, increment_str);

        // Output file
        const output = args.output;
        var file = try std.fs.cwd().createFile(output, .{});
        defer file.close();
        const fw = file.writer();

        // Generate time series
        try writeNumberNTimesWithIncrementNoise(f64, fw, number, length, increment, &noise_genator);
    } else {
        // Box-Muller
        const mu = std.fmt.parseFloat(f32, mu_str) catch return parsing_error(f32, mu_str);
        const sigma = std.fmt.parseFloat(f32, sigma_str) catch return parsing_error(f32, sigma_str);

        var noise_genator = BoxMuller(f32).init(random, mu, sigma);

        // Parameters
        const number = std.fmt.parseFloat(f32, number_str) catch return parsing_error(f32, number_str);
        const increment = std.fmt.parseFloat(f32, increment_str) catch return parsing_error(f32, increment_str);

        // Output file
        const output = args.output;
        var file = try std.fs.cwd().createFile(output, .{});
        defer file.close();
        const fw = file.writer();

        // Generate time series
        try writeNumberNTimesWithIncrementNoise(f32, fw, number, length, increment, &noise_genator);
    }
}

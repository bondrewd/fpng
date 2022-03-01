const std = @import("std");
const argparse = @import("argparse");

const ArgumentParser = argparse.ArgumentParser(.{
    .app_name = "fpng",
    .app_description = "Floating-point number generator.",
    .app_version = .{ .major = 0, .minor = 1, .patch = 0 },
}, &[_]argparse.AppOptionPositional{
    .{
        .option = .{
            .name = "double_precision",
            .short = "-d",
            .long = "--double-precision",
            .description = "Use f64 instead of f32 for generating the time series.",
        },
    },
    .{
        .option = .{
            .name = "number",
            .short = "-n",
            .long = "--number",
            .metavar = "F",
            .description = "Generate time series using the number N (default: 0.0)",
            .takes = 1,
        },
    },
    .{
        .option = .{
            .name = "increment",
            .short = "-i",
            .long = "--increment",
            .metavar = "I",
            .description = "Increment at each step by I (default: 0.0)",
            .takes = 1,
        },
    },
    .{
        .option = .{
            .name = "mu",
            .short = "-m",
            .long = "--mu",
            .metavar = "M",
            .description = "Random noise mean value M (default: 0.0)",
            .takes = 1,
        },
    },
    .{
        .option = .{
            .name = "sigma",
            .short = "-s",
            .long = "--sigma",
            .metavar = "S",
            .description = "Random noise sigma value S (default: 0.0)",
            .takes = 1,
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

fn BoxMullerIterator(comptime T: type) type {
    return struct {
        prng: std.rand.Random,
        mu: T,
        sigma: T,
        spare: ?T,

        const Self = @This();

        pub fn init(prng: std.rand.Random, mu: T, sigma: T) Self {
            return .{
                .prng = prng,
                .mu = mu,
                .sigma = sigma,
                .spare = null,
            };
        }

        pub fn next(self: *Self) T {
            if (self.spare) |spare| {
                const num = spare;
                self.spare = null;
                return num;
            }

            const u = self.prng.float(T);
            const v = self.prng.float(T);

            const r = std.math.sqrt(-2.0 * std.math.ln(u));
            const t = 2.0 * std.math.pi * v;

            const x = r * std.math.cos(t);
            const y = r * std.math.sin(t);

            const m = self.mu;
            const s = self.sigma;

            self.spare = m + s * x;
            return m + s * y;
        }
    };
}

fn writeNumberNTimesWithIncrementNoise(comptime T: type, writer: anytype, number: T, length: usize, inc: T, mu: T, sigma: T) !void {
    // Random number generator
    var prng = std.rand.DefaultPrng.init(blk: {
        var seed: u64 = undefined;
        try std.os.getrandom(std.mem.asBytes(&seed));
        break :blk seed;
    });
    const random = prng.random();
    var bm = BoxMullerIterator(T).init(random, mu, sigma);

    // Floating-point number size in bytes
    const sz = @typeInfo(T).Float.bits / 8;

    var i: usize = 0;
    var n = number;
    while (i < length) : (i += 1) {
        // Generate noise
        const noise = bm.next();

        // Convert floating-point number to bytes
        var bytes = @bitCast([sz]u8, n + noise);

        // Reverse bits because of endianness
        std.mem.reverse(u8, bytes[0..]);

        // Write bytes
        for (bytes) |byte| try writer.writeByte(byte);

        // Increment number
        n += inc;
    }
}

pub fn main() anyerror!void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();

    var allocator = arena.allocator();

    var args = try ArgumentParser.parseArgumentsAllocator(allocator);

    const output = args.output;

    var file = try std.fs.cwd().createFile(output, .{});
    defer file.close();

    const length = try std.fmt.parseInt(usize, args.length, 10);

    const mu_str = if (args.mu.len > 0) args.mu else "0.0";
    const sigma_str = if (args.sigma.len > 0) args.sigma else "0.0";
    const number_str = if (args.number.len > 0) args.number else "0.0";
    const increment_str = if (args.increment.len > 0) args.increment else "0.0";

    const w = file.writer();

    if (args.double_precision) {
        const mu = try std.fmt.parseFloat(f64, mu_str);
        const sigma = try std.fmt.parseFloat(f64, sigma_str);
        const number = try std.fmt.parseFloat(f64, number_str);
        const increment = try std.fmt.parseFloat(f64, increment_str);

        try writeNumberNTimesWithIncrementNoise(f64, w, number, length, increment, mu, sigma);
    } else {
        const mu = try std.fmt.parseFloat(f32, mu_str);
        const sigma = try std.fmt.parseFloat(f32, sigma_str);
        const number = try std.fmt.parseFloat(f32, number_str);
        const increment = try std.fmt.parseFloat(f32, increment_str);

        try writeNumberNTimesWithIncrementNoise(f32, w, number, length, increment, mu, sigma);
    }
}

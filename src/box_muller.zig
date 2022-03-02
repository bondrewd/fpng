const std = @import("std");

pub fn BoxMuller(comptime T: type) type {
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

        pub fn generate(self: *Self) T {
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

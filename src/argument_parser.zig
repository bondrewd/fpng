const argparse = @import("argparse");

pub const ArgumentParser = argparse.ArgumentParser(.{
    .app_name = "fpng",
    .app_description = "Floating-point number generator",
    .app_version = .{ .major = 0, .minor = 1, .patch = 0 },
}, &[_]argparse.AppOptionPositional{
    .{
        .option = .{
            .name = "double_precision",
            .short = "-d",
            .long = "--double-precision",
            .description = "Use f64 instead of f32 for generating time series",
        },
    },
    .{
        .option = .{
            .name = "number",
            .short = "-n",
            .long = "--number",
            .metavar = "N",
            .description = "Generate time series using N as initial value",
            .takes = 1,
            .default = &.{"0.0"},
        },
    },
    .{
        .option = .{
            .name = "increment",
            .short = "-i",
            .long = "--increment",
            .metavar = "N",
            .description = "Increment by N at each step",
            .takes = 1,
            .default = &.{"0.0"},
        },
    },
    .{
        .option = .{
            .name = "mu",
            .short = "-m",
            .long = "--mu",
            .metavar = "μ",
            .description = "Random noise mean value",
            .takes = 1,
            .default = &.{"0.0"},
        },
    },
    .{
        .option = .{
            .name = "sigma",
            .short = "-s",
            .long = "--sigma",
            .metavar = "σ",
            .description = "Random noise standard deviation",
            .takes = 1,
            .default = &.{"0.0"},
        },
    },
    .{
        .option = .{
            .name = "seed",
            .long = "--seed",
            .metavar = "N",
            .description = "Seed for generating random numbers",
            .takes = 1,
        },
    },
    .{
        .positional = .{
            .name = "length",
            .metavar = "LENGTH",
            .description = "Time series length",
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

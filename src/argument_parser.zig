const argparse = @import("argparse");

pub const ArgumentParser = argparse.ArgumentParser(.{
    .app_name = "fpng",
    .app_description = "Floating-point number generator.",
    .app_version = .{ .major = 0, .minor = 1, .patch = 0 },
}, &[_]argparse.AppOptionPositional{
    .{
        .option = .{
            .name = "double_precision",
            .short = "-d",
            .long = "--double-precision",
            .description = "Use f64 instead of f32 for generating the time series",
        },
    },
    .{
        .option = .{
            .name = "number",
            .short = "-n",
            .long = "--number",
            .metavar = "N",
            .description = "Generate time series using the number N (default: 0.0)",
            .takes = 1,
        },
    },
    .{
        .option = .{
            .name = "increment",
            .short = "-i",
            .long = "--increment",
            .metavar = "N",
            .description = "Increment at each step by N (default: 0.0)",
            .takes = 1,
        },
    },
    .{
        .option = .{
            .name = "mu",
            .short = "-m",
            .long = "--mu",
            .metavar = "N",
            .description = "Random noise mean value N (default: 0.0)",
            .takes = 1,
        },
    },
    .{
        .option = .{
            .name = "sigma",
            .short = "-s",
            .long = "--sigma",
            .metavar = "N",
            .description = "Random noise sigma value N (default: 0.0)",
            .takes = 1,
        },
    },
    .{
        .option = .{
            .name = "seed",
            .long = "--seed",
            .metavar = "N",
            .description = "Seed for generating random numbers (default: randomly selected)",
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

const std = @import("std");

// Ansi format
const reset = "\x1b[000m";
const bold = "\x1b[001m";
const red = "\x1b[091m";
const blue = "\x1b[094m";
const green = "\x1b[092m";
const yellow = "\x1b[093m";

pub fn parsing_error(comptime T: type, buf: []const u8) void {
    const stderr = std.io.getStdErr().writer();

    const type_name = @typeName(T);
    stderr.print(bold ++ red ++ "Error: " ++ reset ++ "failed parsing " ++ green ++ "{s}" ++ reset ++ " into " ++ green ++ "{s}" ++ reset ++ "\n", .{ buf, type_name }) catch unreachable;
}

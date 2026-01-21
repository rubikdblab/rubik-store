const std = @import("std");
const testing = std.testing;
const Tokenizer = @import("tokenizer.zig").Tokenizer;
const TokenizerResult = @import("tokenizer.zig").TokenizerResult;

test "test basic toml tokenization" {
    const tomlString = "[name]";

    var tokenizer = Tokenizer.init(tomlString);
    const result1 = try tokenizer.next();

    switch (result1) {
        .token => |t| {
            try testing.expectEqual("[", t.slice);
        },
        else => unreachable(),
    }
}

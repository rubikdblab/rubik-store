const std = @import("std");
const testing = std.testing;

const TOMLConfigManager = @import("toml_config_manager.zig");
const types = @import("types.zig");

test "storage config loads correctly" {
    var mgr = try TOMLConfigManager.init(
        testing.allocator,
        "test_data/config/test.toml",
    );

    const configManager = mgr.configManager();
    const val = configManager.getConfig(
        types.ConfigCategory.storage,
        types.StorageConfigKey.page_size,
    ) orelse {
        try testing.expect(false);
        return;
    };

    try testing.expectEqual(@as(i64, 4096), val.integer);
}

test "example print" {
    std.debug.print("Hello from the test!\n", .{});
}

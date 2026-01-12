const std = @import("std");
const types = @import("types.zig");
const ConfigManager = @import("interface.zig").ConfigManager;
const testing = std.testing;
const TOMLConfigManager = @import("toml_config_manager.zig").TOMLConfigManager;

test "storage config loads correctly" {
    const tomlConfigManager = try TOMLConfigManager.init(
        testing.allocator,
        "test_data/config/test.toml",
    );
    const cfgMgr = ConfigManager{
        .ctx = tomlConfigManager,
    };

    const storageCfg = cfgMgr.getConfig(types.StorageConfig);

    try testing.expectEqual(@as(i64, 4096), storageCfg.page_size);
}

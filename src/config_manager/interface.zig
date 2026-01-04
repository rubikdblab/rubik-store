const types = @import("types.zig");

pub const ConfigManager = struct {
    ctx: *anyopaque,
    getConfigFn: *const fn (ctx: *anyopaque, category: types.ConfigCategory, key: anytype) ?types.ConfigValue,

    pub fn getConfig(self: ConfigManager, category: types.ConfigCategory, key: anytype) ?types.ConfigValue {
        return self.getConfigFn(self.ctx, category, key);
    }
};

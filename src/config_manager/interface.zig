const types = @import("types.zig");

pub const ConfigManager = struct {
    ctx: *anyopaque,

    pub fn getConfig(self: ConfigManager, comptime ConfigType: type) !ConfigType {
        return self.ctx.getConfig(ConfigType);
    }
};

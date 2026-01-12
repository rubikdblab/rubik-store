const toml = @import("toml");
const std = @import("std");
const types = @import("types.zig");
const iface = @import("interface.zig");

/// TOMLConfigManager is an implementation for the ConfigManager interface.
pub const TOMLConfigManager = struct {
    allocator: std.mem.Allocator,
    path: []const u8,
    config: types.DBConfig,

    /// init initializes the configuration manager.
    /// It loads the configuration from the provided file path.
    pub fn init(allocator: std.mem.Allocator, path: []const u8) !TOMLConfigManager {
        var self = TOMLConfigManager{
            .allocator = allocator,
            .path = path,
            .config = std.mem.zeroes(types.DBConfig),
        };

        try self.loadFromFile();
        return self;
    }

    /// configManager returns the interface type - ConfigManager with implementation of TOMLConfigManager.
    pub fn configManager(self: *TOMLConfigManager) iface.ConfigManager {
        return .{
            .ctx = self,
            .getConfigFn = getConfig,
        };
    }

    /// getConfig is the implementation of the interface method required by the ConfigManager.
    fn getConfig(self: *TOMLConfigManager, comptime ConfigType: type) !ConfigType {
        if (ConfigType == types.StorageConfig) {
            return self.db_config.storageConfig;
        } else {
            @compileError("Unknown config type requested");
        }
    }

    /// loadFromFile reads the TOML configuration from the file and loads it in internal maps for vending.
    fn loadFromFile(self: *TOMLConfigManager) !void {
        var parser = toml.Parser(types.DBConfig).init(self.allocator);
        defer parser.deinit();

        var result = try parser.parseFile(self.path);
        defer result.deinit();

        self.db_config = result.value;
    }
};

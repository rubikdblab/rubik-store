const toml = @import("toml");
const std = @import("std");
const types = @import("types.zig");
const iface = @import("interface.zig");

const file_path = "config/prod.toml";

/// TOMLConfigManager is an implementation for the ConfigManager interface.
pub const TOMLConfigManager = struct {
    allocator: std.mem.Allocator,
    config: types.DBConfig,

    /// init initializes the configuration manager.
    /// It loads the configuration from the provided file path.
    pub fn init(allocator: std.mem.Allocator) !TOMLConfigManager {
        var self = TOMLConfigManager{
            .allocator = allocator,
            .config = types.DBConfig.init(),
        };

        try self.loadFromFile(file_path);
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
    fn getConfig(ptr: *anyopaque, category: types.ConfigCategory, key: anytype) ?types.ConfigValue {
        const self: *TOMLConfigManager = @ptrCast(@alignCast(ptr));

        return switch (category) {
            .storage => getFromMap(types.StorageConfigKey, self.config.storage.map, key),
        };
    }

    /// getFromMap is a utility method for fetching a config value from a given config map.
    fn getFromMap(
        comptime KeyEnum: type,
        map: std.EnumMap(KeyEnum, types.ConfigValue),
        key: anytype,
    ) ?types.ConfigValue {
        if (@TypeOf(key) != KeyEnum) {
            @panic("Invalid config key type for category");
        }
        return map.get(key);
    }

    /// loadFromFile reads the TOML configuration from the file and loads it in internal maps for vending.
    fn loadFromFile(self: *TOMLConfigManager, path: []const u8) !void {
        const data = try std.fs.cwd().readFileAlloc(
            self.allocator,
            path,
            64 * 1024,
        );
        defer self.allocator.free(data);

        var parser = toml.Parser.init(self.allocator);
        defer parser.deinit();

        const root = try parser.parse(data);

        if (root.get("storage")) |s| {
            self.parseStorage(s);
        }
    }

    /// parseStorage loads the configuration for category - storage.
    fn parseStorage(self: *TOMLConfigManager, v: toml.Value) void {
        if (v.get("page_size")) |ps| {
            self.config.storage.map.put(
                .page_size,
                .{ .integer = ps.integer },
            );
        }
    }
};

const toml = @import("toml");
const std = @import("std");
const types = @import("types.zig");
const iface = @import("interface.zig");

const file_path = "config/prod.toml";

pub const TOMLConfigManager = struct {
    allocator: std.mem.Allocator,
    config: types.DBConfig,

    pub fn init(allocator: std.mem.Allocator, path: []const u8) !TOMLConfigManager {
        var self = TOMLConfigManager{
            .allocator = allocator,
            .config = types.DBConfig.init(),
        };

        try self.loadFromFile(path);
        return self;
    }

    pub fn configManager(self: *TOMLConfigManager) iface.ConfigManager {
        return .{
            .ctx = self,
            .getConfigFn = getConfig,
        };
    }

    fn getConfig(ptr: *anyopaque, category: types.ConfigCategory, key: anytype) ?types.ConfigValue {
        const self: *TOMLConfigManager = @ptrCast(@alignCast(ptr));

        return switch (category) {
            .storage => getFromMap(types.StorageConfigKey, self.config.storage.map, key),
        };
    }

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

    fn parseStorage(self: *TOMLConfigManager, v: toml.Value) void {
        if (v.get("page_size")) |ps| {
            self.config.storage.map.put(
                .page_size,
                .{ .integer = ps.integer },
            );
        }
    }
};

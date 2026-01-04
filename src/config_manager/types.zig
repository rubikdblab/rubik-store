const std = @import("std");

/// DBConfig stores all the configurations available.
pub const DBConfig = struct {
    storage: StorageConfig,

    pub fn init() DBConfig {
        return .{
            .storage = StorageConfig.init(),
        };
    }
};

/// ConfigCategory represents all available types of configurations vended by the ConfigManager.
pub const ConfigCategory = enum {
    storage,
};

/// configValue is a tagged union that represents the values that can be stored/retrieved for a config.
pub const ConfigValue = union(enum) {
    integer: i64,
    boolean: bool,
    string: []const u8,

    pub fn getInt(self: ConfigValue) !64 {
        return switch (self) {
            .integer => |v| v,
            else => error.TypeMismatch,
        };
    }

    pub fn getBool(self: ConfigValue) !bool {
        return switch (self) {
            .boolean => |v| v,
            else => error.TypeMismatch,
        };
    }

    pub fn getString(self: ConfigValue) ![]const u8 {
        return switch (self) {
            .string => |v| v,
            else => error.TypeMismatch,
        };
    }
};

/// StorageConfig holds all storage related configurations.
pub const StorageConfig = struct {
    map: std.EnumMap(StorageConfigKey, ConfigValue),

    pub fn init() StorageConfig {
        return .{ .map = std.EnumMap(StorageConfigKey, ConfigValue){} };
    }
};

/// StorageConfigKey holds all possible configuration keys available to StorageConfig.
pub const StorageConfigKey = enum {
    page_size,
};

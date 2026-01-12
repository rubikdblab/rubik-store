const std = @import("std");

/// DBConfig stores all the configurations available.
pub const DBConfig = struct {
    storageConfig: StorageConfig,
};

/// StorageConfig holds all storage related configurations.
pub const StorageConfig = struct {
    page_size: i64,
};

pub const PageID = struct {
    segment_id: u32,
    page_no: u32,
};

pub const SegmentID = u23;

pub const SlotID = u16;

pub const RecordID = struct {
    page_id: PageID,
    slot_id: SlotID,
};

pub const PageSize = enum(u32) {
    size_4k = 4096,
    size_8k = 8192,
};

pub const SegmentKind = enum {
    table,
    index,
    metadata,
    wal,
};

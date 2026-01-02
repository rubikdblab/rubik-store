pub fn FileManagerInterface(comptime T: type) void {
    comptime {
        if (!@hasDecl(T, "readAt")) @compileError("FileManager must implement readAt");
        if (!@hasDecl(T, "writeAt")) @compileError("FileManager must implement writeAt");
        if (!@hasDecl(T, "sync")) @compileError("FileManager must implement sync");
    }
}

pub fn PageManagerInterface(comptime T: type) void {
    comptime {
        if (!@hasDecl(T, "readPage")) @compileError("PageManager must implement readPage");
        if (!@hasDecl(T, "writePage")) @compileError("PageManager must implement writePage");
    }
}

pub fn SpaceManagerInterface(comptime T: type) void {
    comptime {
        if (!@hasDecl(T, "allocatePage")) @compileError("SpaceManager must implement allocatePage");
        if (!@hasDecl(T, "freePage")) @compileError("SpaceManager must implement freePage");
    }
}

pub fn RecordManagerInterface(comptime T: type) void {
    comptime {
        if (!@hasDecl(T, "insert")) @compileError("RecordManager must implement insert");
        if (!@hasDecl(T, "read")) @compileError("RecordManager must implement read");
        if (!@hasDecl(T, "update")) @compileError("RecordManager must implement update");
        if (!@hasDecl(T, "delete")) @compileError("RecordManager must implement delete");
    }
}

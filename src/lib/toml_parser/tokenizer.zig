pub const Tokenizer = struct {
    input: []const u8,
    index: usize,
    row: usize,
    col: usize,
    currentState: TokenizerState,
    tokenBeginIndex: usize,

    pub fn init(input: []const u8) Tokenizer {
        return Tokenizer{
            .input = input,
            .index = 0,
            .row = 0,
            .col = 1,
            .currentState = TokenizerState.start,
            .tokenBeginIndex = 0,
        };
    }

    pub fn next(self: *Tokenizer) TokenizerError!TokenizerResult {
        while (true) {
            if (self.index >= self.input.len) {
                return .eof;
            }
            const c = self.input[self.index];
            const maybe = switch (self.currentState) {
                .start => try self.startStateHandler(c),
                .string => try self.stringStateHandler(c),
                .identifier => try self.identifierStateHandler(c),
                .symbol => try self.symbolStateHandler(c),
                .comment => try self.commentStateHandler(c),
                .number => try self.numberStateHandler(c),
            };
            if (maybe) |result| {
                return result;
            }
        }
    }

    fn advance(self: *Tokenizer) void {
        if (isNewline(self.input[self.index])) {
            self.row += 1;
            self.col = 1;
        } else {
            self.col += 1;
        }
        self.index += 1;
    }

    fn startStateHandler(self: *Tokenizer, c: u8) TokenizerError!?TokenizerResult {
        self.advance();
        if (isWhiteSpace(c) or isNewline(c)) {
            self.tokenBeginIndex = self.index;
        } else if (c == '#') {
            self.currentState = TokenizerState.comment;
            self.tokenBeginIndex = self.index;
        } else if (c == '"') {
            self.currentState = TokenizerState.string;
        } else if (isDigit(c) or c == '-') {
            self.currentState = TokenizerState.number;
        } else if (isIdentifier(c)) {
            self.currentState = TokenizerState.identifier;
        } else if (isSymbol(c)) {
            return self.emitAndReset(TokenKind.symbol);
        } else {
            return TokenizerError.UnrecognizedCharacter;
        }
        return null;
    }

    fn stringStateHandler(self: *Tokenizer, c: u8) TokenizerError!?TokenizerResult {
        self.advance();
        if (c == '"') {
            self.currentState = TokenizerState.start;
            self.tokenBeginIndex = self.index;
            return self.emitAndReset(TokenKind.string);
        }
        if (self.index == self.input.len - 1) {
            return TokenizerError.UnexpectedEOF;
        }
        return null;
    }

    fn identifierStateHandler(self: *Tokenizer, c: u8) TokenizerError!?TokenizerResult {
        self.advance();
        if (isIdentifier(c) or c == '.') {
            return null;
        } else if (isWhiteSpace(c) or isNewline(c) or c == '=') {
            self.currentState = TokenizerState.start;
            self.tokenBeginIndex = self.index;
            return self.emitAndReset(TokenKind.identifier);
        } else {
            return TokenizerError.UnexpectedCharacter;
        }
        return null;
    }

    fn symbolStateHandler(self: *Tokenizer, _: u8) TokenizerError!?TokenizerResult {
        self.advance();
        self.currentState = TokenizerState.start;
        self.tokenBeginIndex = self.index;
        return self.emitAndReset(TokenKind.symbol);
    }

    fn commentStateHandler(self: *Tokenizer, c: u8) TokenizerError!?TokenizerResult {
        self.advance();
        if (c == '\n' or c == '\r' or self.index == self.input.len - 1) {
            self.currentState = TokenizerState.start;
            self.tokenBeginIndex = self.index;
            return self.emitAndReset(TokenKind.comment);
        }
        return null;
    }

    fn numberStateHandler(self: *Tokenizer, c: u8) TokenizerError!?TokenizerResult {
        self.advance();
        if (isDigit(c)) {
            return null;
        } else if (c == '.') {
            for (self.tokenBeginIndex..self.index - 1) |i| {
                if (self.input[i] == '.') {
                    if (self.input[self.tokenBeginIndex] == '-') {
                        return TokenizerError.UnexpectedCharacter;
                    } else {
                        self.currentState = TokenizerState.identifier;
                    }
                }
            }
        } else if (isIdentifier(c)) {
            self.currentState = TokenizerState.identifier;
        } else if (isNewline(c) or isWhiteSpace(c)) {
            self.currentState = TokenizerState.start;
            self.tokenBeginIndex = self.index;
            return self.emitAndReset(TokenKind.number);
        }
        return null;
    }

    fn emitAndReset(self: *Tokenizer, kind: TokenKind) TokenizerResult {
        return TokenizerResult{
            .token = Token{
                .kind = kind,
                .slice = self.input[self.tokenBeginIndex..self.index],
                .row = self.row,
                .col = self.tokenBeginIndex,
            },
        };
    }
};

const TokenizerState = enum {
    start,
    string,
    number,
    identifier,
    symbol,
    comment,
};

pub const TokenizerResult = union(enum) {
    token: Token,
    eof,
};

pub const Token = struct {
    kind: TokenKind,
    slice: []const u8,
    row: usize,
    col: usize,
};

pub const TokenKind = enum {
    identifier,
    string,
    number,
    symbol,
    newline,
    comment,
};

pub const TokenizerError = error{
    UnrecognizedCharacter,
    UnexpectedCharacter,
    UnexpectedEOF,
};

fn isDigit(c: u8) bool {
    return c >= '0' and c <= '9';
}

fn isIdentifier(c: u8) bool {
    return (c >= 'a' and c <= 'z') or (c >= 'A' and c <= 'Z') or c == '_' or (c >= '0' and c <= '9');
}

fn isSymbol(c: u8) bool {
    return (c == '=' or c == '[' or c == ']' or c == '.' or c == ',');
}

fn isNewline(c: u8) bool {
    return (c == '\n');
}

fn isWhiteSpace(c: u8) bool {
    return (c == ' ' or c == '\t');
}

# Requirements Document

## Introduction

Replace fzf-lua with snacks.nvim picker while maintaining all existing functionality and improving user experience with modern features.

## Requirements

### REQ-001: Core File and Buffer Navigation

**User Story:** As a Neovim user, I want to search and navigate files and buffers with the same keybindings and behavior as my current fzf-lua setup, so that I can maintain my muscle memory and workflow.

#### Acceptance Criteria

1. WHEN I press `<Leader>ff` THEN the system SHALL open a file picker in the current working directory
2. WHEN I press `<Leader>fB` THEN the system SHALL show all open buffers with filename-first formatting
3. WHEN I press `<Leader>fo` THEN the system SHALL show recent files from the current working directory only
4. WHEN I press `<Leader>fl` or `<Leader>f<CR>` THEN the system SHALL resume the last search with the previous pattern
5. WHEN I press `,` (localleader) THEN the system SHALL show recent files and buffers from current session
6. WHEN I press `<Leader>fXa` THEN the system SHALL show Neovim config files from `stdpath("config")`

---

### REQ-002: Live Grep and Search Functionality

**User Story:** As a developer, I want to search text across files with live grep and support for visual selections, so that I can quickly find code and text patterns.

#### Acceptance Criteria

1. WHEN I press `<Leader>fg` THEN the system SHALL open live grep in the current working directory
2. WHEN I press `<Leader>fs` THEN the system SHALL open static grep search
3. WHEN I select text visually and press `<Leader>fg` THEN the system SHALL pre-populate the grep search with the selected text
4. WHEN I press `<Leader>fc` THEN the system SHALL search for the word under cursor across all files
5. WHEN I press `<Leader>fb` THEN the system SHALL search within the current buffer only
6. WHEN I press `<Leader>f/` THEN the system SHALL perform live grep within the current buffer
7. IF ripgrep is not available THEN the system SHALL show an appropriate message or fallback

---

### REQ-003: Git Integration

**User Story:** As a Git user, I want to search and navigate Git-related information (branches, commits, status), so that I can efficiently work with version control.

#### Acceptance Criteria

1. WHEN I press `<Leader>gfb` THEN the system SHALL show Git branches with the ability to switch branches
2. WHEN I press `<Leader>gfc` THEN the system SHALL show repository-wide Git commits
3. WHEN I press `<Leader>gfC` THEN the system SHALL show Git commits for the current file only
4. WHEN I press `<Leader>gfs` THEN the system SHALL show Git status with changed files
5. WHEN Git is not available in the current directory THEN the system SHALL show an appropriate message
6. WHEN I select a Git branch THEN the system SHALL checkout that branch (with confirmation if needed)
7. WHEN I select a Git commit THEN the system SHALL show the commit diff in preview

---

### REQ-004: LSP Integration

**User Story:** As a developer using LSP, I want to navigate code definitions, references, and symbols with the same keybindings, so that I can maintain my code navigation workflow.

#### Acceptance Criteria

1. WHEN I press `gd` THEN the system SHALL show LSP definitions and jump if only one result
2. WHEN I press `grr` THEN the system SHALL show LSP references
3. WHEN I press `gri` THEN the system SHALL show LSP implementations
4. WHEN I press `gy` THEN the system SHALL show LSP type definitions
5. WHEN I press `<Leader>ls` THEN the system SHALL show document symbols
6. WHEN I press `<Leader>lS` or `<Leader>lG` THEN the system SHALL show workspace symbols
7. WHEN I press `<Leader>lD` THEN the system SHALL show document diagnostics
8. WHEN LSP is not attached to the buffer THEN the system SHALL show an appropriate message

---

### REQ-005: Utility Pickers

**User Story:** As a Neovim user, I want to access various utility pickers (quickfix, jumps, marks, registers, etc.), so that I can efficiently navigate and manage Neovim state.

#### Acceptance Criteria

1. WHEN I press `<Leader>fq` THEN the system SHALL show the quickfix list
2. WHEN I press `<Leader>fj` THEN the system SHALL show the jumplist
3. WHEN I press `<Leader>f'` THEN the system SHALL show marks
4. WHEN I press `<Leader>fr` THEN the system SHALL show registers with preview
5. WHEN I press `<Leader>f;` THEN the system SHALL show command history
6. WHEN I press `<Leader>f:` THEN the system SHALL show available commands
7. WHEN I press `<Leader>fh` THEN the system SHALL show help tags
8. WHEN I press `<Leader>fk` THEN the system SHALL show keymaps
9. WHEN I press `<Leader>fm` THEN the system SHALL show man pages
10. WHEN I press `<Leader>f.` THEN the system SHALL open the main picker selector

---

### REQ-006: Window Configuration and UI

**User Story:** As a user, I want the picker windows to have consistent sizing, borders, and preview behavior similar to my current fzf-lua setup, so that I have a familiar and comfortable visual experience.

#### Acceptance Criteria

1. WHEN any picker opens THEN the window SHALL be 85% width and 95% height
2. WHEN a picker has a preview THEN the preview SHALL show on the right at 45% width OR bottom at 40% height depending on window width
3. WHEN the window width is less than 240 columns THEN the layout SHALL use vertical (preview on bottom)
4. WHEN the window width is 240+ columns THEN the layout SHALL use horizontal (preview on right)
5. WHEN a picker opens THEN it SHALL use single borders
6. WHEN a file has syntax highlighting THEN the preview SHALL show highlighted content
7. WHEN the preview content is too large THEN it SHALL show the first 50 lines by default

---

### REQ-007: Custom Keybindings Within Picker

**User Story:** As a power user, I want custom keybindings within the picker that match my fzf-lua configuration, so that I can navigate and act on results efficiently.

#### Acceptance Criteria

1. WHEN I press `Ctrl-q` in the picker THEN it SHALL select all items and confirm
2. WHEN I press `Ctrl-u` THEN it SHALL scroll half-page up
3. WHEN I press `Ctrl-d` THEN it SHALL scroll half-page down
4. WHEN I press `Ctrl-f` THEN it SHALL scroll preview down
5. WHEN I press `Ctrl-b` THEN it SHALL scroll preview up
6. WHEN I press `Tab` THEN it SHALL toggle selection and move down
7. WHEN I press `Shift-Tab` THEN it SHALL toggle selection and move up
8. WHEN I press `Ctrl-o` THEN it SHALL open the selected file in a specific window (window picker action)

---

### REQ-008: Vim UI Select Replacement

**User Story:** As a Neovim user, I want `vim.ui.select` to use the snacks picker instead of the default UI, so that I have a consistent interface for all selection prompts.

#### Acceptance Criteria

1. WHEN any plugin calls `vim.ui.select` THEN it SHALL use snacks picker
2. WHEN a selection prompt appears THEN it SHALL have the same look and feel as other pickers
3. WHEN I cancel the selection THEN it SHALL return nil to the calling function
4. WHEN I confirm a selection THEN it SHALL return the selected item to the calling function

---

### REQ-009: Custom Pickers Migration

**User Story:** As a user with custom pickers (folders, zoxide, etc.), I want these pickers to work with snacks.nvim or have suitable replacements, so that I don't lose custom functionality.

#### Acceptance Criteria

1. WHEN zoxide is installed and I need to navigate directories THEN the system SHALL provide a zoxide picker (snacks has built-in `Snacks.picker.zoxide()`)
2. WHEN I need to browse folders THEN the system SHALL provide an explorer or folder picker with preview
3. WHEN I need enhanced grep with custom options THEN the system SHALL support grep with configurable options
4. IF a custom picker cannot be directly migrated THEN the system SHALL provide equivalent functionality through snacks sources or custom implementation

---

### REQ-010: Performance and Responsiveness

**User Story:** As a user working with large codebases, I want the picker to remain responsive and fast, so that my workflow is not interrupted by lag.

#### Acceptance Criteria

1. WHEN searching in directories with 10,000+ files THEN the picker SHALL show results within 500ms
2. WHEN live grep is active THEN results SHALL update within 200ms of typing
3. WHEN the matcher is processing THEN it SHALL not block the UI
4. WHEN the finder is running THEN it SHALL show progress indicators
5. WHEN I type quickly THEN the search SHALL debounce appropriately without missing input

---

### REQ-011: Plugin Registration and Lazy Loading

**User Story:** As a user with a lazy-loaded plugin setup, I want snacks.nvim picker to load efficiently and not impact startup time, so that Neovim starts quickly.

#### Acceptance Criteria

1. WHEN Neovim starts THEN snacks.nvim picker SHALL not load until first use
2. WHEN the first picker is opened THEN subsequent pickers SHALL open instantly
3. WHEN fzf-lua plugin is removed THEN there SHALL be no errors or warnings
4. WHEN plugins.lua is loaded THEN snacks.nvim SHALL be properly registered

---

### REQ-012: Migration Strategy

**User Story:** As a user migrating from fzf-lua, I want a clean migration path that implements basic features first, then adds enhancements, so that I can use the picker immediately.

#### Acceptance Criteria

1. WHEN the migration is complete THEN the old fzf-lua config files SHALL be removed (no archiving)
2. WHEN basic features are implemented THEN all core file/buffer/grep/git/LSP pickers SHALL work
3. WHEN basic features are stable THEN new custom pickers SHALL be added (explorer, projects, undo, zoxide)
4. WHEN a new custom picker is added THEN it SHALL be documented with keybindings
5. IF fzf-lua needs to be restored THEN the user can revert via git history (no rollback plan needed)
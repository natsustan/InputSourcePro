import AppKit
import AXSwift

enum AppTerminalKind: String {
    case codex
    case cursor
    case antigravity
    case opencode
    case vscode

    var bundleIdentifier: String {
        switch self {
        case .codex:
            return "com.openai.codex"
        case .cursor:
            return "com.todesktop.230313mzl4w4u92"
        case .antigravity:
            return "com.google.antigravity"
        case .opencode:
            return "ai.opencode.desktop"
        case .vscode:
            return "com.microsoft.VSCode"
        }
    }

    var appKindIdSuffix: String {
        switch self {
        case .codex:
            return "codex_terminal"
        case .cursor:
            return "cursor_terminal"
        case .antigravity:
            return "antigravity_terminal"
        case .opencode:
            return "opencode_terminal"
        case .vscode:
            return "vscode_terminal"
        }
    }

    static func from(bundleIdentifier: String?) -> AppTerminalKind? {
        guard let bundleIdentifier else { return nil }
        return allCases.first { $0.bundleIdentifier == bundleIdentifier }
    }
}

extension AppTerminalKind: CaseIterable {}

enum AppTerminalDetector {
    private static let maxAncestorDepth = 16

    // xterm.js prefixes every class on the helper textarea, its container, and
    // its render layers with `xterm` (e.g. `xterm-helper-textarea`,
    // `xterm-screen`, `xterm-viewport`, `xterm-rows`, `xterm-cursor-layer`).
    // Matching this prefix on AXDOMClassList is both specific to xterm.js and
    // resilient to version changes. We deliberately avoid broad keywords like
    // `terminal` / `console` / `shell`, because Codex labels other panes with
    // those words, which caused the terminal input source to be applied to the
    // chat composer as well.
    private static let xtermClassPrefix = "xterm"

    static func isTerminalFocused(focusedElement: UIElement?) -> Bool {
        guard let focusedElement else { return false }
        return hasXtermAncestor(focusedElement)
    }

    private static func hasXtermAncestor(_ focusedElement: UIElement) -> Bool {
        var element: UIElement? = focusedElement

        for _ in 0 ..< maxAncestorDepth {
            guard let current = element else { return false }

            if elementHasXtermClass(current) {
                return true
            }

            element = try? current.attribute(.parent)
        }

        return false
    }

    private static func elementHasXtermClass(_ element: UIElement) -> Bool {
        return element.domClassList().contains { $0.hasPrefix(xtermClassPrefix) }
    }
}

import Foundation

/// Translate display-oriented mathematical notation into short, understandable spoken phrases.
/// The lesson scripts deliberately use words already; this covers any newly added equation text.
enum SpeechText {
    static func readable(_ input: String) -> String {
        var text = input
        let replacements: [(String, String)] = [
            ("ω_n", "omega naught"), ("ω_d", "omega d"),
            ("ω", "omega"), ("ζ", "zeta"), ("θ", "theta"), ("α", "alpha"),
            ("Σ", "sum of"), ("∑", "sum of"), ("∫", "integral of"),
            ("ẍ", "x double dot"), ("ẋ", "x dot"),
            ("\\ddot{x}", "x double dot"), ("\\dot{x}", "x dot"),
            ("I_G", "I sub G"), ("I_O", "I sub O"),
            ("F_x", "F sub x"), ("F_y", "F sub y"),
            ("v_G", "v sub G"), ("m/s²", "meters per second squared"),
            ("rad/s", "radians per second"), ("N·m", "newton meters"),
            ("²", " squared"), ("√", "square root of "),
            ("→", "leads to"), ("≈", "approximately equals")
        ]
        for (source, target) in replacements {
            text = text.replacingOccurrences(of: source, with: target)
        }
        return text
    }
}

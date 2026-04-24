/// Maps exercise names to Eppley machine image asset paths.
/// Uses keyword matching — most specific keywords first.
class MachineImages {
  static const _hs = 'assets/machine/HammerStrength/';
  static const _lf = 'assets/machine/LifeFitness/';
  static const _pr = 'assets/machine/Precor/';

  /// Ordered keyword → asset path. Earlier entries take priority.
  static const List<(String, String)> _rules = [
    // ── Chest ─────────────────────────────────────────────────────────────
    ('incline press',        '${_hs}Iso-Lateral Incline Press.png'),
    ('incline dumbbell',     '${_hs}Iso-Lateral Incline Press.png'),
    ('incline smith',        '${_hs}Iso-Lateral Incline Press.png'),
    ('bench press',          '${_hs}Iso-Lateral Horizonal Bench Press.png'),
    ('flat barbell',         '${_hs}Iso-Lateral Horizonal Bench Press.png'),
    ('converging chest',     '${_pr}Converging Chest Press.png'),
    ('chest press',          '${_pr}Converging Chest Press.png'),
    ('wide chest',           '${_hs}Iso-Lateral Wide Chest.png'),
    ('cable fly',            '${_pr}Rear Delt Pec Fly.png'),
    ('chest fly',            '${_pr}Rear Delt Pec Fly.png'),
    ('rear delt',            '${_pr}Rear Delt Pec Fly.png'),
    // ── Shoulder ──────────────────────────────────────────────────────────
    ('converging shoulder',  '${_pr}Converging Shoulder Press.png'),
    ('shoulder press',       '${_hs}Iso-Lateral Shoulder Press.png'),
    ('overhead press',       '${_hs}Iso-Lateral Shoulder Press.png'),
    ('lateral raise',        '${_lf}Insignia Series Lateral Raise.png'),
    // ── Back ──────────────────────────────────────────────────────────────
    ('lat pulldown',         '${_lf}Axiom Series Lat Pulldown.png'),
    ('lat pull',             '${_lf}Axiom Series Lat Pulldown.png'),
    ('pulldown',             '${_lf}Insignia Series Pulldown.png'),
    ('high row',             '${_hs}Iso-Lateral High Row.png'),
    ('low row',              '${_hs}Iso-Lateral Low Row.png'),
    ('seated cable row',     '${_hs}Iso-Lateral Low Row.png'),
    ('cable row',            '${_hs}Iso-Lateral Low Row.png'),
    ('iso-lateral row',      '${_hs}Iso-Lateral Row.png'),
    // ── Arms ──────────────────────────────────────────────────────────────
    ('bicep curl',           '${_lf}Insignia Series Biceps Curl.png'),
    ('biceps curl',          '${_lf}Insignia Series Biceps Curl.png'),
    ('hammer curl',          '${_lf}Insignia Series Biceps Curl.png'),
    ('tricep pushdown',      '${_pr}Triceps Extension.png'),
    ('tricep extension',     '${_pr}Triceps Extension.png'),
    ('overhead tricep',      '${_pr}Triceps Extension.png'),
    // ── Legs ──────────────────────────────────────────────────────────────
    ('seated leg curl',      '${_pr}Seated Leg Curl.png'),
    ('prone leg curl',       '${_pr}Prone Leg Curl.png'),
    ('kneeling leg curl',    '${_hs}Iso-Lateral Kneeling Leg Curl.png'),
    ('leg curl',             '${_lf}Axiom Series Leg Curl.png'),
    ('leg extension',        '${_lf}Axiom Series Leg Extension.png'),
    ('leg press',            '${_lf}Axiom Series Leg Extension.png'),
    ('inner thigh',          '${_pr}Inner Thigh.png'),
    ('outer thigh',          '${_pr}Outer Thigh.png'),
    ('hip abductor',         '${_lf}Axiom Series Hip Abductor Adductor.png'),
    ('hip adductor',         '${_lf}Axiom Series Hip Abductor Adductor.png'),
  ];

  /// Returns the asset path for the exercise, or null if no match found.
  static String? pathFor(String exerciseName) {
    final lower = exerciseName.toLowerCase();
    for (final (keyword, path) in _rules) {
      if (lower.contains(keyword)) return path;
    }
    return null;
  }

  /// True if this exercise has a machine image at Eppley.
  static bool has(String exerciseName) => pathFor(exerciseName) != null;
}

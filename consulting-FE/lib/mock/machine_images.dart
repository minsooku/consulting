/// Resolves machine image asset paths.
///
/// Primary lookup: use the `machine` filename stored in [ChecklistItem.machine]
/// (e.g. "Converging Chest Press.png") and find which subfolder it lives in.
///
/// Fallback: keyword matching on the exercise name for cases where `machine`
/// is null (e.g. free-weight exercises without a machine).
class MachineImages {
  static const _hs = 'assets/machine/HammerStrength/';
  static const _lf = 'assets/machine/LifeFitness/';
  static const _pr = 'assets/machine/Precor/';

  // ── Filename → folder lookup ───────────────────────────────────────────────
  // Key: exact PNG filename (case-sensitive, matches assets/machine/*/*)
  static const Map<String, String> _byFilename = {
    // HammerStrength
    'Iso-Lateral High Row.png':              '${_hs}Iso-Lateral High Row.png',
    'Iso-Lateral Horizonal Bench Press.png': '${_hs}Iso-Lateral Horizonal Bench Press.png',
    'Iso-Lateral Incline Press.png':         '${_hs}Iso-Lateral Incline Press.png',
    'Iso-Lateral Kneeling Leg Curl.png':     '${_hs}Iso-Lateral Kneeling Leg Curl.png',
    'Iso-Lateral Low Row.png':               '${_hs}Iso-Lateral Low Row.png',
    'Iso-Lateral Row.png':                   '${_hs}Iso-Lateral Row.png',
    'Iso-Lateral Shoulder Press.png':        '${_hs}Iso-Lateral Shoulder Press.png',
    'Iso-Lateral Wide Chest.png':            '${_hs}Iso-Lateral Wide Chest.png',

    // LifeFitness
    'Axiom Series Hip Abductor Adductor.png':  '${_lf}Axiom Series Hip Abductor Adductor.png',
    'Axiom Series Lat Pulldown.png':            '${_lf}Axiom Series Lat Pulldown.png',
    'Axiom Series Leg Curl.png':                '${_lf}Axiom Series Leg Curl.png',
    'Axiom Series Leg Extension.png':           '${_lf}Axiom Series Leg Extension.png',
    'Axiom Series Leg Extension_Leg Curl.png':  '${_lf}Axiom Series Leg Extension_Leg Curl.png',
    'Axiom Series Shoulder Press.png':          '${_lf}Axiom Series Shoulder Press.png',
    'Insignia Series Biceps Curl.png':          '${_lf}Insignia Series Biceps Curl.png',
    'Insignia Series Lateral Raise.png':        '${_lf}Insignia Series Lateral Raise.png',
    'Insignia Series Pulldown.png':             '${_lf}Insignia Series Pulldown.png',

    // Precor
    'Biceps Curl.png':              '${_pr}Biceps Curl.png',
    'Converging Chest Press.png':   '${_pr}Converging Chest Press.png',
    'Converging Shoulder Press.png':'${_pr}Converging Shoulder Press.png',
    'Inner Thigh.png':              '${_pr}Inner Thigh.png',
    'Leg Extension.png':            '${_pr}Leg Extension.png',
    'Outer Thigh.png':              '${_pr}Outer Thigh.png',
    'Prone Leg Curl.png':           '${_pr}Prone Leg Curl.png',
    'Rear Delt Pec Fly.png':        '${_pr}Rear Delt Pec Fly.png',
    'Seated Leg Curl.png':          '${_pr}Seated Leg Curl.png',
    'Triceps Extension.png':        '${_pr}Triceps Extension.png',
  };

  // ── Keyword fallback (for exercises without a machine field) ──────────────
  static const List<(String, String)> _keywords = [
    ('incline press',        '${_hs}Iso-Lateral Incline Press.png'),
    ('incline dumbbell',     '${_hs}Iso-Lateral Incline Press.png'),
    ('bench press',          '${_hs}Iso-Lateral Horizonal Bench Press.png'),
    ('converging chest',     '${_pr}Converging Chest Press.png'),
    ('chest press',          '${_pr}Converging Chest Press.png'),
    ('wide chest',           '${_hs}Iso-Lateral Wide Chest.png'),
    ('cable fly',            '${_pr}Rear Delt Pec Fly.png'),
    ('chest fly',            '${_pr}Rear Delt Pec Fly.png'),
    ('rear delt',            '${_pr}Rear Delt Pec Fly.png'),
    ('converging shoulder',  '${_pr}Converging Shoulder Press.png'),
    ('shoulder press',       '${_hs}Iso-Lateral Shoulder Press.png'),
    ('overhead press',       '${_hs}Iso-Lateral Shoulder Press.png'),
    ('lateral raise',        '${_lf}Insignia Series Lateral Raise.png'),
    ('lat pulldown',         '${_lf}Axiom Series Lat Pulldown.png'),
    ('pulldown',             '${_lf}Insignia Series Pulldown.png'),
    ('high row',             '${_hs}Iso-Lateral High Row.png'),
    ('low row',              '${_hs}Iso-Lateral Low Row.png'),
    ('seated cable row',     '${_hs}Iso-Lateral Low Row.png'),
    ('bicep curl',           '${_lf}Insignia Series Biceps Curl.png'),
    ('biceps curl',          '${_lf}Insignia Series Biceps Curl.png'),
    ('tricep pushdown',      '${_pr}Triceps Extension.png'),
    ('tricep extension',     '${_pr}Triceps Extension.png'),
    ('leg extension',        '${_lf}Axiom Series Leg Extension.png'),
    ('leg curl',             '${_lf}Axiom Series Leg Curl.png'),
    ('seated leg curl',      '${_pr}Seated Leg Curl.png'),
    ('inner thigh',          '${_pr}Inner Thigh.png'),
    ('outer thigh',          '${_pr}Outer Thigh.png'),
    ('hip abductor',         '${_lf}Axiom Series Hip Abductor Adductor.png'),
    ('hip adductor',         '${_lf}Axiom Series Hip Abductor Adductor.png'),
  ];

  /// Resolve asset path from [machine] filename first; fall back to keyword
  /// matching on [exerciseName]. Returns null when no match is found.
  static String? resolve({String? machine, String? exerciseName}) {
    if (machine != null) {
      final path = _byFilename[machine];
      if (path != null) return path;
    }
    if (exerciseName != null) {
      final lower = exerciseName.toLowerCase();
      for (final (keyword, path) in _keywords) {
        if (lower.contains(keyword)) return path;
      }
    }
    return null;
  }

  /// Shorthand: resolve by exercise name only (keyword fallback).
  static String? pathFor(String exerciseName) =>
      resolve(exerciseName: exerciseName);
}

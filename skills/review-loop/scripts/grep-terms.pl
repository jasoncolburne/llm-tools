#!/usr/bin/env perl
# grep-terms — decoration- and wrap-tolerant phrase search over Markdown.
#
# Markdown emphasis/code markers (* _ ` ~) sit at word boundaries, so a plain
# grep for a multi-word term misses its decorated forms:  "retry budget"  does
# not match  "retry **`budget`**".  Line-wrapping hides them the same way.  This
# tool widens each whitespace gap in a term so it also matches the marker-padded
# and line-wrapped forms, then reports file:line like grep.  Each word's initial
# letter is also matched in either case (so "retry" finds a sentence-start
# "Retry" too) without going fully case-insensitive.
#
# Direct use (literal phrases; the reason this exists — one-shot straggler sweeps):
#   grep-terms.pl [-i] [-w] PHRASE [PHRASE ...] [-- PATH ...]
#     grep-terms.pl "retry budget" "rate limit"
#   Paths default to every tracked *.md; pass files/dirs to narrow.
#
# Lint use (ERE patterns from a file; report only the forms a same-line grep
# misses, so it complements — never double-reports — the line-based pass):
#   grep-terms.pl --regex --novel -f PATTERNS -F FILES
#
# Attributed use (--label --first; verify many separate phrases in one pass):
#   grep-terms.pl --label --first -f QUOTES -- FILE
#     3<TAB>path/to/file.md:4285: embodiments a cache **layer** exists as ...
#   --label prefixes each hit with the pattern's 1-based number, which is its line in
#   QUOTES, so a caller checking N quotes can tell which one matched and where.
#   Without it, a many-pattern sweep reports hits it cannot attribute. --first stops at
#   the first hit per pattern, which is what an existence check wants.
#
# Exit 0 if any match, 1 if none (grep-like), 2 on a usage error.

use strict;
use warnings;
use utf8;
use open qw(:std :encoding(UTF-8));
use Encode qw(decode_utf8);
use Getopt::Long qw(:config bundling no_ignore_case);

# Split trailing paths off at the first "--" BEFORE GetOptions (which would
# otherwise consume the separator itself). Everything after "--" is a path.
my @paths;
for my $i (0 .. $#ARGV) {
    if ($ARGV[$i] eq '--') {
        @paths = @ARGV[$i + 1 .. $#ARGV];
        @ARGV  = @ARGV[0 .. $i - 1];
        last;
    }
}

sub usage {
    print <<'EOF';
grep-terms — decoration- and wrap-tolerant phrase search over Markdown.

Finds a phrase through the forms plain grep misses: **bold**/`code`/_em_/~strike~ markers at word
boundaries, line wraps (including inside "> " blockquotes), and sentence-case first letters.

Usage:
  grep-terms.pl [-i] [-w] PHRASE [PHRASE ...] [-- PATH ...]
  grep-terms.pl --regex --novel -f PATTERNS -F FILES     (lint use)

Flags:
  -i          fully case-insensitive (NOTE: default widening is first-letter only — an ALL-CAPS
              word like "LIVE" or "STATES" needs -i to match its lowercase form)
  -w          word-ish boundaries (use for short terms: "TTL", "seal" — avoids substring hits)
  -r, --regex treat tokens as ERE instead of literals
  --novel     report only decorated/wrapped hits a same-line grep would miss
  --label     prefix each hit with "N<TAB>", N being the 1-based pattern number (the
              line number in -f FILE) — lets one sweep of many patterns be attributed
  --first     stop after the first hit for each pattern (existence and where, not every site)
  --plain     strip Markdown emphasis from the reported line (**bold**, `code`, _em_, ~strike~
              at word boundaries; snake_case underscores are left alone) — for a programmatic
              caller comparing the reported text against an undecorated copy
  -f FILE     read patterns from FILE, one per line
  -F FILE     read the file list from FILE, one per line

Paths after "--" default to every git-tracked *.md; files/dirs/globs narrow it (untracked dirs are
walked). A zero-file resolution is a hard error, never a clean sweep — in zsh remember $VAR does not
word-split; use ${=VAR} or list paths explicitly.

Exit: 0 = matches, 1 = none, 2 = usage error. Output is grep-style file:line with the full source
line(s), whitespace-collapsed. Full documentation in this script's header comment.
EOF
    exit 0;
}

my %o;
GetOptions(\%o, 'i', 'w', 'regex|r', 'novel', 'label', 'first', 'plain', 'f=s', 'F=s',
           'help|h' => \&usage) or exit 2;

# --- patterns: from -f FILE (one per line) and/or the remaining positional args ---
my @phrases;
if ($o{f}) {
    open my $h, '<', $o{f} or die "grep-terms: cannot read $o{f}: $!\n";
    push @phrases, grep { length } map { chomp; $_ } <$h>;
    close $h;
}
# Command-line args arrive as raw BYTES; file contents are read as CHARACTERS (the
# `use open` layer above). Matching an undecoded byte-string pattern against a decoded
# subject can never hit, so any phrase containing a non-ASCII character — "≥ 2",
# "(MIN − 2)/4", an arrow, a ★ — returned ZERO SILENTLY, which reads as "clean".
# Decode the phrases only: paths and -f/-F filenames stay bytes, which is what open()
# and -f want. Phrases from -f are already decoded by the layer.
push @phrases, map { decode_utf8($_) } @ARGV;
die "grep-terms: no phrases (give them positionally or via -f)\n" unless @phrases;

# --- files: from -F FILE, else the given paths (dirs/globs expanded via git), else all tracked *.md ---
my @files;
if ($o{F}) {
    open my $h, '<', $o{F} or die "grep-terms: cannot read $o{F}: $!\n";
    @files = grep { length } map { chomp; $_ } <$h>;
    close $h;
} elsif (@paths) {
    for my $p (@paths) {
        if    (-f $p) { push @files, $p; }
        elsif (-d $p) {
            # A directory of UNTRACKED files (e.g. a scratch dir) expands to nothing via git —
            # fall back to a filesystem walk so the sweep searches what the caller named.
            my @g = grep { length } split /\n/, `git ls-files -- '$p/**/*.md' '$p/*.md' 2>/dev/null`;
            @g = grep { length } split /\n/, `find '$p' -type f -name '*.md' 2>/dev/null` unless @g;
            push @files, @g;
        }
        else          { push @files, split /\n/, `git ls-files -- '$p' 2>/dev/null`; }
    }
} else {
    @files = split /\n/, `git ls-files -- '*.md' 2>/dev/null`;
}
@files = grep { length } @files;

# An EMPTY file list must never look like a clean sweep. A nonexistent path, an unsplit
# shell variable of paths, or a directory whose files are untracked all resolved to zero
# files and exited 1 with no output — indistinguishable from "searched everything, found
# nothing". Same silent-wrong-clean class as the byte/char defect. Fail as a usage error.
die "grep-terms: no files to search"
  . (@paths ? " (paths resolved to nothing: @paths)" : "")
  . " — a zero-file sweep is not a clean sweep\n"
  unless @files;

# --- build a marker+wrap-tolerant regex per phrase ---
my $MK  = '[*_`~]*';              # an optional run of emphasis/code markers
# The gap must also cross a BLOCKQUOTE continuation prefix ("> ", nested "> > "): a phrase that
# wraps inside a blockquote puts "\n> " between two of its words, and a gap of bare \s+ returned
# ZERO SILENTLY — the third silent-wrong-clean defect, and it bites hardest on exactly the material
# that lives in blockquotes (normative rules, constants). Mid-line "a > b" now also matches "a b";
# over-reporting is the correct failure direction for a sweep tool.
my $GAP = $MK . '(?:\s+(?:>[ \t]*)*)+' . $MK;   # inter-token gap: markers, whitespace (+ "> " prefixes), markers
sub build {
    my ($p) = @_;
    my @tok = grep { length } split /\s+/, $p;   # only literal-space phrases get widened
    return undef unless @tok;
    # --regex keeps ERE tokens; default is literal. For literal tokens, also allow
    # markers at punctuation boundaries INSIDE a token: the source writes
    # "**retry-budget**:" and a quoted copy reads "retry-budget:", where the closing "**"
    # falls between a word character and a colon. Marker tolerance living only in the
    # inter-token gap missed every such span and reported it as absent. Splitting each
    # token at word/non-word transitions and rejoining with the marker class covers it.
    # Over-reporting is the correct failure direction for a sweep tool.
    @tok = map {
        $o{regex} ? $_
                  : join($MK, map { quotemeta }
                              split /(?<=\w)(?=\W)|(?<=\W)(?=\w)/, $_)
    } @tok;
    # First-letter case variant per word: match either case at each word's initial
    # letter, so "rate limit" also finds "Rate limit" / "Rate Limit" (sentence
    # starts, headings, bold labels) without going fully case-insensitive.
    s/^([A-Za-z])/'[' . lc($1) . uc($1) . ']'/e for @tok;
    my $re = $MK . join($GAP, @tok);                  # allow leading markers
    $re = '(?<!\w)' . $re . '(?!\w)' if $o{w};        # -w: word-ish boundaries
    return $o{i} ? qr/$re/i : qr/$re/;
}
# Keep each regex paired with its 1-based position in @phrases, so --label can say
# which pattern a hit belongs to. A sweep of many patterns is otherwise unattributable,
# which is what a caller verifying N separate quotes needs.
my @res;
for my $i (0 .. $#phrases) {
    my $re = build($phrases[$i]);
    push @res, [ $i + 1, $re ] if defined $re;
}
exit 1 unless @res;

# --- search (slurp each file so \s+ can cross newlines) ---
my $hits = 0;
my %found;   # pattern number -> seen, for --first
for my $file (@files) {
    next unless -f $file && !-B $file;
    open my $fh, '<', $file or next;
    local $/; my $c = <$fh>; close $fh;
    for my $pair (@res) {
        my ($pnum, $re) = @$pair;
        next if $o{first} && $found{$pnum};
        # pos() belongs to $c, not to the regex. A --first "last" leaves it parked at the
        # previous pattern's match, and the next pattern then resumes from there and can
        # never see an earlier occurrence — a silent under-report that grows with the
        # number of patterns. Every pattern searches the whole file.
        pos($c) = 0;
        while ($c =~ /$re/g) {
            my ($off, $m) = ($-[0], $&);
            # --novel: skip a plain same-line hit (no newline, no marker) — the
            # caller's line-based pass already reports those.
            next if $o{novel} && $m !~ /\n/ && $m !~ /[*_`~]/;
            my $line = 1 + (substr($c, 0, $off) =~ tr/\n//);
            # Show the full source line(s) the match sits on (grep-style context), not
            # just the matched term — a bare-term report forces a second grep to tell,
            # say, the "band" constant from "out-of-band". A wrap-spanning match shows
            # both lines, whitespace-collapsed to one.
            my $ls = rindex($c, "\n", $off) + 1;
            my $le = index($c, "\n", $+[0]);
            $le = length($c) if $le < 0;
            (my $show = substr($c, $ls, $le - $ls)) =~ s/\s+/ /g;
            $show =~ s/^ | $//g;
            # --plain: drop emphasis at word boundaries only, so "**bold**" and "`code`"
            # lose their markers while "snake_case" keeps its underscore. Lets a caller
            # compare the reported text with an undecorated copy of the same span.
            $show =~ s/(?<!\w)[*_`~]+|[*_`~]+(?!\w)//g if $o{plain};
            print $o{label} ? "$pnum\t$file:$line: $show\n" : "$file:$line: $show\n";
            $hits = 1;
            $found{$pnum} = 1;
            last if $o{first};
        }
    }
}
exit($hits ? 0 : 1);

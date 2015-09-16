USING: arrays help.markup help.syntax math ;
IN: compiler.cfg.linear-scan.ranges

HELP: intersect-range
{ $values
  { "range1" pair }
  { "range2" pair }
  { "n/f" { $link number } " or " { $link f } }
}
{ $description "First index for the ranges intersection, or f if they don't intersect." } ;

ARTICLE: "compiler.cfg.linear-scan.ranges" "Live ranges utilities"
"Utilities for dealing with the live range part of live intervals. A sequence of integer 2-tuples encodes the closed intervals in the cfg where a virtual register is live."
$nl
"Range splitting:"
{ $subsections
  split-range split-ranges
} ;

ABOUT: "compiler.cfg.linear-scan.ranges"

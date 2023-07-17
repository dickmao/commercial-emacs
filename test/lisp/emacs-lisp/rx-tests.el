;;; rx-tests.el --- tests for rx.el              -*- lexical-binding: t -*-

;; Copyright (C) 2016-2023 Free Software Foundation, Inc.

;; This file is NOT part of GNU Emacs.

;; GNU Emacs is free software: you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation, either version 3 of the License, or
;; (at your option) any later version.

;; GNU Emacs is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with GNU Emacs.  If not, see <https://www.gnu.org/licenses/>.

;;; Code:

(require 'ert)
(require 'rx)

(ert-deftest rx-seq ()
  (should (equal (rx "a.b" "*" "c")
                 "a\\.b\\*c"))
  (should (equal (rx (seq "a" (: "b" (and "c" (sequence "d" nonl)
                                          "e")
                                 "f")
                          "g"))
                 "abcd.efg"))
  (should (equal (rx "a$" "b")
                 "a\\$b"))
  (should (equal (rx bol "a" "b" ?c eol)
                 "^abc$"))
  (should (equal (rx "a" "" "b")
                 "ab"))
  (should (equal (rx (seq))
                 ""))
  (should (equal (rx "" (or "ab" nonl) "")
                 "ab\\|.")))

(ert-deftest rx-or ()
  (should (equal (rx (or "ab" (| "c" nonl) "de"))
                 "ab\\|c\\|.\\|de"))
  (should (equal (rx (or "ab" "abc" ?a))
                 "\\(?:a\\(?:bc?\\)?\\)"))
  (should (equal (rx (or "ab" (| (or "abcd" "abcde")) (or "a" "abc")))
                 "\\(?:a\\(?:b\\(?:c\\(?:de?\\)?\\)?\\)?\\)"))
  (should (equal (rx (or "a" (eval (string ?a ?b))))
                 "\\(?:ab?\\)"))
  (should (equal (rx (| nonl "a") (| "b" blank))
                 "\\(?:.\\|a\\)\\(?:b\\|[[:blank:]]\\)"))
  (should (equal (rx (|))
                 "\\`a\\`")))

(ert-deftest rx-def-in-or ()
  (rx-let ((a b)
           (b (or "abc" c))
           (c ?a)
           (d (any "a-z")))
    (should (equal (rx (or a (| "ab" "abcde") "abcd"))
                   "\\(?:a\\(?:b\\(?:c\\(?:de?\\)?\\)?\\)?\\)"))
    (should (equal (rx (or ?m (not d)))
                   "[^a-ln-z]"))))

(ert-deftest rx-char-any ()
  "Test character alternatives with `]' and `-' (Bug#25123)."
  (should (equal
           ;; relint suppression: Range .<-]. overlaps previous .]-{
           (rx string-start (1+ (char (?\] . ?\{) (?< . ?\]) (?- . ?:)))
               string-end)
           "\\`[.-:<-{-]+\\'")))

(ert-deftest rx-char-any-range-nl ()
  "Test character alternatives with LF as a range endpoint."
  (should (equal (rx (any "\n-\r"))
                 "[\n-\r]"))
  (should (equal (rx (any "\a-\n"))
                 "[\a-\n]")))

(ert-deftest rx-char-any-raw-byte ()
  "Test raw bytes in character alternatives."

  ;; The multibyteness of the rx return value sometimes depends on whether
  ;; the test had been byte-compiled or not, so we add explicit conversions.

  ;; Separate raw characters.
  (should (equal (string-to-multibyte (rx (any "\326A\333B")))
                 (string-to-multibyte "[AB\326\333]")))
  ;; Range of raw characters, unibyte.
  (should (equal (string-to-multibyte (rx (any "\200-\377")))
                 (string-to-multibyte "[\200-\377]")))

  ;; Range of raw characters, multibyte.
  (should (equal (rx (any "Å\211\326-\377\177"))
                 "[\177Å\211\326-\377]"))
  ;; Split range; \177-\377ÿ should not be optimized to \177-\377.
  (should (equal (rx (any "\177-\377" ?ÿ))
                 "[\177ÿ\200-\377]"))
  ;; Range between normal chars and raw bytes: must be split to be parsed
  ;; correctly by the Emacs regexp engine.
  (should (equal
           (rx (any (0 . #x3fffff)) (any (?G . #x3fff9a)) (any (?Ü . #x3ffff2)))
           "[\0-\x3fff7f\x80-\xff][G-\x3fff7f\x80-\x9a][Ü-\x3fff7f\x80-\xf2]"))
  ;; As above but with ranges in string form. For historical reasons,
  ;; we special-case ASCII-to-raw ranges to exclude non-ASCII unicode.
  (should (equal
           (rx (any "\x00-\xff") (any "G-\x9a") (any "Ü-\xf2"))
           "[\0-\x7f\x80-\xff][G-\x7f\x80-\x9a][Ü-\x3fff7f\x80-\xf2]")))

(ert-deftest rx-any ()
  (should (equal (rx (any ?A (?C . ?D) "F-H" "J-L" "M" "N-P" "Q" "RS"))
                 "[ACDF-HJ-S]"))
  (should (equal (rx (in "a!f" ?c) (char "q-z" "0-3")
                     (not-char "a-e1-5") (not (in "A-M" ?q)))
                 "[!acf][0-3q-z][^1-5a-e][^A-Mq]"))
  (should (equal (rx (any "^") (any "]") (any "-")
                     (not (any "^")) (not (any "]")) (not (any "-")))
                 "\\^]-[^^][^]][^-]"))
  (should (equal (rx (any "]" "^") (any "]" "-") (any "-" "^")
                     (not (any "]" "^")) (not (any "]" "-"))
                     (not (any "-" "^")))
                 "[]^][]-][-^][^]^][^]-][^-^]"))
  (should (equal (rx (any "]" "^" "-") (not (any "]" "^" "-")))
                 "[]^-][^]^-]"))
  (should (equal (rx (any "-" ascii) (any "^" ascii) (any "]" ascii))
                 "[[:ascii:]-][[:ascii:]^][][:ascii:]]"))
  (should (equal (rx (not (any "-" ascii)) (not (any "^" ascii))
                     (not (any "]" ascii)))
                 "[^[:ascii:]-][^[:ascii:]^][^][:ascii:]]"))
  (should (equal (rx (any "-]" ascii) (any "^]" ascii) (any "-^" ascii))
                 "[][:ascii:]-][]^[:ascii:]][[:ascii:]^-]"))
  (should (equal (rx (not (any "-]" ascii)) (not (any "^]" ascii))
                     (not (any "-^" ascii)))
                 "[^][:ascii:]-][^]^[:ascii:]][^[:ascii:]^-]"))
  (should (equal (rx (any "-]^" ascii) (not (any "-]^" ascii)))
                 "[]^[:ascii:]-][^]^[:ascii:]-]"))
  (should (equal (rx (any "^" lower upper) (not (any "^" lower upper)))
                 "[[:lower:]^[:upper:]][^[:lower:]^[:upper:]]"))
  (should (equal (rx (any "-" lower upper) (not (any "-" lower upper)))
                 "[[:lower:][:upper:]-][^[:lower:][:upper:]-]"))
  (should (equal (rx (any "]" lower upper) (not (any "]" lower upper)))
                 "[][:lower:][:upper:]][^][:lower:][:upper:]]"))
  ;; relint suppression: Duplicated character .-.
  ;; relint suppression: Single-character range .f-f
  ;; relint suppression: Range .--/. overlaps previous .-
  ;; relint suppression: Range .\*--. overlaps previous .--/
  (should (equal (rx (any "-a" "c-" "f-f" "--/*--") (any "," "-" "A"))
                 "[*-/acf][,A-]"))
  (should (equal (rx (any "]-a" ?-) (not (any "]-a" ?-)))
                 "[]-a-][^]-a-]"))
  (should (equal (rx (any "--]") (not (any "--]"))
                     (any "-" "^-a") (not (any "-" "^-a")))
                 "[].-\\-][^].-\\-][-^-a][^-^-a]"))
  (should (equal (rx (not (any "!a" "0-8" digit nonascii)))
                 "[^!0-8a[:digit:][:nonascii:]]"))
  (should (equal (rx (any) (not (any)))
                 "\\`a\\`[^z-a]"))
  (should (equal (rx (any "") (not (any "")))
                 "\\`a\\`[^z-a]"))
  ;; relint suppression: Duplicated class .space.
  (should (equal (rx (any space ?a digit space))
                 "[a[:space:][:digit:]]"))
  (should (equal (rx (not "\n") (not ?\n) (not (any "\n")) (not-char ?\n)
                     (| (not (in "a\n")) (not (char ?\n (?b . ?b)))))
          ".....")))

(ert-deftest rx-pcase ()
  (should (equal (pcase "i18n" ((rx (let x (+ digit))) (list 'ok x)))
                 '(ok "18")))
  (should (equal (pcase "a 1 2 3 1 1 b"
                   ((rx (let u (+ digit)) space
                        (let v (+ digit)) space
                        (let v (+ digit)) space
                        (backref u) space
                        (backref 1))
                    (list u v)))
                 '("1" "3")))
  (should (equal (pcase "bz"
                   ((rx "a" (let x nonl)) (list 1 x))
                   (_ 'no))
                 'no))
  (should (equal (pcase "az"
                   ((rx "a" (let x nonl)) (list 1 x))
                   ((rx "b" (let x nonl)) (list 2 x))
                   (_ 'no))
                 '(1 "z")))
  (should (equal (pcase "bz"
                   ((rx "a" (let x nonl)) (list 1 x))
                   ((rx "b" (let x nonl)) (list 2 x))
                   (_ 'no))
                 '(2 "z")))
  (let ((k "blue"))
    (should (equal (pcase "<blue>"
                     ((rx "<" (literal k) ">") 'ok))
                   'ok)))
  (should (equal (pcase "abc"
                   ((rx (? (let x alpha)) (?? (let y alnum)) ?c)
                    (list x y)))
                 '("a" "b")))
  (should (equal (pcase 'not-a-string
                   ((rx nonl) 'wrong)
                   (_ 'correct))
                 'correct))
  (should (equal (pcase "PQR"
                   ((and (rx (let a nonl)) (rx ?z))
                    (list 'one a))
                   ((rx (let b ?Q))
                    (list 'two b)))
                 '(two "Q")))
  (should (equal (pcase-let (((rx ?B (let z nonl)) "ABC"))
                   (list 'ok z))
                 '(ok "C")))
  (should (equal (pcase-let* (((rx ?E (let z nonl)) "DEF"))
                   (list 'ok z))
                 '(ok "F"))))

(ert-deftest rx-let-pcase ()
  "Test `rx-let' around `pcase' with `rx' patterns (bug#59814)."
  (should (equal (rx-let ((tata "ab"))
                   (pcase "abc" ((rx tata) 'toto)))
                 'toto)))

(ert-deftest rx-kleene ()
  "Test greedy and non-greedy repetition operators."
  (should (equal (rx (* "a") (+ "b") (\? "c") (?\s "d")
                     (*? "e") (+? "f") (\?? "g") (?? "h"))
                 "a*b+c?d?e*?f+?g??h??"))
  (should (equal (rx (zero-or-more "a") (0+ "b")
                     (one-or-more "c") (1+ "d")
                     (zero-or-one "e") (optional "f") (opt "g"))
                 "a*b*c+d+e?f?g?"))
  (should (equal (rx (minimal-match
                      (seq (* "a") (+ "b") (\? "c") (?\s "d")
                           (*? "e") (+? "f") (\?? "g") (?? "h"))))
                 "a*b+c?d?e*?f+?g??h??"))
  (should (equal (rx (minimal-match
                      (seq (zero-or-more "a") (0+ "b")
                           (one-or-more "c") (1+ "d")
                           (zero-or-one "e") (optional "f") (opt "g"))))
                 "a*?b*?c+?d+?e??f??g??"))
  (should (equal (rx (maximal-match
                      (seq (* "a") (+ "b") (\? "c") (?\s "d")
                         (*? "e") (+? "f") (\?? "g") (?? "h"))))
                 "a*b+c?d?e*?f+?g??h??"))
  (should (equal (rx "a" (*) (+ (*)) (? (*) (+)) "b")
                 "ab")))

(ert-deftest rx-repeat ()
  (should (equal (rx (= 3 "a") (>= 51 "b")
                     (** 2 11 "c") (repeat 6 "d") (repeat 4 8 "e"))
                 "a\\{3\\}b\\{51,\\}c\\{2,11\\}d\\{6\\}e\\{4,8\\}"))
  (should (equal (rx (= 0 "k") (>= 0 "l") (** 0 0 "m") (repeat 0 "n")
                     (repeat 0 0 "o"))
                 "k\\{0\\}l\\{0,\\}m\\{0\\}n\\{0\\}o\\{0\\}"))
  (should (equal (rx (opt (0+ "a")))
                 "\\(?:a*\\)?"))
  (should (equal (rx (opt (= 4 "a")))
                 "a\\{4\\}?"))
  (should (equal (rx "a" (** 3 7) (= 4) (>= 3) (= 4 (>= 7) (= 2)) "b")
                 "ab")))

(ert-deftest rx-atoms ()
  (should (equal (rx anychar anything)
                 "[^z-a][^z-a]"))
  (should (equal (rx unmatchable)
                 "\\`a\\`"))
  (should (equal (rx line-start not-newline nonl any line-end)
                 "^...$"))
  (should (equal (rx bol string-start string-end buffer-start buffer-end
                     bos eos bot eot eol)
                 "^\\`\\'\\`\\'\\`\\'\\`\\'$"))
  (should (equal (rx point word-start word-end bow eow symbol-start symbol-end
                     word-boundary not-word-boundary not-wordchar)
                 "\\=\\<\\>\\<\\>\\_<\\_>\\b\\B\\W"))
  (should (equal (rx digit numeric num control cntrl)
                 "[[:digit:]][[:digit:]][[:digit:]][[:cntrl:]][[:cntrl:]]"))
  (should (equal (rx hex-digit hex xdigit blank)
                 "[[:xdigit:]][[:xdigit:]][[:xdigit:]][[:blank:]]"))
  (should (equal (rx graph graphic print printing)
                 "[[:graph:]][[:graph:]][[:print:]][[:print:]]"))
  (should (equal (rx alphanumeric alnum letter alphabetic alpha)
                 "[[:alnum:]][[:alnum:]][[:alpha:]][[:alpha:]][[:alpha:]]"))
  (should (equal (rx ascii nonascii lower lower-case)
                 "[[:ascii:]][[:nonascii:]][[:lower:]][[:lower:]]"))
  (should (equal (rx punctuation punct space whitespace white)
                 "[[:punct:]][[:punct:]][[:space:]][[:space:]][[:space:]]"))
  (should (equal (rx upper upper-case word wordchar)
                 "[[:upper:]][[:upper:]][[:word:]][[:word:]]"))
  (should (equal (rx unibyte multibyte)
                 "[[:unibyte:]][[:multibyte:]]")))

(ert-deftest rx-syntax ()
  (should (equal (rx (syntax whitespace) (syntax punctuation)
                     (syntax word) (syntax symbol)
                     (syntax open-parenthesis) (syntax close-parenthesis))
                 "\\s-\\s.\\sw\\s_\\s(\\s)"))
  (should (equal (rx (syntax string-quote) (syntax paired-delimiter)
                     (syntax escape) (syntax character-quote)
                     (syntax comment-start) (syntax comment-end)
                     (syntax string-delimiter) (syntax comment-delimiter))
                 "\\s\"\\s$\\s\\\\s/\\s<\\s>\\s|\\s!")))

(ert-deftest rx-category ()
  (should (equal (rx (category space-for-indent) (category base)
                     (category consonant) (category base-vowel)
                     (category upper-diacritical-mark)
                     (category lower-diacritical-mark)
                     (category tone-mark) (category symbol)
                     (category digit)
                     (category vowel-modifying-diacritical-mark)
                     (category vowel-sign) (category semivowel-lower)
                     (category not-at-end-of-line)
                     (category not-at-beginning-of-line))
                 "\\c \\c.\\c0\\c1\\c2\\c3\\c4\\c5\\c6\\c7\\c8\\c9\\c<\\c>"))
  (should (equal (rx (category alpha-numeric-two-byte)
                     (category chinese-two-byte) (category greek-two-byte)
                     (category japanese-hiragana-two-byte)
                     (category indian-two-byte)
                     (category japanese-katakana-two-byte)
                     (category strong-left-to-right)
                     (category korean-hangul-two-byte)
                     (category strong-right-to-left)
                     (category cyrillic-two-byte)
                     (category combining-diacritic))
                 "\\cA\\cC\\cG\\cH\\cI\\cK\\cL\\cN\\cR\\cY\\c^"))
  (should (equal (rx (category ascii) (category arabic) (category chinese)
                     (category ethiopic) (category greek) (category korean)
                     (category indian) (category japanese)
                     (category japanese-katakana) (category latin)
                     (category lao) (category tibetan))
                 "\\ca\\cb\\cc\\ce\\cg\\ch\\ci\\cj\\ck\\cl\\co\\cq"))
  (should (equal (rx (category japanese-roman) (category thai)
                     (category vietnamese) (category hebrew)
                     (category cyrillic) (category can-break))
                 "\\cr\\ct\\cv\\cw\\cy\\c|"))
  (should (equal (rx (category ?g) (not (category ?~)))
                 "\\cg\\C~")))

(ert-deftest rx-not ()
  (should (equal (rx (not word-boundary))
                 "\\B"))
  (should (equal (rx (not ascii) (not lower-case) (not wordchar))
                 "[^[:ascii:]][^[:lower:]][^[:word:]]"))
  (should (equal (rx (not (syntax punctuation)) (not (syntax escape)))
                 "\\S.\\S\\"))
  (should (equal (rx (not (category tone-mark)) (not (category lao)))
                 "\\C4\\Co"))
  (should (equal (rx (not (not ascii)) (not (not (not (any "a-z")))))
                 "[[:ascii:]][^a-z]"))
  (should (equal (rx (not ?a) (not "b") (not (not "c")) (not (not ?d)))
                 "[^a][^b]cd")))

(ert-deftest rx-charset-or ()
  (should (equal (rx (or))
                 "\\`a\\`"))
  (should (equal (rx (or (any "ba")))
                 "[ab]"))
  (should (equal (rx (| (any "a-f") (any "c-k" ?y) (any ?r "x-z")))
                 "[a-krx-z]"))
  (should (equal (rx (or (not (any "a-m")) (not (any "f-p"))))
                 "[^f-m]"))
  (should (equal (rx (| (any "e-m") (not (any "a-z"))))
                 "[^a-dn-z]"))
  (should (equal (rx (or (not (any "g-r")) (not (any "t"))))
                 "[^z-a]"))
  (should (equal (rx (not (or (not (any "g-r")) (not (any "t")))))
                 "\\`a\\`"))
  (should (equal (rx (or (| (any "a-f") (any "u-z"))
                         (any "g-r")))
                 "[a-ru-z]"))
  (should (equal (rx (or (intersection (any "c-z") (any "a-g"))
                         (not (any "a-k"))))
                 "[^abh-k]"))
  (should (equal (rx (or ?f (any "b-e") "a") (not (or ?x "y" (any "s-w"))))
                 "[a-f][^s-y]"))
  (should (equal (rx (not (or (in "abc") (char "bcd"))))
                 "[^a-d]"))
  (should (equal (rx (or (not (in "abc")) (not (char "bcd"))))
                 "[^bc]"))
  (should (equal (rx (or "x" (? "yz")))
                 "x\\|\\(?:yz\\)?")))

(ert-deftest rx-def-in-charset-or ()
  (rx-let ((a (any "badc"))
           (b (| a (any "def")))
           (c ?a)
           (d "b"))
    (should (equal (rx (or b (any "q")) (or c d))
                   "[a-fq][ab]")))
  (rx-let ((diff-| (a b) (not (or (not a) b))))
    (should (equal (rx (diff-| (any "a-z") (any "gr")))
                   "[a-fh-qs-z]"))))

(ert-deftest rx-intersection ()
  (should (equal (rx (intersection))
                 "[^z-a]"))
  (should (equal (rx (intersection (any "ba")))
                 "[ab]"))
  (should (equal (rx (intersection (any "a-j" "u-z") (any "c-k" ?y)
                                   (any "a-i" "x-z")))
                 "[c-iy]"))
  (should (equal (rx (intersection (not (any "a-m")) (not (any "f-p"))))
                 "[^a-p]"))
  (should (equal (rx (intersection (any "a-z") (not (any "g-q"))))
                 "[a-fr-z]"))
  (should (equal (rx (intersection (any "a-d") (any "e")))
                 "\\`a\\`"))
  (should (equal (rx (not (intersection (any "a-d") (any "e"))))
                 "[^z-a]"))
  (should (equal (rx (intersection (any "d-u")
                                   (intersection (any "e-z") (any "a-m"))))
                 "[e-m]"))
  (should (equal (rx (intersection (or (any "a-f") (any "f-t"))
                                   (any "e-w")))
                 "[e-t]"))
  (should (equal (rx (intersection ?m (any "a-z") "m"))
                 "m")))

(ert-deftest rx-def-in-intersection ()
  (rx-let ((a (any "a-g"))
           (b (intersection a (any "d-j"))))
    (should (equal (rx (intersection b (any "e-k")))
                   "[e-g]")))
  (rx-let ((diff-& (a b) (intersection a (not b))))
    (should (equal (rx (diff-& (any "a-z") (any "m-p")))
                   "[a-lq-z]"))))

(ert-deftest rx-group ()
  (should (equal (rx (group nonl) (submatch "x")
                     (group-n 3 "y") (submatch-n 13 "z") (backref 1))
                 "\\(.\\)\\(x\\)\\(?3:y\\)\\(?13:z\\)\\1"))
  (should (equal (rx (group) (group-n 2))
                 "\\(\\)\\(?2:\\)")))

(ert-deftest rx-regexp ()
  (should (equal (rx (regexp "abc") (regex "[de]"))
                 "\\(?:abc\\)[de]"))
  (should (equal (rx "a" (regexp "$"))
                 "a\\(?:$\\)"))
  (let ((x "a*"))
    (should (equal (rx (regexp x) "b")
                   "\\(?:a*\\)b"))
    (should (equal (rx "" (regexp x) (eval ""))
                   "a*"))))

(ert-deftest rx-eval ()
  (should (equal (rx (eval (list 'syntax 'symbol)))
                 "\\s_"))
  (should (equal (rx "a" (eval (concat)) "b")
                 "ab")))

(ert-deftest rx-literal ()
  (should (equal (rx (literal "$a"))
                 "\\$a"))
  (should (equal (rx (literal (char-to-string 42)) nonl)
                 "\\*."))
  (let ((x "a+b"))
    (should (equal (rx (opt (literal (upcase x))))
                   "\\(?:A\\+B\\)?"))))

(ert-deftest rx-to-string ()
  (should (equal (rx-to-string '(or nonl "\nx"))
                 "\\(?:.\\|\nx\\)"))
  (should (equal (rx-to-string '(or nonl "\nx") t)
                 ".\\|\nx")))

(ert-deftest rx-let ()
  (rx-let ((beta gamma)
           (gamma delta)
           (delta (+ digit))
           (epsilon (or gamma nonl)))
    (should (equal (rx bol delta epsilon)
                   "^[[:digit:]]+\\(?:[[:digit:]]+\\|.\\)")))
  (rx-let ((p () point)
           (separated (x sep) (seq x (* sep x)))
           (comma-separated (x) (separated x ","))
           (semi-separated (x) (separated x ";"))
           (matrix (v) (semi-separated (comma-separated v))))
    (should (equal (rx (p) (matrix (+ "a")) eos)
                   "\\=a+\\(?:,a+\\)*\\(?:;a+\\(?:,a+\\)*\\)*\\'")))
  (rx-let ((b bol)
           (z "B")
           (three (x) (= 3 x)))
    (rx-let ((two (x) (seq x x))
             (z "A")
             (e eol))
      (should (equal (rx b (two (three z)) e)
                     "^A\\{3\\}A\\{3\\}$"))))
  (rx-let ((f (a b &rest r) (seq "<" a ";" b ":" r ">")))
    (should (equal (rx bol (f ?x ?y) ?! (f ?u ?v ?w) ?! (f ?k ?l ?m ?n) eol)
                   "^<x;y:>!<u;v:w>!<k;l:mn>$")))

  ;; Rest parameters are expanded by splicing.
  (rx-let ((f (&rest r) (or bol r eol)))
    (should (equal (rx (f "ab" nonl))
                   "^\\|ab\\|.\\|$")))

  ;; Substitution is done in number positions.
  (rx-let ((stars (n) (= n ?*)))
    (should (equal (rx (stars 4))
                   "\\*\\{4\\}")))

  ;; Substitution is done inside dotted pairs.
  (rx-let ((f (x y z) (any x (y . z))))
    (should (equal (rx (f ?* ?a ?t))
                   "[*a-t]")))

  ;; Substitution is done in the head position of forms.
  (rx-let ((f (x) (x "a")))
    (should (equal (rx (f +))
                   "a+"))))

(ert-deftest rx-define ()
  (rx-define rx--a (seq "x" (opt "y")))
  (should (equal (rx bol rx--a eol)
                 "^xy?$"))
  (rx-define rx--c (lb rb &rest stuff) (seq lb stuff rb))
  (should (equal (rx bol (rx--c "<" ">" rx--a nonl) eol)
                 "^<xy?.>$"))
  (rx-define rx--b (* rx--a))
  (should (equal (rx rx--b)
                 "\\(?:xy?\\)*"))
  (rx-define rx--a "z")
  (should (equal (rx rx--b)
                 "z*")))

(defun rx--test-rx-to-string-define ()
  ;; `rx-define' won't expand to code inside `ert-deftest' since we use
  ;; `eval-and-compile'.  Put it into a defun as a workaround.
  (rx-define rx--d "Q")
  (rx-to-string '(seq bol rx--d) t))

(ert-deftest rx-to-string-define ()
  "Check that `rx-to-string' uses definitions made by `rx-define'."
  (should (equal (rx--test-rx-to-string-define)
                 "^Q")))

(ert-deftest rx-let-define ()
  "Test interaction between `rx-let' and `rx-define'."
  (rx-define rx--e "one")
  (rx-define rx--f "eins")
  (rx-let ((rx--e "two"))
    (should (equal (rx rx--e nonl rx--f) "two.eins"))
    (rx-define rx--e "three")
    (should (equal (rx rx--e) "two"))
    (rx-define rx--f "zwei")
    (should (equal (rx rx--f) "zwei")))
  (should (equal (rx rx--e nonl rx--f) "three.zwei")))

(ert-deftest rx-let-eval ()
  (rx-let-eval '((a (* digit))
                 (f (x &rest r) (seq x nonl r)))
    (should (equal (rx-to-string '(seq a (f bow a ?b)) t)
                   "[[:digit:]]*\\<.[[:digit:]]*b"))))

(ert-deftest rx-redefine-builtin ()
  (should-error (rx-define sequence () "x"))
  (should-error (rx-define sequence "x"))
  (should-error (rx-define nonl () "x"))
  (should-error (rx-define nonl "x"))
  (should-error (rx-let ((punctuation () "x")) nil))
  (should-error (rx-let ((punctuation "x")) nil))
  (should-error (rx-let-eval '((not-char () "x")) nil))
  (should-error (rx-let-eval '((not-char "x")) nil)))

(ert-deftest rx-def-in-not ()
  "Test definition expansion inside (not ...)."
  (rx-let ((a alpha)
           (b (not hex))
           (c (not (category base)))
           (d (x) (any ?a x ?z))
           (e (x) (syntax x))
           (f (not b)))
    (should (equal (rx (not a) (not b) (not c) (not f))
                   "[^[:alpha:]][[:xdigit:]]\\c.[^[:xdigit:]]"))
    (should (equal (rx (not (d ?m)) (not (e symbol)))
                   "[^amz]\\S_"))))

(ert-deftest rx-constituents ()
  (let ((rx-constituents
         (append '((beta . gamma)
                   (gamma . "a*b")
                   (delta . ((lambda (form)
                               (regexp-quote (format "<%S>" form)))
                             1 nil symbolp))
                   (epsilon . delta))
                 rx-constituents)))
    (should (equal (rx-to-string '(seq (+ beta) nonl gamma) t)
                   "\\(?:a*b\\)+.\\(?:a*b\\)"))
    (should (equal (rx-to-string '(seq (delta a b c) (* (epsilon d e))) t)
                   "\\(?:<(delta a b c)>\\)\\(?:<(epsilon d e)>\\)*"))))

(ert-deftest rx-compat ()
  "Test old symbol retained for compatibility (bug#37517)."
  (should (equal
           (with-no-warnings
             (rx-submatch-n '(group-n 3 (+ nonl) eol)))
           "\\(?3:.+$\\)")))

(provide 'rx-tests)

;;; rx-tests.el ends here

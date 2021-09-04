;;; ethiopic.el --- Quail package for inputting Ethiopic characters  -*-coding: utf-8-emacs; lexical-binding:t -*-

;; Copyright (C) 1997, 1998, 1999, 2000, 2001, 2002, 2003, 2004, 2005,
;;   2006, 2007, 2008, 2009, 2010, 2011
;;   National Institute of Advanced Industrial Science and Technology (AIST)
;;   Registration Number H14PRO021

;; Keywords: multilingual, input method, ethiopic

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

;; Author: TAKAHASHI Naoto <ntakahas@etl.go.jp>

;;; Commentary:

;;; Code:

(require 'quail)
(require 'ethio-util)

;;
;; The package "ethiopic"
;;

(quail-define-package
 "ethiopic" "Ethiopic"
 '("ፊደል "
   (ethio-prefer-ascii-space "_" "፡")
   "።")
 t "  Quail package for Ethiopic (Tigrigna and Amharic)

When you are in Ethiopic language environment, the following special
keys are available.

C-F9 or `M-x ethio-toggle-space'
  Toggles space characters for keyboard input.  The current mode is
  indicated in mode-line, whether by `_' (ASCII space) or `፡'
  (Ethiopic colon-like word separator).  Even in the `፡' mode, an
  ASCII space is inserted if the point is preceded by an Ethiopic
  punctuation char that is followed by zero or more ASCII spaces.

S-F5 or `M-x ethio-toggle-punctuation'
  Toggles ASCII punctuation and Ethiopic punctuation for keyboard input.
  The current mode is indicated by `.' (ASCII) or `።' (Ethiopic).

S-SPC or `M-x ethio-insert-ethio-space'
  Always insert an Ethiopic word separator `፡'.  With a prefix number,
  insert that many word separators.

C-\\=' or `M-x ethio-gemination'
  Compose the character before the point with the Ethiopic gemination mark.
  If the character is already composed, decompose it and remove the
  gemination mark."

 ;; The following keys should work as defined in lisp/language/ethio-util,
 ;; even during the translation.
 '(([C-f9]  . quail-execute-non-quail-command)
   ([S-f5]  . quail-execute-non-quail-command)
   (" "     . quail-execute-non-quail-command)
   ([?\S- ] . quail-execute-non-quail-command)
   ([?\C-'] . quail-execute-non-quail-command))
 t t)

(quail-define-rules
 ("he" ?ሀ)
 ("hu" ?ሁ)
 ("hi" ?ሂ)
 ("ha" ?ሃ)
 ("hE" ?ሄ)
 ("hee" ?ሄ)
 ("h" ?ህ)
 ("ho" ?ሆ)
 ("hW" ?ኋ)
 ("hWa" ?ኋ)
 ("hWe" ?ኈ)
 ("hWu" ?ኍ)
 ("hWi" ?ኊ)
 ("hWE" ?ኌ)
 ("hW'" ?ኍ)

 ("le" ?ለ)
 ("lu" ?ሉ)
 ("li" ?ሊ)
 ("la" ?ላ)
 ("lE" ?ሌ)
 ("lee" ?ሌ)
 ("l" ?ል)
 ("lo" ?ሎ)
 ("lW" ?ሏ)
 ("lWa" ?ሏ)
 ("lWe" ["ል����"])
 ("lWu" ["ል����"])
 ("lWi" ["ል����"])
 ("lWE" ["ል����"])
 ("lW'" ["ል����"])

 ("Le" ?ለ)
 ("Lu" ?ሉ)
 ("Li" ?ሊ)
 ("La" ?ላ)
 ("LE" ?ሌ)
 ("Lee" ?ሌ)
 ("L" ?ል)
 ("Lo" ?ሎ)
 ("LW" ?ሏ)
 ("LWa" ?ሏ)
 ("LWe" ["ል����"])
 ("LWu" ["ል����"])
 ("LWi" ["ል����"])
 ("LWE" ["ል����"])
 ("LW'" ["ል����"])

 ("He" ?ሐ)
 ("Hu" ?ሑ)
 ("Hi" ?ሒ)
 ("Ha" ?ሓ)
 ("HE" ?ሔ)
 ("Hee" ?ሔ)
 ("H" ?ሕ)
 ("Ho" ?ሖ)
 ("HW" ?ሗ)
 ("HWa" ?ሗ)
 ("HWe" ["ሕ����"])
 ("HWu" ["ሕ����"])
 ("HWi" ["ሕ����"])
 ("HWE" ["ሕ����"])
 ("HW'" ["ሕ����"])

 ("me" ?መ)
 ("mu" ?ሙ)
 ("mi" ?ሚ)
 ("ma" ?ማ)
 ("mE" ?ሜ)
 ("mee" ?ሜ)
 ("m" ?ም)
 ("mo" ?ሞ)
 ("mWe" ?����)
 ("mWu" ?����)
 ("mWi" ?����)
 ("mW" ?ሟ)
 ("mWa" ?ሟ)
 ("mWE" ?����)
 ("mWee" ?����)
 ("mW'" ?����)
 ("mY" ?ፘ)
 ("mYa" ?ፘ)

 ("Me" ?መ)
 ("Mu" ?ሙ)
 ("Mi" ?ሚ)
 ("Ma" ?ማ)
 ("ME" ?ሜ)
 ("Mee" ?ሜ)
 ("M" ?ም)
 ("Mo" ?ሞ)
 ("MWe" ?����)
 ("MWu" ?����)
 ("MWi" ?����)
 ("MW" ?ሟ)
 ("MWa" ?ሟ)
 ("MWE" ?����)
 ("MWee" ?����)
 ("MW'" ?����)
 ("MY" ?ፘ)
 ("MYa" ?ፘ)

 ("`se" ?ሠ)
 ("`su" ?ሡ)
 ("`si" ?ሢ)
 ("`sa" ?ሣ)
 ("`sE" ?ሤ)
 ("`see" ?ሤ)
 ("`s" ?ሥ)
 ("`so" ?ሦ)
 ("`sW" ?ሧ)
 ("`sWa" ?ሧ)
 ("`sWe" ["ሥ����"])
 ("`sWu" ["ሥ����"])
 ("`sWi" ["ሥ����"])
 ("`sWE" ["ሥ����"])
 ("`sWee" ["ሥ����"])
 ("`sW'" ["ሥ����"])

 ("s2e" ?ሠ)
 ("s2u" ?ሡ)
 ("s2i" ?ሢ)
 ("s2a" ?ሣ)
 ("s2E" ?ሤ)
 ("s2ee" ?ሤ)
 ("s2" ?ሥ)
 ("s2o" ?ሦ)
 ("s2W" ?ሧ)
 ("s2Wa" ?ሧ)
 ("s2We" ["ሥ����"])
 ("s2Wu" ["ሥ����"])
 ("s2Wi" ["ሥ����"])
 ("s2WE" ["ሥ����"])
 ("s2Wee" ["ሥ����"])
 ("s2W'" ["ሥ����"])

 ("sse" ?ሠ)
 ("ssu" ?ሡ)
 ("ssi" ?ሢ)
 ("ssa" ?ሣ)
 ("ssE" ?ሤ)
 ("ssee" ?ሤ)
 ("ss" ?ሥ)
 ("sso" ?ሦ)
 ("ssW" ?ሧ)
 ("ssWa" ?ሧ)
 ("ssWe" ["ሥ����"])
 ("ssWu" ["ሥ����"])
 ("ssWi" ["ሥ����"])
 ("ssWE" ["ሥ����"])
 ("ssWee" ["ሥ����"])
 ("ssW'" ["ሥ����"])

 ("re" ?ረ)
 ("ru" ?ሩ)
 ("ri" ?ሪ)
 ("ra" ?ራ)
 ("rE" ?ሬ)
 ("ree" ?ሬ)
 ("r" ?ር)
 ("ro" ?ሮ)
 ("rW" ?ሯ)
 ("rWa" ?ሯ)
 ("rY" ?ፙ)
 ("rYa" ?ፙ)
 ("rWe" ["ር����"])
 ("rWu" ["ር����"])
 ("rWi" ["ር����"])
 ("rWE" ["ር����"])
 ("rWee" ["ር����"])
 ("rW'" ["ር����"])

 ("Re" ?ረ)
 ("Ru" ?ሩ)
 ("Ri" ?ሪ)
 ("Ra" ?ራ)
 ("RE" ?ሬ)
 ("Ree" ?ሬ)
 ("R" ?ር)
 ("Ro" ?ሮ)
 ("RW" ?ሯ)
 ("RWa" ?ሯ)
 ("RYa" ?ፙ)
 ("RWe" ["ር����"])
 ("RWu" ["ር����"])
 ("RWi" ["ር����"])
 ("RWE" ["ር����"])
 ("RWee" ["ር����"])
 ("RW'" ["ር����"])

 ("se" ?ሰ)
 ("su" ?ሱ)
 ("si" ?ሲ)
 ("sa" ?ሳ)
 ("sE" ?ሴ)
 ("see" ?ሴ)
 ("s" ?ስ)
 ("so" ?ሶ)
 ("sW" ?ሷ)
 ("sWa" ?ሷ)
 ("sWe" ["ስ����"])
 ("sWu" ["ስ����"])
 ("sWi" ["ስ����"])
 ("sWE" ["ስ����"])
 ("sWee" ["ስ����"])
 ("sW'" ["ስ����"])

 ("xe" ?ሸ)
 ("xu" ?ሹ)
 ("xi" ?ሺ)
 ("xa" ?ሻ)
 ("xE" ?ሼ)
 ("xee" ?ሼ)
 ("x" ?ሽ)
 ("xo" ?ሾ)
 ("xW" ?ሿ)
 ("xWa" ?ሿ)
 ("xWe" ["ሽ����"])
 ("xWu" ["ሽ����"])
 ("xWi" ["ሽ����"])
 ("xWE" ["ሽ����"])
 ("xWee" ["ሽ����"])
 ("xW'" ["ሽ����"])

 ("qe" ?ቀ)
 ("qu" ?ቁ)
 ("qi" ?ቂ)
 ("qa" ?ቃ)
 ("qE" ?ቄ)
 ("qee" ?ቄ)
 ("q" ?ቅ)
 ("qo" ?ቆ)
 ("qWe" ?ቈ)
 ("qWu" ?ቍ)
 ("qWi" ?ቊ)
 ("qW" ?ቋ)
 ("qWa" ?ቋ)
 ("qWE" ?ቌ)
 ("qWee" ?ቌ)
 ("qW'" ?ቍ)

 ("`qe" ?����)
 ("`qu" ?����)
 ("`qi" ?����)
 ("`qa" ?����)
 ("`qE" ?����)
 ("`qee" ?����)
 ("`q" ?����)
 ("`qo" ?����)

 ("q2e" ?����)
 ("q2u" ?����)
 ("q2i" ?����)
 ("q2a" ?����)
 ("q2E" ?����)
 ("q2ee" ?����)
 ("q2" ?����)
 ("q2o" ?����)

 ("qqe" ?����)
 ("qqu" ?����)
 ("qqi" ?����)
 ("qqa" ?����)
 ("qqE" ?����)
 ("qqee" ?����)
 ("qq" ?����)
 ("qqo" ?����)

 ("Qe" ?ቐ)
 ("Qu" ?ቑ)
 ("Qi" ?ቒ)
 ("Qa" ?ቓ)
 ("QE" ?ቔ)
 ("Qee" ?ቔ)
 ("Q" ?ቕ)
 ("Qo" ?ቖ)
 ("QWe" ?ቘ)
 ("QWu" ?ቝ)
 ("QWi" ?ቚ)
 ("QW" ?ቛ)
 ("QWa" ?ቛ)
 ("QWE" ?ቜ)
 ("QWee" ?ቜ)
 ("QW'" ?ቝ)

 ("be" ?በ)
 ("bu" ?ቡ)
 ("bi" ?ቢ)
 ("ba" ?ባ)
 ("bE" ?ቤ)
 ("bee" ?ቤ)
 ("b" ?ብ)
 ("bo" ?ቦ)
 ("bWe" ?����)
 ("bWu" ?����)
 ("bWi" ?����)
 ("bW" ?ቧ)
 ("bWa" ?ቧ)
 ("bWE" ?����)
 ("bWee" ?����)
 ("bW'" ?����)

 ("Be" ?በ)
 ("Bu" ?ቡ)
 ("Bi" ?ቢ)
 ("Ba" ?ባ)
 ("BE" ?ቤ)
 ("Bee" ?ቤ)
 ("B" ?ብ)
 ("Bo" ?ቦ)
 ("BWe" ?����)
 ("BWu" ?����)
 ("BWi" ?����)
 ("BW" ?ቧ)
 ("BWa" ?ቧ)
 ("BWE" ?����)
 ("BWee" ?����)
 ("BW'" ?����)

 ("ve" ?ቨ)
 ("vu" ?ቩ)
 ("vi" ?ቪ)
 ("va" ?ቫ)
 ("vE" ?ቬ)
 ("vee" ?ቬ)
 ("v" ?ቭ)
 ("vo" ?ቮ)
 ("vW" ?ቯ)
 ("vWa" ?ቯ)
 ("vWe" ["ቭ����"])
 ("vWu" ["ቭ����"])
 ("vWi" ["ቭ����"])
 ("vWE" ["ቭ����"])
 ("vWee" ["ቭ����"])
 ("vW'" ["ቭ����"])

 ("Ve" ?ቨ)
 ("Vu" ?ቩ)
 ("Vi" ?ቪ)
 ("Va" ?ቫ)
 ("VE" ?ቬ)
 ("Vee" ?ቬ)
 ("V" ?ቭ)
 ("Vo" ?ቮ)
 ("VW" ?ቯ)
 ("VWa" ?ቯ)
 ("VWe" ["ቭ����"])
 ("VWu" ["ቭ����"])
 ("VWi" ["ቭ����"])
 ("VWE" ["ቭ����"])
 ("VWee" ["ቭ����"])
 ("VW'" ["ቭ����"])

 ("te" ?ተ)
 ("tu" ?ቱ)
 ("ti" ?ቲ)
 ("ta" ?ታ)
 ("tE" ?ቴ)
 ("tee" ?ቴ)
 ("t" ?ት)
 ("to" ?ቶ)
 ("tW" ?ቷ)
 ("tWa" ?ቷ)
 ("tWe" ["ት����"])
 ("tWu" ["ት����"])
 ("tWi" ["ት����"])
 ("tWE" ["ት����"])
 ("tWee" ["ት����"])
 ("tW'" ["ት����"])

 ("ce" ?ቸ)
 ("cu" ?ቹ)
 ("ci" ?ቺ)
 ("ca" ?ቻ)
 ("cE" ?ቼ)
 ("cee" ?ቼ)
 ("c" ?ች)
 ("co" ?ቾ)
 ("cW" ?ቿ)
 ("cWa" ?ቿ)
 ("cWe" ["ች����"])
 ("cWu" ["ች����"])
 ("cWi" ["ች����"])
 ("cWE" ["ች����"])
 ("cWee" ["ች����"])
 ("cW'" ["ች����"])

 ("`he" ?ኀ)
 ("`hu" ?ኁ)
 ("`hi" ?ኂ)
 ("`ha" ?ኃ)
 ("`hE" ?ኄ)
 ("`hee" ?ኄ)
 ("`h" ?ኅ)
 ("`ho" ?ኆ)
 ("`hWe" ?ኈ)
 ("`hWu" ?ኍ)
 ("`hWi" ?ኊ)
 ("`hW" ?ኋ)
 ("`hWa" ?ኋ)
 ("`hWE" ?ኌ)
 ("`hWee" ?ኌ)
 ("`hW'" ?ኍ)

 ("h2e" ?ኀ)
 ("h2u" ?ኁ)
 ("h2i" ?ኂ)
 ("h2a" ?ኃ)
 ("h2E" ?ኄ)
 ("h2ee" ?ኄ)
 ("h2" ?ኅ)
 ("h2o" ?ኆ)
 ("h2We" ?ኈ)
 ("h2Wu" ?ኍ)
 ("h2Wi" ?ኊ)
 ("h2W" ?ኋ)
 ("h2Wa" ?ኋ)
 ("h2WE" ?ኌ)
 ("h2Wee" ?ኌ)
 ("h2W'" ?ኍ)

 ("hhe" ?ኀ)
 ("hhu" ?ኁ)
 ("hhi" ?ኂ)
 ("hha" ?ኃ)
 ("hhE" ?ኄ)
 ("hhee" ?ኄ)
 ("hh" ?ኅ)
 ("hho" ?ኆ)
 ("hhWe" ?ኈ)
 ("hhWu" ?ኍ)
 ("hhWi" ?ኊ)
 ("hhW" ?ኋ)
 ("hhWa" ?ኋ)
 ("hhWE" ?ኌ)
 ("hhWee" ?ኌ)
 ("hhW'" ?ኍ)

 ("ne" ?ነ)
 ("nu" ?ኑ)
 ("ni" ?ኒ)
 ("na" ?ና)
 ("nE" ?ኔ)
 ("nee" ?ኔ)
 ("n" ?ን)
 ("no" ?ኖ)
 ("nW" ?ኗ)
 ("nWa" ?ኗ)
 ("nWe" ["ን����"])
 ("nWu" ["ን����"])
 ("nWi" ["ን����"])
 ("nWE" ["ን����"])
 ("nWee" ["ን����"])
 ("nW'" ["ን����"])

 ("Ne" ?ኘ)
 ("Nu" ?ኙ)
 ("Ni" ?ኚ)
 ("Na" ?ኛ)
 ("NE" ?ኜ)
 ("Nee" ?ኜ)
 ("N" ?ኝ)
 ("No" ?ኞ)
 ("NW" ?ኟ)
 ("NWa" ?ኟ)
 ("NWe" ["ኝ����"])
 ("NWu" ["ኝ����"])
 ("NWi" ["ኝ����"])
 ("NWE" ["ኝ����"])
 ("NWee" ["ኝ����"])
 ("NW'" ["ኝ����"])

 ; ("e" ?አ) ; old style
 ("u" ?ኡ)
 ("U" ?ኡ)
 ("i" ?ኢ)
 ("a" ?ኣ)
 ("A" ?ኣ)
 ("E" ?ኤ)
 ; ("ee" ?ኤ) ; Alef-E is rare vs Aynu-I, so ee = Aynu-I
 ("I" ?እ)
 ("e" ?እ)    ; This is the premise to "new style" for vowels

 ("o" ?ኦ)
 ("O" ?ኦ)
 ("ea" ?ኧ)

 ("ke" ?ከ)
 ("ku" ?ኩ)
 ("ki" ?ኪ)
 ("ka" ?ካ)
 ("kE" ?ኬ)
 ("kee" ?ኬ)
 ("k" ?ክ)
 ("ko" ?ኮ)
 ("kWe" ?ኰ)
 ("kWu" ?ኵ)
 ("kWi" ?ኲ)
 ("kW" ?ኳ)
 ("kWa" ?ኳ)
 ("kWE" ?ኴ)
 ("kWee" ?ኴ)
 ("kW'" ?ኵ)

 ("`ke" ?����)
 ("`ku" ?����)
 ("`ki" ?����)
 ("`ka" ?����)
 ("`kE" ?����)
 ("`kee" ?����)
 ("`k" ?����)
 ("`ko" ?����)

 ("k2e" ?����)
 ("k2u" ?����)
 ("k2i" ?����)
 ("k2a" ?����)
 ("k2E" ?����)
 ("k2ee" ?����)
 ("k2" ?����)
 ("k2o" ?����)

 ("kke" ?����)
 ("kku" ?����)
 ("kki" ?����)
 ("kka" ?����)
 ("kkE" ?����)
 ("kkee" ?����)
 ("kk" ?����)
 ("kko" ?����)

 ("Ke" ?ኸ)
 ("Ku" ?ኹ)
 ("Ki" ?ኺ)
 ("Ka" ?ኻ)
 ("KE" ?ኼ)
 ("Kee" ?ኼ)
 ("K" ?ኽ)
 ("Ko" ?ኾ)
 ("KWe" ?ዀ)
 ("KWu" ?ዅ)
 ("KWi" ?ዂ)
 ("KW" ?ዃ)
 ("KWa" ?ዃ)
 ("KWE" ?ዄ)
 ("KWee" ?ዄ)
 ("KW'" ?ዅ)

 ("Xe" ?����)
 ("Xu" ?����)
 ("Xi" ?����)
 ("Xa" ?����)
 ("XE" ?����)
 ("Xee" ?����)
 ("X" ?����)
 ("Xo" ?����)

 ("we" ?ወ)
 ("wu" ?ዉ)
 ("wi" ?ዊ)
 ("wa" ?ዋ)
 ("wE" ?ዌ)
 ("wee" ?ዌ)
 ("w" ?ው)
 ("wo" ?ዎ)

 ("`e" ?ዐ)
 ("`u" ?ዑ)
 ("`U" ?ዑ)
 ("`i" ?ዒ)
 ("`a" ?ዓ)
 ("`A" ?ዓ)
 ("`E" ?ዔ)
 ("`ee" ?ዔ)
 ("`I" ?ዕ)
 ("`o" ?ዖ)
 ("`O" ?ዖ)

 ("e2" ?ዐ)
 ("u2" ?ዑ)
 ("U2" ?ዑ)
 ("i2" ?ዒ)
 ("a2" ?ዓ)
 ("A2" ?ዓ)
 ("E2" ?ዔ)
 ("ee2" ?ዔ)
 ("I2" ?ዕ)
 ("o2" ?ዖ)
 ("O2" ?ዖ)

 ; ("ee" ?ዐ) ; old style
 ("ae" ?ዐ)   ; new style
 ("aaa" ?ዐ)  ; new style
 ("uu" ?ዑ)
 ("UU" ?ዑ)
 ("ii" ?ዒ)
 ("aa" ?ዓ)
 ("AA" ?ዓ)
 ("EE" ?ዔ)
 ("II" ?ዕ)
 ("ee" ?ዕ)   ; new style
 ("oo" ?ዖ)
 ("OO" ?ዖ)

 ("ze" ?ዘ)
 ("zu" ?ዙ)
 ("zi" ?ዚ)
 ("za" ?ዛ)
 ("zE" ?ዜ)
 ("zee" ?ዜ)
 ("z" ?ዝ)
 ("zo" ?ዞ)
 ("zW" ?ዟ)
 ("zWa" ?ዟ)
 ("zWe" ["ዝ����"])
 ("zWu" ["ዝ����"])
 ("zWi" ["ዝ����"])
 ("zWE" ["ዝ����"])
 ("zWee" ["ዝ����"])
 ("zW'" ["ዝ����"])

 ("Ze" ?ዠ)
 ("Zu" ?ዡ)
 ("Zi" ?ዢ)
 ("Za" ?ዣ)
 ("ZE" ?ዤ)
 ("Zee" ?ዤ)
 ("Z" ?ዥ)
 ("Zo" ?ዦ)
 ("ZW" ?ዧ)
 ("ZWa" ?ዧ)
 ("ZWe" ["ዥ����"])
 ("ZWu" ["ዥ����"])
 ("ZWi" ["ዥ����"])
 ("ZWE" ["ዥ����"])
 ("ZWee" ["ዥ����"])
 ("ZW'" ["ዥ����"])

 ("ye" ?የ)
 ("yu" ?ዩ)
 ("yi" ?ዪ)
 ("ya" ?ያ)
 ("yE" ?ዬ)
 ("yee" ?ዬ)
 ("y" ?ይ)
 ("yo" ?ዮ)
 ("yW" ?����)
 ("yWa" ?����)
 ("yWe" ["ይ����"])
 ("yWu" ["ይ����"])
 ("yWi" ["ይ����"])
 ("yWE" ["ይ����"])
 ("yWee" ["ይ����"])
 ("yW'" ["ይ����"])

 ("Ye" ?የ)
 ("Yu" ?ዩ)
 ("Yi" ?ዪ)
 ("Ya" ?ያ)
 ("YE" ?ዬ)
 ("Yee" ?ዬ)
 ("Y" ?ይ)
 ("Yo" ?ዮ)
 ("YW" ?����)
 ("YWa" ?����)
 ("YWe" ["ይ����"])
 ("YWu" ["ይ����"])
 ("YWi" ["ይ����"])
 ("YWE" ["ይ����"])
 ("YWee" ["ይ����"])
 ("YW'" ["ይ����"])

 ("de" ?ደ)
 ("du" ?ዱ)
 ("di" ?ዲ)
 ("da" ?ዳ)
 ("dE" ?ዴ)
 ("dee" ?ዴ)
 ("d" ?ድ)
 ("do" ?ዶ)
 ("dW" ?ዷ)
 ("dWa" ?ዷ)
 ("dWe" ["ድ����"])
 ("dWu" ["ድ����"])
 ("dWi" ["ድ����"])
 ("dWE" ["ድ����"])
 ("dWee" ["ድ����"])
 ("dW'" ["ድ����"])

 ("De" ?ዸ)
 ("Du" ?ዹ)
 ("Di" ?ዺ)
 ("Da" ?ዻ)
 ("DE" ?ዼ)
 ("Dee" ?ዼ)
 ("D" ?ዽ)
 ("Do" ?ዾ)
 ("DW" ?ዿ)
 ("DWa" ?ዿ)
 ("DWe" ["ዽ����"])
 ("DWu" ["ዽ����"])
 ("DWi" ["ዽ����"])
 ("DWE" ["ዽ����"])
 ("DWee" ["ዽ����"])
 ("DW'" ["ዽ����"])

 ("je" ?ጀ)
 ("ju" ?ጁ)
 ("ji" ?ጂ)
 ("ja" ?ጃ)
 ("jE" ?ጄ)
 ("jee" ?ጄ)
 ("j" ?ጅ)
 ("jo" ?ጆ)
 ("jW" ?ጇ)
 ("jWa" ?ጇ)
 ("jWe" ["ጅ����"])
 ("jWu" ["ጅ����"])
 ("jWi" ["ጅ����"])
 ("jWE" ["ጅ����"])
 ("jWee" ["ጅ����"])
 ("jW'" ["ጅ����"])

 ("Je" ?ጀ)
 ("Ju" ?ጁ)
 ("Ji" ?ጂ)
 ("Ja" ?ጃ)
 ("JE" ?ጄ)
 ("Jee" ?ጄ)
 ("J" ?ጅ)
 ("Jo" ?ጆ)
 ("JW" ?ጇ)
 ("JWa" ?ጇ)
 ("JWe" ["ጅ����"])
 ("JWu" ["ጅ����"])
 ("JWi" ["ጅ����"])
 ("JWE" ["ጅ����"])
 ("JWee" ["ጅ����"])
 ("JW'" ["ጅ����"])

 ("ge" ?ገ)
 ("gu" ?ጉ)
 ("gi" ?ጊ)
 ("ga" ?ጋ)
 ("gE" ?ጌ)
 ("gee" ?ጌ)
 ("g" ?ግ)
 ("go" ?ጎ)
 ("gWe" ?ጐ)
 ("gWu" ?ጕ)
 ("gWi" ?ጒ)
 ("gW" ?ጓ)
 ("gWa" ?ጓ)
 ("gWE" ?ጔ)
 ("gWee" ?ጔ)
 ("gW'" ?ጕ)

 ("`ge" ?����)
 ("`gu" ?����)
 ("`gi" ?����)
 ("`ga" ?����)
 ("`gE" ?����)
 ("`gee" ?����)
 ("`g" ?����)
 ("`go" ?����)

 ("g2e" ?����)
 ("g2u" ?����)
 ("g2i" ?����)
 ("g2a" ?����)
 ("g2E" ?����)
 ("g2ee" ?����)
 ("g2" ?����)
 ("g2o" ?����)

 ("gge" ?����)
 ("ggu" ?����)
 ("ggi" ?����)
 ("gga" ?����)
 ("ggE" ?����)
 ("ggee" ?����)
 ("gg" ?����)
 ("ggo" ?����)

 ("Ge" ?ጘ)
 ("Gu" ?ጙ)
 ("Gi" ?ጚ)
 ("Ga" ?ጛ)
 ("GE" ?ጜ)
 ("Gee" ?ጜ)
 ("G" ?ጝ)
 ("Go" ?ጞ)
 ("GWe" ?����)
 ("GWu" ?����)
 ("GWi" ?����)
 ("GW" ?����)
 ("GWa" ?����)
 ("GWE" ?����)
 ("GWee" ?����)
 ("GW'" ?����)

 ("Te" ?ጠ)
 ("Tu" ?ጡ)
 ("Ti" ?ጢ)
 ("Ta" ?ጣ)
 ("TE" ?ጤ)
 ("Tee" ?ጤ)
 ("T" ?ጥ)
 ("To" ?ጦ)
 ("TW" ?ጧ)
 ("TWa" ?ጧ)
 ("TWe" ["ጥ����"])
 ("TWu" ["ጥ����"])
 ("TWi" ["ጥ����"])
 ("TWE" ["ጥ����"])
 ("TWee" ["ጥ����"])
 ("TW'" ["ጥ����"])

 ("Ce" ?ጨ)
 ("Cu" ?ጩ)
 ("Ci" ?ጪ)
 ("Ca" ?ጫ)
 ("CE" ?ጬ)
 ("Cee" ?ጬ)
 ("C" ?ጭ)
 ("Co" ?ጮ)
 ("CW" ?ጯ)
 ("CWa" ?ጯ)
 ("CWe" ["ጭ����"])
 ("CWu" ["ጭ����"])
 ("CWi" ["ጭ����"])
 ("CWE" ["ጭ����"])
 ("CWee" ["ጭ����"])
 ("CW'" ["ጭ����"])

 ("Pe" ?ጰ)
 ("Pu" ?ጱ)
 ("Pi" ?ጲ)
 ("Pa" ?ጳ)
 ("PE" ?ጴ)
 ("Pee" ?ጴ)
 ("P" ?ጵ)
 ("Po" ?ጶ)
 ("PW" ?ጷ)
 ("PWa" ?ጷ)
 ("PWe" ["ጵ����"])
 ("PWu" ["ጵ����"])
 ("PWi" ["ጵ����"])
 ("PWE" ["ጵ����"])
 ("PWee" ["ጵ����"])
 ("PW'" ["ጵ����"])

 ("Se" ?ጸ)
 ("Su" ?ጹ)
 ("Si" ?ጺ)
 ("Sa" ?ጻ)
 ("SE" ?ጼ)
 ("See" ?ጼ)
 ("S" ?ጽ)
 ("So" ?ጾ)
 ("SW" ?ጿ)
 ("SWa" ?ጿ)
 ("SWe" ["ጽ����"])
 ("SWu" ["ጽ����"])
 ("SWi" ["ጽ����"])
 ("SWE" ["ጽ����"])
 ("SWee" ["ጽ����"])
 ("SW'" ["ጽ����"])

 ("`Se" ?ፀ)
 ("`Su" ?ፁ)
 ("`Si" ?ፂ)
 ("`Sa" ?ፃ)
 ("`SE" ?ፄ)
 ("`See" ?ፄ)
 ("`S" ?ፅ)
 ("`So" ?ፆ)
 ("`SW" ?ጿ)
 ("`SWa" ?ጿ)
 ("`SWe" ["ፅ����"])
 ("`SWu" ["ፅ����"])
 ("`SWi" ["ፅ����"])
 ("`SWE" ["ፅ����"])
 ("`SWee" ["ፅ����"])
 ("`SW'" ["ፅ����"])

 ("S2e" ?ፀ)
 ("S2u" ?ፁ)
 ("S2i" ?ፂ)
 ("S2a" ?ፃ)
 ("S2E" ?ፄ)
 ("S2ee" ?ፄ)
 ("S2" ?ፅ)
 ("S2o" ?ፆ)
 ("S2W" ?ጿ)
 ("S2Wa" ?ጿ)
 ("S2We" ["ፅ����"])
 ("S2Wu" ["ፅ����"])
 ("S2Wi" ["ፅ����"])
 ("S2WE" ["ፅ����"])
 ("S2Wee" ["ፅ����"])
 ("S2W'" ["ፅ����"])

 ("SSe" ?ፀ)
 ("SSu" ?ፁ)
 ("SSi" ?ፂ)
 ("SSa" ?ፃ)
 ("SSE" ?ፄ)
 ("SSee" ?ፄ)
 ("SS" ?ፅ)
 ("SSo" ?ፆ)
 ("SSW" ?ጿ)
 ("SSWa" ?ጿ)
 ("SSWe" ["ፅ����"])
 ("SSWu" ["ፅ����"])
 ("SSWi" ["ፅ����"])
 ("SSWE" ["ፅ����"])
 ("SSWee" ["ፅ����"])
 ("SW'" ["ፅ����"])

 ("fe" ?ፈ)
 ("fu" ?ፉ)
 ("fi" ?ፊ)
 ("fa" ?ፋ)
 ("fE" ?ፌ)
 ("fee" ?ፌ)
 ("f" ?ፍ)
 ("fo" ?ፎ)
 ("fWe" ?����)
 ("fWu" ?����)
 ("fWi" ?����)
 ("fW" ?ፏ)
 ("fWa" ?ፏ)
 ("fWE" ?����)
 ("fWee" ?����)
 ("fW'" ?����)
 ("fY" ?ፚ)
 ("fYa" ?ፚ)

 ("Fe" ?ፈ)
 ("Fu" ?ፉ)
 ("Fi" ?ፊ)
 ("Fa" ?ፋ)
 ("FE" ?ፌ)
 ("Fee" ?ፌ)
 ("F" ?ፍ)
 ("Fo" ?ፎ)
 ("FWe" ?����)
 ("FWu" ?����)
 ("FWi" ?����)
 ("FW" ?ፏ)
 ("FWa" ?ፏ)
 ("FWE" ?����)
 ("FWee" ?����)
 ("FW'" ?����)
 ("FY" ?ፚ)
 ("FYa" ?ፚ)

 ("pe" ?ፐ)
 ("pu" ?ፑ)
 ("pi" ?ፒ)
 ("pa" ?ፓ)
 ("pE" ?ፔ)
 ("pee" ?ፔ)
 ("p" ?ፕ)
 ("po" ?ፖ)
 ("pWe" ?����)
 ("pWu" ?����)
 ("pWi" ?����)
 ("pW" ?ፗ)
 ("pWa" ?ፗ)
 ("pWE" ?����)
 ("pWee" ?����)
 ("pW'" ?����)

 ("'" [""])
 ("''" ?')
 (":" ?፡)
 ("::" ?።)
 (":::" ?:)
 ("." ?።)
 (".." ?����)
 ("..." ?.)
 ("," ?፣)
 (",," ?,)
 (";" ?፤)
 (";;" ?\;)
 ("-:" ?፥)
 (":-" ?፦)
 ("*" ?*)
 ("**" ?፨)
 (":|:" ?፨)
 ("?" ?����)
 ("??" ?፧)
 ("`?" ?፧)
 ("???" ??)
 ("<<" ?����)
 (">>" ?����)
 ("`!" ?����)
 ("wWe" ?����)
 ("wWu" ?����)
 ("wWi" ?����)
 ("wW" ?����)
 ("wWa" ?����)
 ("wWE" ?����)
 ("wWee" ?����)
 ("wW'" ?����)
 ("We" ?����)
 ("Wu" ?����)
 ("Wi" ?����)
 ("W" ?����)
 ("Wa" ?����)
 ("WE" ?����)
 ("Wee" ?����)
 ("W'" ?����)
 ("`1" ?፩)
 ("`2" ?፪)
 ("`3" ?፫)
 ("`4" ?፬)
 ("`5" ?፭)
 ("`6" ?፮)
 ("`7" ?፯)
 ("`8" ?፰)
 ("`9" ?፱)
 ("`10" ?፲)
 ("`20" ?፳)
 ("`30" ?፴)
 ("`40" ?፵)
 ("`50" ?፶)
 ("`60" ?፷)
 ("`70" ?፸)
 ("`80" ?፹)
 ("`90" ?፺)
 ("`100" ?፻)
 ("`1000" ["፲፻"])
 ("`2000" ["፳፻"])
 ("`3000" ["፴፻"])
 ("`4000" ["፵፻"])
 ("`5000" ["፶፻"])
 ("`6000" ["፷፻"])
 ("`7000" ["፸፻"])
 ("`8000" ["፹፻"])
 ("`9000" ["፺፻"])
 ("`10000" ?፼)
 ("`20000" ["፪፼"])
 ("`30000" ["፫፼"])
 ("`40000" ["፬፼"])
 ("`50000" ["፭፼"])
 ("`60000" ["፮፼"])
 ("`70000" ["፯፼"])
 ("`80000" ["፰፼"])
 ("`90000" ["፱፼"])
 ("`100000" ["፲፼"])
 ("`200000" ["፳፼"])
 ("`300000" ["፴፼"])
 ("`400000" ["፵፼"])
 ("`500000" ["፶፼"])
 ("`600000" ["፷፼"])
 ("`700000" ["፸፼"])
 ("`800000" ["፹፼"])
 ("`900000" ["፺፼"])
 ("`1000000" ["፻፼"])
)

(defun ethio-select-a-translation ()
  ;; The translation of `a' depends on the language
  ;; (either Tigrigna or Amharic).
  (quail-defrule "a"
		 (if (ethio-prefer-amharic-p) ?አ ?ኣ)
		 "ethiopic"))

;;; ethiopic.el ends here

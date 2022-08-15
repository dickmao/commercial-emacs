;; Some efforts were spent to have it somewhat compatible with
;; `compilation-minor-mode'.
(defcustom diff-whitespace-style '(face trailing)
  "Specify `whitespace-style' variable for `diff-mode' buffers."
  :require 'whitespace
  :type (get 'whitespace-style 'custom-type)
  :version "29.1")

        (when (re-search-forward regexp-file (line-end-position 4) t) ; File header.
(defvar whitespace-style)
(defvar whitespace-trailing-regexp)

  (setq-local whitespace-style diff-whitespace-style)
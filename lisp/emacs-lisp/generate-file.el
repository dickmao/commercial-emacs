;;; generate-file.el --- utility functions for generated files  -*- lexical-binding: t -*-

;; Copyright (C) 2022 Free Software Foundation, Inc.

;; Keywords: maint
;; Package: emacs

;; This file is part of GNU Emacs.

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

;;; Commentary:

;;; Code:

(eval-when-compile (require 'cl-lib))

(cl-defun generate-file-heading (file &key description text (code t))
  "Insert a standard header for FILE.
This header will specify that this is a generated file that
should not be edited.

If `standard-output' is bound to a buffer, insert in that buffer.
If no, insert at point in the current buffer.

DESCRIPTION (if any) will be used in the first line.

TEXT (if given) will be inserted as a comment.

If CODE is non-nil (which is the default), a Code: line is
inserted."
  (with-current-buffer (if (bufferp standard-output)
                           standard-output
                         (current-buffer))
    (insert ";;; " (file-name-nondirectory file)
            " --- "
            (or description "automatically generated")
            " (do not edit) "
            "  -*- lexical-binding: t -*-\n\n"
            ";; This file is part of GNU Emacs.\n\n")
    (when text
      (insert ";;; Commentary:\n\n")
      (let ((start (point))
            (fill-prefix ";; "))
        (insert ";; " text)
        (fill-region start (point))))
    (ensure-empty-lines 1)
    (when code
      (insert ";;; Code:\n\n"))))

(cl-defun generate-file-trailer (file &key version inhibit-provide
                                      (coding 'utf-8-emacs-unix) autoloads
                                      compile provide)
  "Insert a standard trailer for FILE.
By default, this trailer inhibits version control, byte
compilation, updating autoloads, and uses a `utf-8-emacs-unix'
coding system.  These can be inhibited by providing non-nil
values to the VERSION, NO-PROVIDE, AUTOLOADS and COMPILE
keyword arguments.

CODING defaults to `utf-8-emacs-unix'.  Use a nil value to
inhibit generating this setting, or a coding system value to use
that.

If PROVIDE is non-nil, use that in the `provide' statement
instead of using FILE as the basis.

If `standard-output' is bound to a buffer, insert in that buffer.
If no, insert at point in the current buffer."
  (with-current-buffer (if (bufferp standard-output)
                           standard-output
                         (current-buffer))
    (ensure-empty-lines 1)
    (unless inhibit-provide
      (insert (format "(provide '%s)\n\n"
                      (or provide
	                  (file-name-sans-extension
                           (file-name-nondirectory file))))))
    ;; Some of the strings below are chopped into bits to inhibit
    ;; automatic scanning tools from thinking that they are actual
    ;; directives.
    (insert ";; Local " "Variables:\n")
    (unless version
      (insert ";; version-control: never\n"))
    (unless compile
      (insert ";; no-byte-" "compile: t\n")) ;; #$ is byte-compiled into nil.
    (unless autoloads
      (insert ";; no-update-autoloads: t\n"))
    (when coding
      (insert (format ";; coding: %s\n"
                      (if (eq coding t)
                          'utf-8-emacs-unix
                        coding))))
    (insert
     ";; End:\n\n"
     ";;; " (file-name-nondirectory file) " ends here\n")))

(provide 'generate-file)

;;; generate-file.el ends here

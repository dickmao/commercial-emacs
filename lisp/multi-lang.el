;;; multi-lang.el --- One buffer, multiple major modes  -*- lexical-binding:t -*-

(defgroup multi-lang nil
  "Multiple language modes in buffer."
  :version "31.1"
  :group 'convenience)

(defface multi-lang '((t :inherit highlight :extend t))
  "Default face for `multi-lang-face'."
  :version "31.1"
  :group 'multi-lang)

(defcustom multi-lang-face 'multi-lang
  "Demarcate multi-lang overlay."
  :type 'face
  :group 'multi-lang
  :set (lambda (symbol value)
	 (set symbol value)
	 (dolist (b (buffer-list))
	   (with-current-buffer b
             ;; (mapc (lambda (ov) (overlay-put ov 'face multi-lang-face)) overlays)
             ))))

(provide 'multi-lang)

;;; multi-lang.el ends here

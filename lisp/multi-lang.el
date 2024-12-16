;;; multi-lang.el --- One buffer, multiple major modes  -*- lexical-binding:t -*-

(defgroup multi-lang nil
  "Multiple language modes in buffer."
  :version "31.1"
  :group 'convenience)

(defface multi-lang '((t :inherit highlight :extend t))
  "Default face for `multi-lang-face'."
  :version "31.1"
  :group 'multi-lang)

(defcustom multi-lang-face-alist nil
  "Demarcate multi-lang overlay."
  :type '(alist :key-type (symbol :tag "Major mode")
                :value-type (symbol :tag "Face"))
  :group 'multi-lang)

(defsubst multi-lang-p (overlay)
  (overlay-get overlay 'multi-lang-p))

(defun delete-multi-lang-overlay (beg)
  "Remove all multi-lang overlays at BEG."
  (interactive "d")
  (dolist (ov (overlays-at beg))
    (when (multi-lang-p ov)
      (let ((font-lock-extra-managed-props
             (cons 'fontified font-lock-extra-managed-props))
            (beg (overlay-start ov))
            (end (overlay-end ov))
            (modified (buffer-modified-p)))
        ;; Eschew `with-silent-modifications' since precision required.
        (unwind-protect
            (progn
              (delete-overlay ov)
              (font-lock-unfontify-region beg end))
          (when (memq modified '(nil autosaved))
            (restore-buffer-modified-p modified)))))))

(defun make-multi-lang-overlay (beg end mode)
  "Return indirect buffer with major mode MODE.
The macro `with-silent-modifications' is unused
as we require surgical precision on `buffer-undo-list'."
  (interactive
   (list (if (region-active-p) (region-beginning) (point))
         (if (region-active-p) (region-end) (point))
         (intern-soft
          (completing-read
           "Mode: "
           (let (modes)
             (mapatoms
              (lambda (sym)
                (when (provided-mode-derived-p sym '(prog-mode))
                  (push sym modes)))) modes)
           nil t))))
  (if (or (null mode) (string-empty-p (symbol-name mode)))
      (keyboard-quit)
    ;; Eschew `with-silent-modifications' since precision required.
    (let ((modified (buffer-modified-p)))
      (unwind-protect
          (let ((font-lock-extra-managed-props
                 (cons 'fontified font-lock-extra-managed-props)))
            (font-lock-unfontify-region beg end)
            (make-multi-lang--overlay beg end mode))
        (when (memq modified '(nil autosaved))
          (restore-buffer-modified-p modified))))))

(defalias 'multi-lang-on-switch-to-buffer
  (lambda (_window)
    (mapc (lambda (ov) (funcall (or (overlay-on-enter ov) #'ignore) ov))
          (overlays-at (point))))
  "A hook in `window-buffer-change-functions' to immediately switch
to the appropriate indirect buffer.")

(provide 'multi-lang)

;;; multi-lang.el ends here

;;; image-dired-external.el --- External process support for Image-Dired  -*- lexical-binding: t -*-

;; Copyright (C) 2005-2024 Free Software Foundation, Inc.

;; Author: Mathias Dahl <mathias.rem0veth1s.dahl@gmail.com>
;; Maintainer: Stefan Kangas <stefankangas@gmail.com>
;; Keywords: multimedia
;; Package: image-dired

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

;;; Commentary:

;; See the description of the `image-dired' package.

;;; Code:

(require 'dired)
(require 'exif)

(require 'image-dired-util)

(declare-function image-dired-display-image "image-dired")
(declare-function clear-image-cache "image.c" (&optional filter))
(declare-function w32image-create-thumbnail "w32image.c")

(defvar image-dired-dir)
(defvar image-dired-thumb-size)
(defvar image-dired-main-image-directory)
(defvar image-dired-rotate-original-ask-before-overwrite)
(defvar image-dired-thumbnail-storage)

(defgroup image-dired-external nil
  "External process support for Image-Dired."
  :prefix "image-dired-"
  :link '(info-link "(emacs) Image-Dired")
  :group 'image-dired)

(defcustom image-dired-cmd-create-thumbnail-program
  (if (executable-find "gm") "gm" "convert")
  "File name of the executable used to create thumbnails.
Used together with `image-dired-cmd-create-thumbnail-options'.
On MS-Windows, if such an executable is not available, Emacs
will use `w32image-create-thumbnail' to create thumbnails."
  :type 'file
  :version "29.1")

(defcustom image-dired-cmd-create-thumbnail-options
  (let ((opts '("-size" "%wx%h" "%f[0]"
                "-resize" "%wx%h>"
                "-strip" "jpeg:%t")))
    (if (executable-find "gm") (cons "convert" opts) opts))
  "Options of command used to create thumbnail image.
Used with `image-dired-cmd-create-thumbnail-program', if that is
available.
Available format specifiers are:
    %s, %w and %h, which are replaced by `image-dired-thumb-size'
    %f which is replaced by the file name of the original image and
    %t which is replaced by the file name of the thumbnail file."
  :type '(repeat (string :tag "Argument"))
  :version "29.1")

(defcustom image-dired-cmd-pngnq-program
  ;; Prefer pngquant to pngnq-s9 as it is faster on my machine.
  ;;   The project also seems more active than the alternatives.
  ;; Prefer pngnq-s9 to pngnq as it fixes bugs in pngnq.
  ;; The pngnq project seems dead (?) since 2011 or so.
  (or (executable-find "pngquant")
      (executable-find "pngnq-s9")
      (executable-find "pngnq"))
  "The executable file name of the `pngquant' or `pngnq' program.
It quantizes colors of PNG images down to 256 colors or fewer
using the NeuQuant algorithm."
  :version "29.1"
  :type '(choice (const :tag "Not Set" nil) file))

(defcustom image-dired-cmd-pngnq-options
  (if (executable-find "pngquant")
      '("--ext" "-nq8.png" "%t") ; same extension as "pngnq"
    '("-f" "%t"))
  "Arguments to pass to `image-dired-cmd-pngnq-program'.
Value can use the same format specifiers as in
`image-dired-cmd-create-thumbnail-options'."
  :type '(repeat (string :tag "Argument"))
  :version "29.1")

(defcustom image-dired-cmd-pngcrush-program (executable-find "pngcrush")
  "The executable file name of the `pngcrush' program.
It optimizes the compression of PNG images.  It also adds PNG textual chunks
with the information required by the Thumbnail Managing Standard."
  :type '(choice (const :tag "Not Set" nil) file))

;; Note: the "-text" arguments below are according to specification in
;; https://specifications.freedesktop.org/thumbnail-spec/thumbnail-spec-latest.html#CREATION
(defcustom image-dired-cmd-pngcrush-options
  `("-q"
    "-text" "b" "Description" "Thumbnail of file://%u"
    "-text" "b" "Software" ,(string-replace "\n" " " (emacs-version))
    ;; "-text b \"Thumb::Image::Height\" \"%oh\" "
    ;; "-text b \"Thumb::Image::Mimetype\" \"%mime\" "
    ;; "-text b \"Thumb::Image::Width\" \"%ow\" "
    "-text" "b" "Thumb::MTime" "%m"
    ;; "-text b \"Thumb::Size\" \"%b\" "
    "-text" "b" "Thumb::URI" "file://%u"
    "%q" "%t")
  "Arguments for `image-dired-cmd-pngcrush-program'.
The value can use the same %-format specifiers as in
`image-dired-cmd-create-thumbnail-options', with \"%q\" standing for a
temporary file name (typically generated by pnqnq),
and \"%u\" standing for a file URI corresponding to file in \"%f\"."
  :version "26.1"
  :type '(repeat (string :tag "Argument")))

(defcustom image-dired-cmd-optipng-program (executable-find "optipng")
  "The executable file name of the `optipng' program."
  :version "26.1"
  :type '(choice (const :tag "Not Set" nil) file))

(defcustom image-dired-cmd-optipng-options '("-o5" "%t")
  "Arguments passed to `image-dired-cmd-optipng-program'.
The value can use the same %-format specifiers as in
`image-dired-cmd-create-thumbnail-options'."
  :version "26.1"
  :type '(repeat (string :tag "Argument"))
  :link '(url-link "man:optipng(1)"))

;; Note: the "-set" arguments below are according to specification in
;; https://specifications.freedesktop.org/thumbnail-spec/thumbnail-spec-latest.html#CREATION
(defcustom image-dired-cmd-create-standard-thumbnail-options
  (let ((opts (list
               "-size" "%wx%h" "%f[0]"
               "-set" "Thumb::MTime" "%m"
               "-set" "Thumb::URI" "file://%u"
               "-set" "Description" "Thumbnail of file://%u"
               "-set" "Software" (string-replace "\n" " " (emacs-version))
               "-thumbnail" "%wx%h>" "png:%t")))
    (if (executable-find "gm") (cons "convert" opts) opts))
  "Options for creating thumbnails according to the Thumbnail Managing Standard.
Used with `image-dired-cmd-create-thumbnail-program', if that is available.
The value can use the same %-format specifiers as in
`image-dired-cmd-create-thumbnail-options', with \"%m\" for file
modification time and \"%u\" for the URI of the file in \"%f\".
On MS-Windows, if the `convert' command is not available, and
`w32image-create-thumbnail' is used instead, the textual chunks
specified by the \"-set\" options will not be injected, and instead
they are added by `pngcrush' if that is available."
  :type '(repeat (string :tag "Argument"))
  :version "29.1")

(defcustom image-dired-cmd-rotate-original-program "jpegtran"
  "Executable file of a program used to rotate original image.
Used together with `image-dired-cmd-rotate-original-options'."
  :type 'file)

(defcustom image-dired-cmd-rotate-original-options
  '("-rotate" "%d" "-copy" "all" "-outfile" "%t" "%o")
  "Arguments of command used to rotate original image.
Used with `image-dired-cmd-rotate-original-program'.
The value can use the following format specifiers:
%d which is replaced by the number of (positive) degrees
to rotate the image, normally 90 or 270 (for 90 degrees right and left),
%o which is replaced by the original image file name
and %t which is replaced by `image-dired-temp-image-file'."
  :version "26.1"
  :type '(repeat (string :tag "Argument")))

(defcustom image-dired-temp-rotate-image-file
  (expand-file-name ".image-dired_rotate_temp"
                    (locate-user-emacs-file "image-dired/"))
  "Temporary file for image rotation operations."
  :type 'file)

(defcustom image-dired-cmd-write-exif-data-program "exiftool"
  "Executable file of a program used to write EXIF data to images.
Used together with `image-dired-cmd-write-exif-data-options'."
  :type 'file)

(defcustom image-dired-cmd-write-exif-data-options '("-%t=%v" "%f")
  "Arguments of the command used to write EXIF data.
Used with `image-dired-cmd-write-exif-data-program'.
The value can use the following format specifiers are:
%f which is replaced by the image file name,
%t which is replaced by the tag name
and %v which is replaced by the tag value."
  :version "26.1"
  :type '(repeat (string :tag "Argument")))


;;; Util functions

(defun image-dired--file-URI (file)
  ;; https://en.wikipedia.org/wiki/File_URI_scheme
  (if (memq system-type '(windows-nt ms-dos))
      (concat "/" file)
    file))

(defun image-dired--probe-thumbnail-cmd (cmd)
  "Check whether CMD is usable for thumbnail creation."
  (cond
   ;; MS-Windows has an incompatible 'convert' command.  Make sure this
   ;; is the one we expect, from ImageMagick.  FIXME: Should we do this
   ;; also on systems other than MS-Windows?
   ((and (memq system-type '(windows-nt cygwin ms-dos))
         (member (downcase (file-name-nondirectory cmd))
                 '("convert" "convert.exe")))
    (with-temp-buffer
      (let (process-file-side-effects)
        (and (equal (condition-case nil
                        ;; Implementation note: 'process-file' below
                        ;; returns non-zero status when convert.exe is
                        ;; the Windows command, because we quote the
                        ;; "/?" argument, and Windows is not smart
                        ;; enough to process quoted options correctly.
		        (apply #'process-file cmd nil t nil '("/?"))
		      (error nil))
		    0)
	     (progn
	       (goto-char (point-min))
	       (looking-at-p "Version: ImageMagick"))))))
   (t t)))

(defun image-dired--check-executable-exists (executable &optional func)
  "If program EXECUTABLE does not exist or cannot be used, signal an error.
But if optional argument FUNC (which must be a symbol) names a known
function, consider that function to be an alternative to running EXECUTABLE."
  (let ((cmd (symbol-value executable)))
    (or (and (executable-find cmd)
             (image-dired--probe-thumbnail-cmd cmd))
        (and func (fboundp func) 'function)
        (error "Executable %S not found or not pertinent" executable))))


;;; Creating thumbnails

(defun image-dired--thumb-size (&optional _)
  "Return thumb size depending on `image-dired-thumbnail-storage'."
  (declare (advertised-calling-convention () "29.1"))
  (pcase image-dired-thumbnail-storage
    ('standard 128)
    ('standard-large 256)
    ('standard-x-large 512)
    ('standard-xx-large 1024)
    (_ image-dired-thumb-size)))

(defvar image-dired--generate-thumbs-start nil
  "Time when `display-thumbs' was called.")

(defvar image-dired-queue nil
  "List of items in the Image-Dired queue.
Each item has the form (ORIGINAL-FILE TARGET-FILE).")

(defvar image-dired-queue-active-jobs 0
  "Number of active jobs in `image-dired-queue'.")

(defvar image-dired-queue-active-limit (min 4 (max 2 (/ (num-processors) 2)))
  "Maximum number of concurrent jobs permitted for generating images.
Increase at your own risk.  If you want to experiment with this,
consider setting `image-dired-debug' to a non-nil value to see
the time spent on generating thumbnails.  Run `clear-image-cache'
and remove the cached thumbnail files between each trial run.
This is unused on MS-Windows when `w32image-create-thumbnail' is
used instead of ImageMagick or GraphicsMagick commands.
In addition, even if those commands are available, the actual number
of concurrent jobs will be limited by 30 from above, since Emacs
on MS-Windows cannot have too many concurrent sub-processes.")

(defun image-dired-pngnq-thumb (spec)
  "Quantize thumbnail described by format SPEC with command `pngnq'."
  (let* ((snt
          (lambda (process status)
            (if (or (and (processp process) ; async case
                         (eq (process-status process) 'exit)
                         (zerop (process-exit-status process)))
                    (zerop status))     ; sync case
                ;; Pass off to pngcrush, or just rename the
                ;; THUMB-nq8.png file back to THUMB.png
                (if (and image-dired-cmd-pngcrush-program
                         (executable-find image-dired-cmd-pngcrush-program))
                    (image-dired-pngcrush-thumb spec)
                  (let ((nq8 (cdr (assq ?q spec)))
                        (thumb (cdr (assq ?t spec))))
                    (rename-file nq8 thumb t)))
              (if (processp process)
                  (message "command %S %s" (process-command process)
                           (string-replace "\n" "" status))))))
         (proc
          (let ((args (mapcar (lambda (arg) (format-spec arg spec))
                              image-dired-cmd-pngnq-options)))
            (if (eq system-type 'windows-nt)
                ;; Cannot safely use 'start-process' here, since awe
                ;; could be called to produce thumbnails for many
                ;; images, and we have a hard limitation of 32
                ;; simultaneous sub-processes on MS-Windows.
                (apply #'call-process
                       image-dired-cmd-pngnq-program nil nil nil args)
              (apply #'start-process
                     "image-dired-pngnq" nil
                     image-dired-cmd-pngnq-program args)))))
    (if (processp proc)
        (setf (process-sentinel proc) snt)
      (unless (zerop proc)
        (message "command %S failed" image-dired-cmd-pngnq-program))
      (funcall snt image-dired-cmd-pngnq-program proc))
    proc))

(defun image-dired-pngcrush-thumb (spec)
  "Optimize thumbnail described by format SPEC with command `pngcrush'."
  ;; If pngnq wasn't run, then the THUMB-nq8.png file does not exist.
  ;; pngcrush needs an infile and outfile, so we just copy THUMB to
  ;; THUMB-nq8.png and use the latter as a temp file.
  (when (not image-dired-cmd-pngnq-program)
    (let ((temp (cdr (assq ?q spec)))
          (thumb (cdr (assq ?t spec))))
      (copy-file thumb temp)))
  (let* ((args (mapcar
                (lambda (arg)
                  (format-spec arg spec))
                image-dired-cmd-pngcrush-options))
         (snt (lambda (process status)
                (unless (or (and (processp process)
                                 (eq (process-status process) 'exit)
                                 (zerop (process-exit-status process)))
                            (zerop status))
                  (if (processp process)
                      (message "command %S %s" (process-command process)
                               (string-replace "\n" "" status))
                    (message "command %S failed with status %s"
                             process status)))
                (when (or (not (processp process))
                          (memq (process-status process) '(exit signal)))
                  (let ((temp (cdr (assq ?q spec))))
                    (delete-file temp)))))
         (proc
          (if (eq system-type 'windows-nt)
              ;; See above for the reasons we don't use 'start-process'
              ;; on MS-Windows.
              (apply #'call-process
                     image-dired-cmd-pngcrush-program nil nil nil args)
            (apply #'start-process "image-dired-pngcrush" nil
                   image-dired-cmd-pngcrush-program args))))
    (if (processp proc)
        (setf (process-sentinel proc) snt)
      (funcall snt image-dired-cmd-pngcrush-program proc))
    proc))

(defun image-dired-optipng-thumb (spec)
  "Optimize thumbnail described by format SPEC with command `optipng'."
  (let* ((args (mapcar
                (lambda (arg)
                  (format-spec arg spec))
                image-dired-cmd-optipng-options))
         (snt (lambda (process status)
                (unless (or (and (processp process)
                                 (eq (process-status process) 'exit)
                                 (zerop (process-exit-status process)))
                            (zerop status))
                  (if (processp process)
                      (message "command %S %s" (process-command process)
                               (string-replace "\n" "" status))
                    (message "command %S failed with status %s"
                             process status)))))
         (proc
          (if (eq system-type 'windows-nt)
              ;; See above for the reasons we don't use 'start-process'
              ;; on MS-Windows.
              (apply #'call-process
                     image-dired-cmd-optipng-program nil nil nil args)
            (apply #'start-process "image-dired-optipng" nil
                   image-dired-cmd-optipng-program args))))
    (if (processp proc)
        (setf (process-sentinel proc) snt)
      (funcall snt image-dired-cmd-optipng-program proc))
    proc))

(defun image-dired-create-thumb-1 (original-file thumbnail-file)
  "For ORIGINAL-FILE, create thumbnail image named THUMBNAIL-FILE."
  (let* ((size (number-to-string (image-dired--thumb-size)))
         (modif-time (format-time-string
                      "%s" (file-attribute-modification-time
                            (file-attributes original-file))))
         (thumbnail-nq8-file (replace-regexp-in-string ".png\\'" "-nq8.png"
                                                       thumbnail-file))
         (spec `((?s . ,size) (?w . ,size) (?h . ,size)
                 (?m . ,modif-time)
                 (?f . ,original-file)
                 (?u . ,(image-dired--file-URI original-file))
                 (?q . ,thumbnail-nq8-file)
                 (?t . ,thumbnail-file)))
         (thumbnail-dir (file-name-directory thumbnail-file))
         process)
    (when (not (file-exists-p thumbnail-dir))
      (with-file-modes #o700
        (make-directory thumbnail-dir t))
      (message "Thumbnail directory created: %s" thumbnail-dir))

    ;; Thumbnail file creation processes begin here and are marshaled
    ;; in a queue by `image-dired-create-thumb'.
    (let ((cmd image-dired-cmd-create-thumbnail-program)
          (args (mapcar
                 (lambda (arg) (format-spec arg spec))
                 (if (memq image-dired-thumbnail-storage
                           image-dired--thumbnail-standard-sizes)
                     image-dired-cmd-create-standard-thumbnail-options
                   image-dired-cmd-create-thumbnail-options))))
      (image-dired-debug "Running %s %s" cmd (string-join args " "))
      (setq process
            (apply #'start-process "image-dired-create-thumbnail" nil
                   cmd args)))

    (setf (process-sentinel process)
          (lambda (process status)
            ;; Trigger next in queue once a thumbnail has been created
            (cl-decf image-dired-queue-active-jobs)
            (image-dired-thumb-queue-run)
            (when (= image-dired-queue-active-jobs 0)
              (image-dired-debug
               (format-time-string
                "Generated thumbnails in %s.%3N seconds"
                (time-subtract nil
                               image-dired--generate-thumbs-start))))
            (if (not (and (eq (process-status process) 'exit)
                          (zerop (process-exit-status process))))
                (message "Thumb could not be created for %s: %s"
                         (abbreviate-file-name original-file)
                         (string-replace "\n" "" status))
              (set-file-modes thumbnail-file #o600)
              (clear-image-cache thumbnail-file)
              ;; PNG thumbnail has been created since we are
              ;; following the XDG thumbnail spec, so try to optimize
              (when (memq image-dired-thumbnail-storage
                          image-dired--thumbnail-standard-sizes)
                (cond
                 ((and image-dired-cmd-pngnq-program
                       (executable-find image-dired-cmd-pngnq-program))
                  (image-dired-pngnq-thumb spec))
                 ((and image-dired-cmd-pngcrush-program
                       (executable-find image-dired-cmd-pngcrush-program))
                  (image-dired-pngcrush-thumb spec))
                 ((and image-dired-cmd-optipng-program
                       (executable-find image-dired-cmd-optipng-program))
                  (image-dired-optipng-thumb spec)))))))
    process))

(defun image-dired-create-thumb-2 (original-file thumbnail-file)
  "For ORIGINAL-FILE, create thumbnail image named THUMBNAIL-FILE.
This is like `image-dired-create-thumb-1', but used when the thumbnail
file is created by Emacs itself."
  (let ((size (image-dired--thumb-size))
        (thumbnail-dir (file-name-directory thumbnail-file)))
    (when (not (file-exists-p thumbnail-dir))
      (with-file-modes #o700
        (make-directory thumbnail-dir t))
      (message "Thumbnail directory created: %s" thumbnail-dir))
    (image-dired-debug "Creating thumbnail for %s" original-file)
    (if (null (w32image-create-thumbnail original-file thumbnail-file
                                         (file-name-extension thumbnail-file)
                                         size size))
        (message "Failed to create a thumbnail for %s"
                 (abbreviate-file-name original-file))
      (clear-image-cache thumbnail-file)
      ;; PNG thumbnail has been created since we are following the XDG
      ;; thumbnail spec, so try to optimize.
      (when (memq image-dired-thumbnail-storage
                  image-dired--thumbnail-standard-sizes)
        (let* ((modif-time (format-time-string
                            "%s" (file-attribute-modification-time
                                  (file-attributes original-file))))
               (thumbnail-nq8-file (replace-regexp-in-string
                                    ".png\\'" "-nq8.png" thumbnail-file))
               (spec `((?s . ,size) (?w . ,size) (?h . ,size)
                       (?m . ,modif-time)
                       (?f . ,original-file)
                       (?u . ,(image-dired--file-URI original-file))
                       (?q . ,thumbnail-nq8-file)
                       (?t . ,thumbnail-file))))
          (cond
           ((and image-dired-cmd-pngnq-program
                 (executable-find image-dired-cmd-pngnq-program))
            (image-dired-pngnq-thumb spec))
           ((and image-dired-cmd-pngcrush-program
                 (executable-find image-dired-cmd-pngcrush-program))
            (image-dired-pngcrush-thumb spec))
           ((and image-dired-cmd-optipng-program
                 (executable-find image-dired-cmd-optipng-program))
            (image-dired-optipng-thumb spec))))))
    ;; Trigger next in queue once a thumbnail has been created.
    (image-dired-thumb-queue-run)))

(defun image-dired-thumb-queue-run ()
  "Run a queued job if one exists and not too many jobs are running.
Queued items live in `image-dired-queue'.
Number of simultaneous jobs is limited by `image-dired-queue-active-limit'."
  (if (not (eq (image-dired--check-executable-exists
                'image-dired-cmd-create-thumbnail-program
                'w32image-create-thumbnail)
               'function))
      ;; We have a usable gm/convert command; queue thethumbnail jobs.
      (let ((max-jobs
             (if (eq system-type 'windows-nt)
                 ;; Can't have more than 32 concurrent sub-processes on
                 ;; MS-Windows.
                 (min 30 image-dired-queue-active-limit)
               image-dired-queue-active-limit)))
        (while (and image-dired-queue
                    (< image-dired-queue-active-jobs max-jobs))
          (cl-incf image-dired-queue-active-jobs)
          (apply #'image-dired-create-thumb-1 (pop image-dired-queue))))
    ;; We are on MS-Windows with ImageMagick/GraphicsMagick, and need to
    ;; generate thumbnails by our lonesome selves.
    (if image-dired-queue
        (let* ((job (pop image-dired-queue))
               (orig-file (car job))
               (thumb-file (cadr job)))
          (run-with-timer 0.05 nil
                          #'image-dired-create-thumb-2
                          orig-file thumb-file)))))

(defun image-dired-create-thumb (original-file thumbnail-file)
  "Add a job for generating ORIGINAL-FILE thumbnail to `image-dired-queue'.
The new file will be named THUMBNAIL-FILE."
  (setq image-dired-queue
        (nconc image-dired-queue
               (list (list original-file thumbnail-file))))
  (run-at-time 0 nil #'image-dired-thumb-queue-run))

(defun image-dired-refresh-thumb ()
  "Force creation of new image for current thumbnail."
  (interactive nil image-dired-thumbnail-mode)
  (let* ((file (image-dired-original-file-name))
         (thumb (expand-file-name (image-dired-thumb-name file))))
    (clear-image-cache (expand-file-name thumb))
    (image-dired-create-thumb file thumb)))

(defun image-dired-rotate-original (degrees)
  "Rotate original image DEGREES degrees."
  (image-dired--check-executable-exists
   'image-dired-cmd-rotate-original-program)
  (if (not (image-dired-image-at-point-p))
      (message "No image at point")
    (let* ((file (image-dired-original-file-name))
           (spec
            (list
             (cons ?d degrees)
             (cons ?o (expand-file-name file))
             (cons ?t image-dired-temp-rotate-image-file))))
      (unless (eq 'jpeg (image-type file))
        (user-error "Only JPEG images can be rotated"))
      (if (not (= 0 (apply #'call-process image-dired-cmd-rotate-original-program
                           nil nil nil
                           (mapcar (lambda (arg) (format-spec arg spec))
                                   image-dired-cmd-rotate-original-options))))
          (error "Could not rotate image")
        (image-dired-display-image image-dired-temp-rotate-image-file)
        (if (or (and image-dired-rotate-original-ask-before-overwrite
                     (y-or-n-p
                      "Rotate to temp file OK.  Overwrite original image? "))
                (not image-dired-rotate-original-ask-before-overwrite))
            (progn
              (copy-file image-dired-temp-rotate-image-file file t)
              (image-dired-refresh-thumb)
              (image-dired-update-thumbnail-at-point))
          (image-dired-display-image file))))))


;;; EXIF support

(defun image-dired-get-exif-file-name (file)
  "Use the image's EXIF information to return a unique file name.
The file name should be unique as long as you do not take more than
one picture per second.  The original file name is suffixed at the end
for traceability.  The format of the returned file name is
YYYY_MM_DD_HH_MM_ss_ORIG_FILE_NAME.jpg.  Used from
`image-dired-copy-with-exif-file-name'."
  (let (data no-exif-data-found)
    (if (not (eq 'jpeg (image-type (expand-file-name file))))
        (setq no-exif-data-found t
              data (format-time-string
                    "%Y:%m:%d %H:%M:%S"
                    (file-attribute-modification-time
                     (file-attributes (expand-file-name file)))))
      (setq data (exif-field 'date-time (exif-parse-file
                                         (expand-file-name file)))))
    (while (string-match "[ :]" data)
      (setq data (replace-match "_" nil nil data)))
    (format "%s%s%s" data
            (if no-exif-data-found
                "_noexif_"
              "_")
            (file-name-nondirectory file))))

(defun image-dired-thumbnail-set-image-description ()
  "Set the ImageDescription EXIF tag for the original image at point.
If the image already has a value for this tag, it is used as the
default value at the prompt."
  (interactive nil image-dired-thumbnail-mode)
  (if (not (image-dired-image-at-point-p))
      (message "No thumbnail at point")
    (let* ((file (image-dired-original-file-name))
           (old-value (or (exif-field 'description (exif-parse-file file)) "")))
      (if (eq 0
              (image-dired-set-exif-data file "ImageDescription"
                                         (read-string "Value of ImageDescription: "
                                                      old-value)))
          (message "Successfully wrote ImageDescription tag")
        (error "Could not write ImageDescription tag")))))

(defun image-dired-set-exif-data (file tag-name tag-value)
  "In FILE, set EXIF tag TAG-NAME to value TAG-VALUE."
  (image-dired--check-executable-exists
   'image-dired-cmd-write-exif-data-program)
  (let ((spec
         (list
          (cons ?f (expand-file-name file))
          (cons ?u (image-dired--file-URI (expand-file-name file)))
          (cons ?t tag-name)
          (cons ?v tag-value))))
    (apply #'call-process image-dired-cmd-write-exif-data-program nil nil nil
           (mapcar (lambda (arg) (format-spec arg spec))
                   image-dired-cmd-write-exif-data-options))))

(define-obsolete-function-alias 'image-dired-thumb-size #'image-dired--thumb-size "29.1")

(provide 'image-dired-external)

;;; image-dired-external.el ends here

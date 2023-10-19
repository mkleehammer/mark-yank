;;; mark-yank-mode.el --- Set region to the last yank  -*- lexical-binding: t -*-

;; Copyright (C) 2023 Michael Kleehammer
;;
;; Author: Michael Kleehammer <michael@kleehammer.com>
;; Maintainer: Michael Kleehammer <michael@kleehammer.com>
;; URL: https://github.com/mkleehammer/mark-yank
;; Version: 1.0.0
;; Package-Requires: ((emacs "24.4"))
;;
;; This file is NOT part of GNU Emacs.
;;
;; MIT License
;;
;; Permission is hereby granted, free of charge, to any person obtaining a copy
;; of this software and associated documentation files (the "Software"), to deal
;; in the Software without restriction, including without limitation the rights
;; to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
;; copies of the Software, and to permit persons to whom the Software is
;; furnished to do so, subject to the following conditions:
;;
;; The above copyright notice and this permission notice shall be included in all
;; copies or substantial portions of the Software.
;;
;; THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
;; IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
;; FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
;; AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
;; LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
;; OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
;; SOFTWARE.

;;; Commentary:
;;
;; When enabled, yank commands are advised to record the point and mark.  The command
;; `mark-yank' will set the region to the recorded location and activate the region.
;;
;; Immediately after yanking, you can press C-x C-x to activate the mark, but this mode is
;; useful for setting the same region even after you've moved around and even made changes.
;;
;; This mode does not bind any keys.  I recommend C-M-y which is unused, similar to C-y used
;; for yank, and similar to other C-M mark keys like C-M-SPC for mark sexp.
;;
;; IMPORTANT: Do not defer loading until you want to mark since the mode must be enabled to
;; monitor the location of the last yank.  If you are using use-package, be sure to add
;; `:demand t' to force it to load immediately even though a key is bound:
;;
;;    (use-package mark-yank
;;      :ensure t
;;      :demand t
;;      :bind ("C-M-y" . 'mark-yank)
;;      :config (mark-yank-mode 1))

;;; Code:

;;;###autoload
(define-minor-mode mark-yank-mode
  "Allow marking of last yank region."
  :global t
  :group 'editing     ; why is this required for modes with no vars?

  (if mark-yank-mode
      (advice-add 'yank :after #'mark-yank--advise-after)
    (advice-remove 'yank #'mark-yank--advise-after))

  (message "mark-yank-mode %s" (if mark-yank-mode "enabled" "disabled")))

(defvar-local mark-yank--last-mark nil
  "Last copy/kill mark.")

(defvar-local mark-yank--last-point nil
  "Last copy/kill point.")

(defun mark-yank--advise-after (&rest _args)
  "Records current mark and point as last."
  (setq mark-yank--last-mark (mark)
        mark-yank--last-point (point)))

(defun mark-yank ()
  "Mark last paste location and activates region."
  (interactive)
  (if (not mark-yank--last-mark)
      (message "No last yank")
    (progn
      (push-mark mark-yank--last-mark)
      (goto-char mark-yank--last-point)
      (setq mark-active t))))

(provide 'mark-yank-mode)
;;; mark-yank-mode.el ends here

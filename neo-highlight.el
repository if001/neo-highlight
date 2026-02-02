;;; neo-highlight.el --- Highlight current buffer file in NeoTree -*- lexical-binding: t; -*-

;; Author: if001 <otomijuf.004@gmail.com>
;; Version: 0.1.0
;; Package-Requires: ((emacs "26.1") (neotree "0.6.0"))
;; Keywords: files, convenience
;; URL: https://github.com/if001/neo-highlight

;;; Commentary:
;;
;; This package highlights the node corresponding to the current buffer's file
;; in NeoTree WITHOUT moving point/cursor in the NeoTree buffer.
;;
;; Usage:
;;   (require 'neo-highlight)
;;   (neo-highlight-mode 1)
;;
;; or via use-package (see README).

;;; Code:

(require 'neotree)

(defgroup neo-highlight nil
  "Highlight current buffer's file in NeoTree."
  :group 'neotree)

(defface neo-highlight-current-file-face
  '((t :inherit hl-line))
  "Face used to highlight current buffer's file node in NeoTree."
  :group 'neo-highlight)

(defcustom neo-highlight-update-on-buffer-change t
  "If non-nil, update highlight on buffer changes via `buffer-list-update-hook`."
  :type 'boolean
  :group 'neo-highlight)

(defvar-local neo-highlight--ov nil
  "Overlay used for highlighting the current file node in the NeoTree buffer.")

(defun neo-highlight--clear ()
  "Clear highlight overlay in NeoTree buffer."
  (when (overlayp neo-highlight--ov)
    (delete-overlay neo-highlight--ov))
  (setq neo-highlight--ov nil))

(defun neo-highlight--line-for-path (path)
  "Return 1-based line number in NeoTree buffer for PATH, or nil."
  (when (and (boundp 'neo-buffer--node-list)
             (vectorp neo-buffer--node-list)
             path)
    (let ((i 0)
          (len (length neo-buffer--node-list))
          found)
      (while (and (< i len) (not found))
        (let ((p (aref neo-buffer--node-list i)))
          (when (and p (neo-path--file-equal-p p path))
            (setq found (1+ i))))
        (setq i (1+ i)))
      found)))

(defun neo-highlight--current-file ()
  "Return current buffer's filename (absolute), or nil."
  (let ((buf (window-buffer (selected-window))))
    (buffer-file-name buf)))

(defun neo-highlight--apply ()
  "Apply highlight in NeoTree buffer for current file, without moving point."
  (let ((path (neo-highlight--current-file)))
    (neo-global--with-buffer
      (neo-highlight--clear)
      (when (and path (neo-global--window-exists-p))
        (let ((line (neo-highlight--line-for-path path)))
          (when line
            (save-excursion
              (goto-char (point-min))
              (forward-line (1- line))
              (setq neo-highlight--ov
                    (make-overlay (line-beginning-position)
                                  (line-end-position)))
              (overlay-put neo-highlight--ov
                           'face 'neo-highlight-current-file-face)
              (overlay-put neo-highlight--ov 'priority 1000))))))))

(defun neo-highlight--after-refresh (&rest _)
  "Advice: update highlight after NeoTree refresh."
  ;; `neo-buffer--refresh` runs in neotree buffer; it is safe to re-apply there.
  (neo-highlight--apply))

(defun neo-highlight--maybe-update ()
  "Update highlight if NeoTree exists."
  (when (neo-global--window-exists-p)
    (neo-highlight--apply)))

;;;###autoload
(define-minor-mode neo-highlight-mode
  "Toggle highlighting of the current buffer's file in NeoTree."
  :global t
  :group 'neo-highlight
  (if neo-highlight-mode
      (progn
        (advice-add 'neo-buffer--refresh :after #'neo-highlight--after-refresh)
        (when neo-highlight-update-on-buffer-change
          (add-hook 'buffer-list-update-hook #'neo-highlight--maybe-update))
        ;; initial
        (neo-highlight--maybe-update))
    (advice-remove 'neo-buffer--refresh #'neo-highlight--after-refresh)
    (remove-hook 'buffer-list-update-hook #'neo-highlight--maybe-update)
    (neo-global--with-buffer
      (neo-highlight--clear))))

(provide 'neo-highlight)
;;; neo-highlight.el ends here

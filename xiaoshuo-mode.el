;;; xiaoshuo-mode.el --- Major mode for Chinese novels -*- lexical-binding: t -*-

;; Author: dalu <mou.tong@qq.com>
;; Maintainer: dalu <mou.tong@qq.com>
;; Version: 0.2.0
;; Package-Requires: ((emacs "30.1"))
;; URL: https://github.com/dalugm/xiaoshuo-mode
;; Keywords: text


;; This file is not part of GNU Emacs

;; This program is free software: you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation, either version 3 of the License, or
;; (at your option) any later version.

;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with this program.  If not, see <https://www.gnu.org/licenses/>.


;;; Commentary:

;; Provide some basic features for reading Chinese novels.

;;; Code:

(defgroup xiaoshuo nil
  "Major mode for reading Chinese novels."
  :prefix "xiaoshuo-"
  :group 'text)

(defcustom xiaoshuo-title-regexp
  (rx bol
      (0+ space)
      "第" (repeat 1 6 nonl) (any "卷回章节话部")
      (0+ nonl)
      eol)
  "Chinese title regexp."
  :type 'regexp
  :group 'xiaoshuo)

(defun xiaoshuo--delete-horizontal-space ()
  "Delete horizontal whitespace around point, including ideographic space."
  (let* ((origin (point))
         (beginning (progn
                      (skip-chars-backward " \t　​")
                      (point)))
         (end (progn
                (goto-char origin)
                (skip-chars-forward " \t　​")
                (point))))
    (delete-region beginning end)))

(defun xiaoshuo-add-two-ideographic-spaces-at-content-bol (&optional arg)
  "Add two ideographic spaces at content's non-empty line beginning.

If a region is selected, executed on the selected region,
otherwise on the whole buffer.

When ARG is non-nil, execute this function based on input regexp.
Otherwise, use `xiaoshuo-title-regexp'."
  (interactive "P")
  (let ((title-regexp (if arg
                          (read-regexp "Title pattern: ")
                        xiaoshuo-title-regexp))
        start end)
    (if (use-region-p)
        (setq start (copy-marker (region-beginning))
              end (copy-marker (region-end)))
      (setq start (copy-marker (point-min))
            end (copy-marker (point-max))))
    (save-excursion
      (goto-char start)
      (while (< (point) end)
        (cond
         ((save-excursion
            (beginning-of-line)
            (re-search-forward title-regexp (pos-eol) t))
          ;; Do not modify title lines.
          (forward-line))
         ((save-excursion
            (beginning-of-line)
            (looking-at-p "[ \t　​]*$"))
          ;; Normalize whitespace-only lines to empty lines.
          (delete-region (pos-bol) (pos-eol))
          (forward-line))
         (t
          (back-to-indentation)
          (xiaoshuo--delete-horizontal-space)
          (insert-char #x3000 2)
          (forward-line)))))))

(defun xiaoshuo-divide-file-chapter (&optional arg)
  "Add empty lines to divide chapters.

When ARG is non-nil, search lines based on input regexp.
Otherwise, use `xiaoshuo-title-regexp'."
  (interactive "P")
  (save-excursion
    ;; Search sentences containing `xiaoshuo-title-regexp'.
    (let ((title-regexp (if arg
                            (read-regexp "Title pattern: ")
                          xiaoshuo-title-regexp)))
      ;; Make sure the final newline exists.
      (goto-char (point-max))
      (unless (bolp)
        (newline))
      ;; Go to start position.
      (goto-char (point-min))
      (while (< (point) (point-max))
        (when (re-search-forward title-regexp (pos-eol) t)
          ;; Add two new lines above the chapter title when it is not
          ;; in the first line.
          (unless (= (pos-bol) (point-min))
            (beginning-of-line)
            (delete-all-space)
            ;; After delete all spaces, insert three newlines to leave
            ;; two blank lines above the chapter title.
            (newline 3))
          ;; Leave one blank line below the chapter title.
          (end-of-line)
          (delete-all-space)
          (newline 2))
        ;; Forward line to continue the loop.
        (forward-line)))
    ;; Avoid extra newlines when chapter title is in the last line.
    (when (= (point) (point-max))
      (delete-all-space)
      (newline))))

(defvar-keymap xiaoshuo-mode-map
  :doc "Keymap for `xiaoshuo-mode'."
  "C-c C-a" #'xiaoshuo-add-two-ideographic-spaces-at-content-bol
  "C-c C-d" #'xiaoshuo-divide-file-chapter)

(define-derived-mode xiaoshuo-mode text-mode "XiaoShuo"
  "Major mode for reading Chinese novels."
  (setq-local imenu-generic-expression
              `((nil ,(rx (group (regexp xiaoshuo-title-regexp))) 1))))

(provide 'xiaoshuo-mode)

;;; xiaoshuo-mode.el ends here

;;; xiaoshuo-mode-tests.el --- Tests for xiaoshuo-mode -*- lexical-binding: t; -*-

(require 'ert)
(require 'xiaoshuo-mode)

(ert-deftest xiaoshuo-indent-command-accepts-prefix-argument ()
  (should (equal (interactive-form
                  #'xiaoshuo-add-two-ideographic-spaces-at-content-bol)
                 '(interactive "P"))))

(ert-deftest xiaoshuo-indent-content-is-idempotent ()
  (with-temp-buffer
    (insert "第一章 开始\n第二章 继续\n  正文\n　​\n")
    (xiaoshuo-add-two-ideographic-spaces-at-content-bol)
    (should (equal (buffer-string)
                   "第一章 开始\n第二章 继续\n　　正文\n\n"))
    (xiaoshuo-add-two-ideographic-spaces-at-content-bol)
    (should (equal (buffer-string)
                   "第一章 开始\n第二章 继续\n　　正文\n\n"))))

(ert-deftest xiaoshuo-mode-keymap-binds-editing-commands ()
  (should (eq (keymap-lookup xiaoshuo-mode-map "C-c C-a")
              #'xiaoshuo-add-two-ideographic-spaces-at-content-bol))
  (should (eq (keymap-lookup xiaoshuo-mode-map "C-c C-d")
              #'xiaoshuo-divide-file-chapter)))

(provide 'xiaoshuo-mode-tests)
;;; xiaoshuo-mode-tests.el ends here

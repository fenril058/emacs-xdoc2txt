;;; xdoc2txt.el --- interface of xdoc2txt for Emacs -*- lexical-binding: t; -*-

;; Copyright (C) 2016  ril

;; Author: ril
;; Created: 2016-01-30 20:27:29
;; Last Modified: 2016-01-31 21:38:30
;; Version: 0.2
;; Keywords: Windows, data
;; URL: https://github.com/fenril058/xdoc2txt

;; This program is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation, either version 3 of the License, or
;; (at your option) any later version.

;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with this program.  If not, see <http://www.gnu.org/licenses/>.

;;; Commentary:

;; This program is a interface of xdoc2txt for Emacs.

;; The program xdoc2txt is a text converter which extract text from
;; binary file such as PDF, WORD, EXCEL, 一太郎 etc. It only works on
;; MS Windows. Its binary file and more infomation can be obtained
;; from <http://ebstudio.info/home/xdoc2txt.html>

;; This file is originated from
;;  <http://www.bookshelf.jp/soft/meadow_23.html#SEC238>

;;; Code
(require 'cl-lib)

(defgroup xdoc2txt nil
  "xdoc2txt interface for Emacs"
  :group 'emacs)

(defcustom xdoc2txt-binary-use-xdoc2txt (executable-find "xdoc2txt.exe")
  "If non-nil，use xdoc2txt when the binary file whose extensions
is in `xdoc2txt-extensions'．"
  :type 'boolean
  :group 'xdoc2txt)

(defcustom xdoc2txt-encoding 'utf-8
  "Enconfig for xdoc2txt. You can choose utf-8, utf-16, euc-jp,
  japanese-shift-jis, and sjis"
  :type 'symbol
  :group 'xdoc2txt.el)

(defcustom xdoc2txt-extensions
  '("rtf" "doc" "xls" "ppt" "docx" "xlsx" "pptx"
    "jaw" "jtw" "jbw" "juw" "jfw" "jvw" "jtd" "jtt"
    "oas" "oa2" "oa3" "bun"
    "wj2" "wj3" "wk3" "wk4"
    "123" "wri" "pdf" "mht")
  "*List of file extensions which are handled by xdoc2txt.
They must be written in lowercase."
  :type 'list
  :group 'xdoc2txt)

(defcustom xdoc2txt-make-header t
  "If non-nil, xdoc2txt insert header defined in
  `xdoc2txt-make-header-format'")

(defvar xdoc2txt-encoding-option nil)

(defun xdoc2txt-select-encoding ()
  (interactive)
  (let ((code xdoc2txt-encoding))
    (setq xdoc2txt-encoding-option
          (cl-case code
            ('utf-8 " -8 ")
            ('utf-16 " -u ")
            ('euc-jp " -e ")
            ('japanese-shift-jis " -s ")
            ('sjis " -j ")
            ))))

(defun xdoc2txt-make-header-format (file)
  (concat "XDOC2TXT FILE: " (file-name-nondirectory file) "\n"
          "----------------------------------------------------\n"))

(defun xdoc2txt-make-format (file)
  (let ((fn (concat
             (expand-file-name
              (make-temp-name "xdoc2")
              temporary-file-directory)
             "."
             (file-name-extension file)
             )))
    (copy-file file fn t)
    (xdoc2txt-select-encoding)
    (when xdoc2txt-make-header
      (insert
       (xdoc2txt-make-header-format file)))
    (insert
     (shell-command-to-string
      (concat "xdoc2txt" xdoc2txt-encoding-option fn)
      ))
    ;; (goto-char (point-min))
    ;; (while (re-search-forward "\r" nil t)
    ;;   (delete-region (match-beginning 0)
    ;;                  (match-end 0)))
    ;; (goto-char (point-min))
    ;; (while (re-search-forward
    ;;         "\\([\n ]+\\)\n[ ]*\n" nil t)
    ;;   (delete-region (match-beginning 1)
    ;;                  (match-end 1)))
    (delete-file fn)))

;;;###autoload
(defun xdoc2txt-binary-file-view (file)
  "View a binary file with xdoc2txt"
  (interactive "f")
  (let ((dummy-buff-name (concat "xdoc2txt:" (file-name-nondirectory file)))
        (dummy-buff))
    (when (get-buffer dummy-buff-name)
     (kill-buffer dummy-buff-name))
    (setq dummy-buff (get-buffer-create dummy-buff-name))
    (set-buffer dummy-buff)
    (xdoc2txt-make-format file)
    ;; (setq buffer-read-only t)
    (set-window-buffer (selected-window) dummy-buff))
  (goto-char (point-min))
  (view-mode t))

;; (defun xdoc2txt-advice-find-file (orig-func file &rest args)
;;   (interactive)
;;   (if (and
;;        xdoc2txt-binary-use-xdoc2txt
;;        (member (file-name-extension file) xdoc2txt-extensions)
;;        (y-or-n-p
;;         "Use xdoc2txt to show the binary data?")
;;        )
;;       (xdoc2txt-binary-file-view file)
;;     (apply orig-func file args))
;;   'around)

;; (advice-add 'find-file :around 'xdoc2txt-advice-find-file)

;; (defun xdoc2txt-add-advice-find-file ()
;;   (interactive)
;;   (advice-add 'find-file :around 'xdoc2txt-advice-find-file))

;; (defun xdoc2txt-remove-advice-find-file ()
;;   (interactive)
;;   (advice-remove 'find-file 'xdoc2txt-advice-find-file))

(defadvice find-file (around xdoc2txt-find-file (file &optional wildcards))
  (if (and
       xdoc2txt-binary-use-xdoc2txt
       (member (file-name-extension file) xdoc2txt-extensions)
       (y-or-n-p
        "Use xdoc2txt to show the binary data?"))
      (xdoc2txt-binary-file-view file)
    ad-do-it))

;;;###autoload
(defun xdoc2txt-acivate-advice ()
  (interactive)
  (ad-activate 'find-file))

(provide 'xdoc2txt)
;;; xdoc2txt.el ends here

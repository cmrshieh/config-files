;;; color-theme-justin.el --- Justin Van Winkle's Color Theme

;; Copyright (C) 1997 -- 2009 Edward O'Connor <ted@oconnor.cx>
;; Copyright (C) 2010 Justin Van Winkle <justin.vanwinkle@gmail.com>

;; Author: Justin Van Winkle <justin.vanwinkle@gmail.com>
;; Keywords: local

;; This file is NOT part of GNU Emacs.

;; This is free software; you can redistribute it and/or modify it under
;; the terms of the GNU General Public License as published by the Free
;; Software Foundation; either version 2, or (at your option) any later
;; version.

;; This file is distributed in the hope that it will be useful, but
;; WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
;; General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with Emacs; see the file COPYING, or type `C-h C-c'. If not,
;; write to the Free Software Foundation at this address:

;;   Free Software Foundation
;;   51 Franklin Street, Fifth Floor
;;   Boston, MA 02110-1301
;;   USA

;;; Commentary:
;;; Code:

(require 'color-theme)

;; Placate the byte compiler and elint
(defvar window-system)
(defvar max-lisp-eval-depth)
(defvar max-specpdl-size)

(defun hober2-use-underline-p (&optional display)
  "Non-nil if DISPLAY supports underlining.
This is only sometimes accurate."
  (if (fboundp 'display-supports-face-attributes-p)
      (display-supports-face-attributes-p '(:underline) display)
    window-system))


(defvar hober2-insignificant-face
  (if window-system
      '(:foreground "gray30")
    '()))

;; Ensuring `max-lisp-eval-depth' and `max-specpdl-size' are big enough
;; for the backquote in `color-theme-hober2', as well as for running
;; `elint-current-buffer' on this file.
(when (< max-lisp-eval-depth 1500)
  (setq max-lisp-eval-depth 1500))
(when (< max-specpdl-size 3000)
  (setq max-specpdl-size 3000))

(defun color-theme-justin ()
  "
Like my previous theme, I've attempted to make sure things look
reasonably similar under console or window system. The colors of
`color-theme-hober2' are often washed-out variants of the colors
of `color-theme-hober'.

Includes antlr, apropos, AUCTeX (font-latex), bbdb, Buffer-menu,
calendar, change-log, comint, compilation, cperl, custom, darcsum,
diary, diff, dired, ediff, erc, eshell, filladapt, font-lock, forms,
gnus, goto-address, help, highline, hl-line, holiday, html-helper,
hyper-apropos, ibuffer, Info, isearch, jde, makefile, Man, message,
multi-region, nxml, psvn, sgml, sh, show-paren, show-tabs, slime, sldb,
speedbar, tex, view, viper, w3m, widget, woman"
  (interactive)
  (color-theme-install
   `(color-theme-justin
     ;; Frame parameters
     ((foreground-color . "#BBB")
      (background-color . "black")
      (mouse-color      . "khaki")
      (cursor-color     . "aquamarine")
      (border-color     . "gray4")
      (background-mode  . dark))
     ;; Face variables
     ((Man-overstrike-face . font-lock-variable-name-face)
      (Man-underline-face  . font-lock-string-face)

      (apropos-symbol-face     . font-lock-keyword-face)
      (apropos-keybinding-face . font-lock-constant-face)
      (apropos-label-face      . font-lock-type-face)
      (apropos-property-face   . font-lock-string-face)
      (apropos-match-face      . font-lock-function-name-face)

      (cperl-pod-face      . font-lock-doc-string-face)
      (cperl-pod-head-face . font-lock-variable-name-face)
      (cperl-here-face     . font-lock-doc-string-face)
      (cperl-invalid-face  . font-lock-warning-face)

      (dired-header-face    . dired-header)
      (dired-mark-face      . dired-mark)
      (dired-marked-face    . dired-marked)
      (dired-flagged-face   . dired-flagged)
      (dired-warning-face   . dired-warning)
      (dired-directory-face . dired-directory)
      (dired-symlink-face   . dired-symlink)
      (dired-ignored-face   . dired-ignored)

      (erc-button-nickname-face . underline)

      (filladapt-debug-indentation-face-1 . highlight)
      (filladapt-debug-indentation-face-2 . secondary-selection)
      (filladapt-debug-paragraph-face     . bold)

      (forms-ro-face . custom-comment-tag-face)
      (forms-rw-face . custom-comment-face)

      (goto-address-url-face        . font-lock-string-face)
      (goto-address-url-mouse-face  . highlight)
      (goto-address-mail-face       . font-lock-string-face)
      (goto-address-mail-mouse-face . highlight)

      (help-highlight-face . font-lock-variable-name-face)

      (hl-line-face . fringe)

      (ibuffer-deletion-face . font-lock-warning-face)
      (ibuffer-filter-group-name-face . bold)
      (ibuffer-marked-face . font-lock-comment-face)
      (ibuffer-title-face . dired-header)

      (list-matching-lines-face             . bold)
      (list-matching-lines-buffer-name-face . font-lock-type-face)

      (view-highlight-face . highlight)

      (viper-replace-overlay-cursor-color . "pale violet red") ;%
      (viper-insert-state-cursor-color    . "light pink") ;%
      (viper-vi-state-cursor-color        . "khaki")

      (widget-mouse-face . highlight))
     ;; Faces
     (default ((t (:background "gray4" :foreground "gray"
                   :stipple nil :box nil :strike-through nil :overline nil
                   :underline nil :slant normal :weight normal
                   :inverse-video nil))))

     (font-lock-builtin-face ((t (:foreground "sandy brown"))))
     (font-lock-color-constant-face ((t (:foreground "khaki"))))
     (font-lock-comment-face ((t (:foreground "gray40"))))
     (font-lock-comment-delimiter-face ((t (:foreground "midnight blue"))))
     (font-lock-constant-face ((t (:foreground "pale violet red"))))
     (font-lock-doc-face ((t (:foreground "khaki"))))
     (font-lock-doc-string-face ((t (:foreground "medium purple"))))
     (font-lock-function-name-face ((t (:foreground "firebrick"))))
     (font-lock-keyword-face ((t (:foreground "steel blue"))))
     (font-lock-preprocessor-face ((t (:foreground "khaki"))))
     (font-lock-reference-face ((t (:foreground "khaki"))))
     (font-lock-string-face ((t (:foreground "slate grey"))))
     (font-lock-negation-char-face ((t (:forground "dark red"))))
     (font-lock-type-face ((t (:foreground "SeaGreen3" :weight bold))))
     (font-lock-variable-name-face ((t (:foreground "IndianRed1"))))
     (font-lock-warning-face ((t (:background "indian red" :foreground "white"))))

     (flymake-warnline ((t (:background "midnight blue"))))
     (flymake-errline ((t (:background "red4"))))

     (fringe ((t (:background "gray6" :foreground "gray21"))))

     (bold ((t (:bold t))))
     (bold-italic ((t (:bold t :slant italic))))

     (border ((t nil)))

     (Buffer-menu-buffer-face ((t (:foreground "cadet blue"))))

     (calendar-today-face ((t (:foreground "khaki")))) ;%

     (change-log-date-face ((t (:foreground "lemon chiffon"))))
     (change-log-name-face ((t (:foreground "khaki"))))
     (change-log-email-face ((t (:foreground "indian red"))))
     (change-log-file-face ((t (:foreground "cadet blue"))))
     (change-log-list-face ((t (:foreground "LightSteelBlue4"))))
     (change-log-conditionals-face ((t (:foreground "indian red"))))
     (change-log-function-face ((t (:foreground "indian red"))))
     (change-log-acknowledgement-face ((t (:background "cadet blue" :foreground "gray4"))))

     (comint-highlight-input ((t (:bold t))))
     (comint-highlight-prompt ((t (:foreground "pale violet red"))))

     (compilation-warning-face ((t (:background "indian red" :foreground "white"))))
     (compilation-warning ((t (:background "indian red" :foreground "white"))))
     (compilation-info-face ((t (:foreground "dark orchid"))))
     (compilation-info ((t (:foreground "dark orchid"))))
     (compilation-error-face ((t (:foreground "dark orchid"))))
     (compilation-error ((t (:foreground "dark orchid"))))

     (css-selector ((t (:foreground "indian red"))))
     (css-property ((t (:foreground "light sea green"))))

     (cursor ((t (:background "khaki" :foreground "gray4"))))

     (custom-button-face ((t (:foreground "gray4" :background "light gray" :bold t :underline t))))
     (custom-button-pressed-face ((t (:foreground "gray4" :background "light gray" :bold t
                                      :underline t))))
     (custom-face-tag-face ((t (:bold t))))
     (custom-variable-tag-face ((t (:bold t))))
     (custom-state-face ((t (:foreground "medium sea green"))))

     (diary-face ((t (:foreground "indian red"))))
     (diary-button-face ((t (:foreground "gray4"
                             :background "light gray"
                             :bold t :underline t))))

     (diff-hunk-header-face ((t (:background "gray30" :foreground "white"))))

     (dired-flagged ((t (:background "indian red" :foreground "white"))))
     (dired-face-flagged ((t (:background "indian red" :foreground "white"))))
     (dired-header ((t (:foreground "medium sea green"))))
     (dired-face-header ((t (:foreground "medium sea green"))))
     (dired-mark ((t (:foreground "khaki"))))
     (dired-marked ((t (:background "cadet blue" :foreground "gray4"))))
     (dired-face-marked ((t (:background "cadet blue" :foreground "gray4"))))
     (dired-warning ((t (:background "indian red" :foreground "white"))))

     (dired-directory ((t (:foreground "khaki"))))
     (dired-face-directory ((t (:foreground "khaki"))))
     (dired-face-executable ((t (:foreground "medium sea green"))))
     (dired-ignored ((t ,hober2-insignificant-face)))
     (dired-face-boring ((t ,hober2-insignificant-face)))
     (dired-face-permissions ((t ,hober2-insignificant-face)))
     (dired-face-setuid ((t (:bold t :foreground "medium sea green"))))
     (dired-face-socket ((t ,hober2-insignificant-face)))
     (dired-symlink ((t (:foreground "cadet blue"))))
     (dired-face-symlink ((t (:foreground "cadet blue"))))
     (ediff-current-diff-face-A ((t (:background "cadet blue" :foreground "gray4"))))
     (ediff-current-diff-face-Ancestor ((t (:background "IndianRed1"
                                            :foreground "light gray"))))
     (ediff-current-diff-face-B ((t (:background "lemon chiffon" :foreground "gray30"))))
     (ediff-current-diff-face-C ((t (:background "medium sea green"
                                     :foreground "light gray"))))
     (ediff-even-diff-face-A ((t (:background "cadet blue" :foreground "gray4" :bold t))))
     (ediff-even-diff-face-Ancestor ((t (:background "IndianRed1"
                                         :foreground "light gray"
                                         :bold t))))
     (ediff-even-diff-face-B ((t (:background "lemon chiffon" :foreground "gray30"
                                  :bold t))))
     (ediff-even-diff-face-C ((t (:background "medium sea green" :foreground "light gray"
                                  :bold t))))
     (ediff-fine-diff-face-A ((t (:background "steel blue" :foreground "gray4"))))
     (ediff-fine-diff-face-Ancestor ((t (:background "orange red"
                                         :foreground "gray4"))))
     (ediff-fine-diff-face-B ((t (:background "LightSteelBlue4" :foreground "white"))))
     (ediff-fine-diff-face-C ((t (:background "DarkGreen"
                                  :foreground "gray4"))))
     (ediff-odd-diff-face-A ((t (:background "steel blue" :foreground "gray4"
                                 :bold t))))
     (ediff-odd-diff-face-Ancestor ((t (:background "orange red"
                                        :foreground "gray4"
                                        :bold t))))
     (ediff-odd-diff-face-B ((t (:background "LightSteelBlue4" :foreground "white" :bold t))))
     (ediff-odd-diff-face-C ((t (:background "DarkGreen"
                                 :foreground "gray4" :bold t))))

     (escape-glyph ((t ,hober2-insignificant-face)))
     (eshell-prompt-face ((t (:foreground "pale violet red"))))
     (eshell-prompt ((t (:foreground "pale violet red"))))

     (eshell-ls-archive-face ((t (:foreground "indian red")))) ;%
     (eshell-ls-archive ((t (:foreground "indian red")))) ;%
     (eshell-ls-backup-face ((t (:foreground "LightSteelBlue4"))))
     (eshell-ls-backup ((t (:foreground "LightSteelBlue4"))))
     (eshell-ls-clutter-face ((t (:background "indian red" :foreground "white"))))
     (eshell-ls-clutter ((t (:background "indian red" :foreground "white"))))
     (eshell-ls-directory-face ((t (:foreground "khaki"))))
     (eshell-ls-directory ((t (:foreground "khaki"))))
     (eshell-ls-executable-face ((t (:foreground "medium sea green"))))
     (eshell-ls-executable ((t (:foreground "medium sea green"))))
     (eshell-ls-missing-face ((t (:background "indian red" :foreground "white" :bold t))))
     (eshell-ls-missing ((t (:background "indian red" :foreground "white" :bold t))))
     (eshell-ls-product-face ((t ,hober2-insignificant-face)))
     (eshell-ls-product ((t ,hober2-insignificant-face)))
     (eshell-ls-readonly-face ((t ,hober2-insignificant-face)))
     (eshell-ls-readonly ((t ,hober2-insignificant-face)))
     (eshell-ls-special-face ((t (:foreground "pale violet red")))) ;%
     (eshell-ls-special ((t (:foreground "pale violet red")))) ;%
     (eshell-ls-symlink-face ((t (:foreground "cadet blue"))))
     (eshell-ls-symlink ((t (:foreground "cadet blue"))))
     (eshell-ls-unreadable-face ((t (:background "indian red" :foreground "white" :bold t))))
     (eshell-ls-unreadable ((t (:background "indian red" :foreground "white" :bold t))))

     (file-name-shadow ((t ,hober2-insignificant-face)))

     (gnus-cite-attribution-face ((t ())))
     (gnus-cite-attribution ((t ())))
     (gnus-cite-face-1 ((t (:foreground "lemon chiffon"))))
     (gnus-cite-1 ((t (:foreground "lemon chiffon"))))
     (gnus-cite-face-2 ((t (:foreground "khaki"))))
     (gnus-cite-2 ((t (:foreground "khaki"))))
     (gnus-cite-face-3 ((t (:foreground "cadet blue"))))
     (gnus-cite-3 ((t (:foreground "cadet blue"))))
     (gnus-cite-face-4 ((t (:foreground "indian red"))))
     (gnus-cite-4 ((t (:foreground "indian red"))))
     (gnus-cite-face-5 ((t (:foreground "pale violet red"))))
     (gnus-cite-5 ((t (:foreground "pale violet red"))))
     (gnus-cite-face-6 ((t (:foreground "DarkGreen"))))
     (gnus-cite-6 ((t (:foreground "DarkGreen"))))
     (gnus-cite-face-7 ((t (:foreground "LightSteelBlue4")))) ;%
     (gnus-cite-7 ((t (:foreground "LightSteelBlue4"))))
     (gnus-cite-face-8 ((t (:foreground "gray"))))
     (gnus-cite-8 ((t (:foreground "gray"))))
     (gnus-cite-face-9 ((t (:foreground "steel blue"))))
     (gnus-cite-9 ((t (:foreground "steel blue"))))
     (gnus-cite-face-10 ((t (:foreground "lemon chiffon"))))
     (gnus-cite-10 ((t (:foreground "lemon chiffon"))))
     (gnus-cite-face-11 ((t (:foreground "khaki"))))
     (gnus-cite-11 ((t (:foreground "khaki"))))

     (gnus-emphasis-bold ((t (:bold t))))
     (gnus-emphasis-bold-italic ((t (:italic t :bold t))))
     (gnus-emphasis-italic ((t (:italic t))))
     (gnus-emphasis-underline ((t (:underline t))))
     (gnus-emphasis-underline-bold ((t (:bold t :underline t))))
     (gnus-emphasis-underline-bold-italic ((t (:italic t :bold t :underline t))))
     (gnus-emphasis-underline-italic ((t (:italic t :underline t))))

     (gnus-header-content-face ((t ,hober2-insignificant-face)))
     (gnus-header-content ((t ,hober2-insignificant-face)))
     (gnus-header-from-face ((t (:height 1.2 :foreground "DarkSeaGreen2"))))
     (gnus-header-from ((t (:height 1.2 :foreground "DarkSeaGreen2"))))
     (gnus-header-name-face ((t (:foreground "cadet blue")))) ;%
     (gnus-header-name ((t (:foreground "cadet blue"))))
     (gnus-header-newsgroups-face ((t (:foreground "medium sea green"))))
     (gnus-header-newsgroups ((t (:foreground "medium sea green"))))
     (gnus-header-subject-face ((t (:height 1.2 :foreground "lemon chiffon"))))
     (gnus-header-subject ((t (:height 1.2 :foreground "lemon chiffon"))))
     (gnus-signature-face ((t ,hober2-insignificant-face)))
     (gnus-signature ((t ,hober2-insignificant-face)))
     (gnus-summary-cancelled-face ((t (:foreground "khaki"))))
     (gnus-summary-cancelled ((t (:foreground "khaki"))))
     (gnus-summary-high-read-face ((t (:foreground "khaki"))))
     (gnus-summary-high-read ((t (:foreground "khaki"))))
     (gnus-summary-high-ticked-face ((t (:foreground "indian red"))))
     (gnus-summary-high-ticked ((t (:foreground "<<medium red>"))))
     (gnus-summary-normal-ticked-face ((t (:foreground "IndianRed1"))))
     (gnus-summary-normal-ticked ((t (:foreground "IndianRed1"))))
     (gnus-summary-low-read-face ((t (:foreground "khaki"))))
     (gnus-summary-low-read ((t (:foreground "khaki"))))
     (gnus-summary-selected-face ((t (:background "gray30" :foreground "white"))))
     (gnus-summary-selected ((t (:background "gray30" :foreground "white"))))

     (header-line ((t (:box (:line-width 2
                             :color "gray8"
                             :style nil)
                       :background "gray8" :foreground "white"))))

     (help-argument-name ((t (:foreground "IndianRed1"))))

     (html-helper-bold-face ((t ())))
     (html-helper-italic-face ((t ())))
     (html-helper-underline-face ((t ())))
     (html-helper-strikethrough-face ((t ())))
     (html-helper-link-face ((t ())))
     (html-helper-significant-tag-face ((t (:foreground "cadet blue")))) ;%

     (hyper-apropos-documentation ((t (:foreground "white")))) ;%
     (hyper-apropos-hyperlink ((t (:underline t))))
     (hyper-apropos-major-heading ((t (:foreground "lemon chiffon")))) ;%
     (hyper-apropos-section-heading ((t (:foreground "khaki"))))
     (hyper-apropos-apropos-heading ((t (:foreground "sandy brown"))))
     (hyper-apropos-apropos-warning ((t (:background "indian red" :foreground "white"))))

     (highlight ((t (:background "DarkGreen" :foreground "light gray" :underline t))))

     (highline-face ((t (:background "gray30" :foreground "white"))))
     (highline-vertical-face ((t (:background "gray30" :foreground "white"))))

     (holiday-face ((t (:foreground "pale violet red"))))

     (isearch ((t (:background "steel blue" :foreground "lemon chiffon"))))
     (isearch-lazy-highlight-face ((t (:background "DarkGreen"
                                       :foreground "lemon chiffon"))))
     (lazy-highlight ((t (:background "indian red" :foreground "lemon chiffon"))))
     (isearch-secondary ((t (:background "indian red" :foreground "lemon chiffon"))))
     (isearch-fail ((t (:background "indian red" :foreground "lemon chiffon"))))

     (iswitchb-current-match ((t (:foreground "cadet blue"))))
     (iswitchb-single-match ((t (:foreground "medium sea green"))))
     (iswitchb-invalid-regexp ((t (:background "indian red" :foreground "white" :bold t))))
     (iswitchb-virtual-matches ((t (:foreground "sandy brown"))))

     (italic ((t (:slant italic))))

     (js2-builtin-face ((t (:foreground "sandy brown"))))
     (js2-comment-face ((t (:foreground "dark orchid"))))
     (js2-constant-face ((t (:foreground "pale violet red"))))
     (js2-error-face ((t (:background "indian red" :foreground "white" :bold t))))
     (js2-external-variable-face ((t (:foreground "indian red"))))
     (js2-function-name-face ((t (:foreground "cadet blue"))))
     (js2-function-param-face ((t (:foreground "IndianRed1"))))
     (js2-instance-member-face ((t (:foreground "IndianRed1"))))
     ;; Copied from `nxml-tag-delimiter'
     (js2-jsdoc-html-tag-delimiter-face ((t ,hober2-insignificant-face)))
     ;; Copied from `nxml-element-local-name'
     (js2-jsdoc-html-tag-name-face ((t (:foreground "cadet blue"))))
     (js2-jsdoc-tag-face ((t (:foreground "medium orchid"))))
     (js2-jsdoc-type-face ((t (:foreground "medium orchid"))))
     (js2-jsdoc-value-face ((t (:foreground "medium orchid"))))
     (js2-keyword-face ((t (:foreground "steel blue"))))
     (js2-private-function-call-face ((t (:foreground "cadet blue"))))
     (js2-private-member-face ((t (:foreground "IndianRed1"))))
     (js2-regexp-face ((t (:foreground "khaki"))))
     (js2-string-face ((t (:foreground "lemon chiffon"))))
     (js2-type-face ((t (:foreground "medium sea green"))))
     (js2-variable-name-face ((t (:foreground "IndianRed1"))))
     (js2-warning-face ((t (:background "indian red" :foreground "white"))))

     (makefile-shell-face ((t ())))
     (makefile-space-face ((t (:background "IndianRed1" :foreground "light gray"))))
     (makefile-targets-face ((t ())))

     (match ((t (:background "DodgerBlue3" :foreground "light gray")))) ;%

     (menu ((t (:background "light gray" :foreground "gray4"))))

     (message-cited-text-face ((t (:foreground "indian red")))) ;%
     (message-cited-text ((t (:foreground "indian red")))) ;%

     (message-header-cc-face ((t (:foreground "medium sea green"))))
     (message-header-cc ((t (:foreground "medium sea green"))))
     (message-header-name-face ((t (:foreground "medium sea green"))))
     (message-header-name ((t (:foreground "medium sea green"))))
     (message-header-newsgroups-face ((t (:foreground "medium sea green"))))
     (message-header-newsgroups ((t (:foreground "medium sea green"))))
     (message-header-other-face ((t (:foreground "cadet blue"))))
     (message-header-other ((t (:foreground "cadet blue"))))
     (message-header-subject-face ((t (:height 1.2 :foreground "lemon chiffon"))))
     (message-header-subject ((t (:height 1.2 :foreground "lemon chiffon"))))
     (message-header-to-face ((t (:foreground "cadet blue"))))
     (message-header-to ((t (:foreground "cadet blue"))))
     (message-header-xheader-face ((t (:foreground "cadet blue"))))
     (message-header-xheader ((t (:foreground "cadet blue"))))

     (message-mml-face ((t (:foreground "medium sea green"))))
     (message-mml ((t (:foreground "medium sea green"))))
     (message-separator-face ((t (:background "indian red" :foreground "white" :bold t))))
     (message-separator ((t (:background "indian red" :foreground "white" :bold t))))

     (minibuffer-prompt ((t (:foreground "medium sea green"))))
     (mm-uu-extract ((t (:background "gray8"
                         :foreground "white"))))


     (mode-line ((t (:foreground "light gray" :background "gray10" :inverse-video nil :box (:line-width 2 :style released-button)))))
     (modeline ((t (:foreground "light gray" :background "gray10" :inverse-video nil :box (:line-width 2 :style released-button)))))
     (mode-line-inactive ((t (:foreground "gray30" :background "gray5"
                              :inverse-video nil :box (:line-width 2 :style released-button)))))
     (mode-line-highlight ((t (:foreground "black" :background "gray20"
                               :inverse-video nil :box (:line-width 2 :style released-button)))))
     (modeline-buffer-id ((t (:foreground "gray61" :background "gray8" :inverse-video nil :box (:line-width 2 :style released-button)))))
     (modeline-mousable ((t (:foreground "gray61" :background "gray8" :inverse-video nil :box (:line-width 2 :style released-button)))))
     (modeline-mousable-minor-mode ((t (:foreground "gray30" :background "gray10" :inverse-video nil :box (:line-width 2 :style released-button)))))
     (mouse ((t (:foreground "khaki" :background "gray4"))))

     (multi-region-face ((t (:background "LightSteelBlue4" :foreground "white"))))

     ;; (nxml-heading ((t ())))
     ;; (nxml-outline-indicator ((t ())))
     ;; (nxml-outline-active-indicator ((t ())))
     ;; (nxml-outline-ellipsis ((t ())))
     ;; (nxml-delimited-data ((t ())))
     ;; (nxml-name ((t ())))
     ;; (nxml-ref ((t ())))
     ;; (nxml-delimiter ((t ())))
     (nxml-text ((t ())))
     (nxml-comment-content ((t (:foreground "dark orchid"))))
     (nxml-comment-delimiter ((t (:foreground "medium orchid"))))
     (nxml-processing-instruction-delimiter ((t ,hober2-insignificant-face)))
     (nxml-processing-instruction-target ((t (:foreground "steel blue"))))
     (nxml-processing-instruction-content ((t ())))
     (nxml-cdata-section-delimiter ((t ,hober2-insignificant-face)))
     (nxml-cdata-section-CDATA ((t (:foreground "cadet blue"))))
     (nxml-cdata-section-content ((t ())))
     (nxml-char-ref-number ((t (:foreground "IndianRed1"))))
     (nxml-char-ref-delimiter ((t (:foreground "IndianRed1"))))
     (nxml-entity-ref-name ((t (:foreground "IndianRed1"))))
     (nxml-entity-ref-delimiter ((t (:foreground "IndianRed1"))))
     (nxml-tag-delimiter ((t ,hober2-insignificant-face)))
     (nxml-tag-slash ((t ,hober2-insignificant-face)))
     (nxml-element-prefix ((t (:foreground "steel blue")))) ;%
     (nxml-element-colon ((t (:foreground "steel blue"))))
     (nxml-element-local-name ((t (:foreground "cadet blue"))))
     (nxml-attribute-prefix ((t (:foreground "sandy brown"))))
     (nxml-attribute-colon ((t (:foreground "sandy brown"))))
     (nxml-attribute-local-name ((t (:foreground "sandy brown"))))
     (nxml-namespace-attribute-xmlns ((t (:foreground "sandy brown"))))
     (nxml-namespace-attribute-colon ((t (:foreground "sandy brown"))))
     (nxml-namespace-attribute-prefix ((t (:foreground "sandy brown")))) ;%
     (nxml-attribute-value ((t (:foreground "lemon chiffon"))))
     (nxml-attribute-value-delimiter ((t (:foreground "lemon chiffon"))))
     ;; (nxml-namespace-attribute-value ((t ())))
     ;; (nxml-namespace-attribute-value-delimiter ((t ())))
     (nxml-prolog-literal-delimiter ((t (:foreground "lemon chiffon"))))
     (nxml-prolog-literal-content ((t (:foreground "lemon chiffon"))))
     (nxml-prolog-keyword ((t (:foreground "cadet blue"))))
     (nxml-markup-declaration-delimiter ((t ,hober2-insignificant-face)))
     ;; (nxml-hash ((t ())))
     ;; (nxml-glyph ((t ())))

     (paren-face-match ((t (:background "cadet blue" :foreground "gray4"))))
     (paren-face-mismatch ((t (:background "indian red" :foreground "white" :bold t))))
     (paren-face-no-match ((t (:background "indian red" :foreground "white" :bold t))))

     (paren-face ((t ,hober2-insignificant-face)))

     (primary-selection ((t (:background "dark slate blue" :foreground "white"))))
     (svn-status-marked-face ((t (:background "cadet blue" :foreground "gray4"))))
     (svn-status-marked-popup-face ((t (:background "indian red" :foreground "white" :bold t))))
     (svn-status-update-available-face ((t (:background "indian red" :foreground "white"))))
     (svn-status-directory-face ((t (:foreground "khaki"))))
     (svn-status-filename-face ((t (:foreground "cadet blue"))))
     (svn-status-symlink-face ((t (:foreground "cadet blue"))))
     (svn-status-locked-face ((t (:foreground "dark orchid"))))
     (svn-status-switched-face ((t (:foreground "lemon chiffon"))))
     (svn-status-blame-highlight-face ((t (:background "DarkGreen" :foreground "light gray" :underline t))))
     (svn-status-blame-rev-number-face ((t (:background "cadet blue" :foreground "gray4"))))


     (rcirc-my-nick ((t (:foreground "light sea green"))))
     (rcirc-mode-line-nick ((t (:foreground "medium orchid" :bold t))))
     (rcirc-other-nick ((t (:foreground "cadet blue"))))
     (rcirc-nick-in-message ((t (:foreground "pale violet red" :bold t))))
     (rcirc-server ((t (:foreground "steel blue"))))
     (rcirc-prompt ((t (:foreground "pale violet red")))) ;%


     (region ((t (:background "dark slate blue" :foreground "white"))))

     (rng-error ((t ,(if (hober2-use-underline-p)
                         '(:underline "red")
                       '(:background "indian red" :foreground "white" :bold t)))))


     (scroll-bar ((t (:background "light gray" :foreground "gray4"))))

     (secondary-selection ((t (:background "LightSteelBlue4" :foreground "white"))))

     (sgml-namespace-face ((t (:foreground "steel blue")))) ;%

     (shadow ((t ,hober2-insignificant-face)))
     (sh-heredoc-face ((t (:foreground "khaki"))))
     (sh-quoted-exec ((t (:foreground "khaki"))))

     (show-paren-match-face ((t (:background "cadet blue" :foreground "gray4"))))
     (show-paren-mismatch-face ((t (:background "indian red" :foreground "white" :bold t))))

     (show-tabs-space ((t (:background "IndianRed1" :foreground "light gray"))))
     (show-tabs-space-face ((t (:background "IndianRed1" :foreground "light gray"))))
     (show-tabs-tab ((t (:background "IndianRed1" :foreground "light gray"))))
     (show-tabs-tab-face ((t (:background "IndianRed1" :foreground "light gray"))))

     (slime-error-face ((t (:background "indian red" :foreground "white" :bold t))))
     (slime-warning-face ((t (:background "indian red" :foreground "white"))))
     (slime-style-warning-face ((t (:background "indian red" :foreground "white"))))
     (slime-note-face ((t (:background "indian red" :foreground "white"))))
     (slime-highlight-face ((t (:background "indian red" :foreground "white"))))

     (sldb-catch-tag-face ((t (:foreground "khaki")))) ;%
     (sldb-condition-face ((t (:foreground "light sea green"))))
     (sldb-detailed-frame-line-face ((t ())))
     (sldb-frame-label-face ((t (:foreground "dark orchid"))))
     (sldb-frame-line-face ((t ())))
     (sldb-local-name-face ((t (:foreground "IndianRed1"))))
     (sldb-local-value-face ((t (:foreground "lemon chiffon"))))
     (sldb-reference-face ((t (:background "cyan"))))
     (sldb-restart-type-face ((t (:foreground "medium orchid"))))
     (sldb-restart-face ((t (:foreground "pale violet red"))))
     (sldb-restart-number-face ((t (:foreground "dark orchid"))))
     (sldb-section-face ((t (:foreground "sandy brown"))))
     (sldb-topline-face ((t (:foreground "IndianRed1"))))

     (slime-repl-prompt-face ((t (:foreground "pale violet red"))))
     (slime-repl-output-face ((t (:foreground "dark orchid"))))
     (slime-repl-input-face ((t (:foreground "pale violet red"))))
     (slime-repl-result-face ((t (:foreground "medium orchid"))))

     (slime-inspector-topline-face ((t (:background "gray30" :foreground "white"))))
     (slime-inspector-label-face ((t (:foreground "indian red")))) ;%
     (slime-inspector-value-face ((t (:foreground "light pink"))))
     (slime-inspector-action-face ((t (:background "cyan"))))
     (slime-inspector-type-face ((t (:foreground "light sea green")))) ;%

     (slime-reader-conditional-face ((t ,hober2-insignificant-face)))

     (speedbar-button-face ((t (:foreground "medium sea green"))))
     (speedbar-directory-face ((t (:foreground "khaki"))))
     (speedbar-file-face ((t (:foreground "cadet blue"))))
     (speedbar-highlight-face ((t (:background "DarkGreen" :foreground "light gray" :underline t))))
     (speedbar-selected-face ((t (:background "cadet blue" :foreground "gray4")))) ;%
     (speedbar-tag-face ((t (:foreground "khaki"))))

     (subscript ((t ())))
     (superscript ((t ())))
     (tex-math-face ((t (:foreground "sandy brown"))))
     (tex-math ((t (:foreground "sandy brown"))))
     (tex-verbatim-face ((t ())))
     (tex-verbatim ((t ())))

     (tool-bar ((t (:background "light gray"
                    :foreground "gray4"
                    :inverse-video nil
                    :underline t))))

     (trailing-whitespace ((t (:background "IndianRed1" :foreground "light gray"))))

     (underline ((t (:underline t))))

     (viper-search-face ((t (:background "steel blue" :foreground "lemon chiffon"))))
     (viper-replace-overlay-face ((t (:foreground "gray4" :bold t
                                      :background "light pink"))))
     (viper-minibuffer-emacs-face ((t (:foreground "gray4"
                                       :background "DarkSeaGreen2"))))
     (viper-minibuffer-insert-face ((t (:foreground "gray4" ;%
                                        :background "light pink"))))
     (viper-minibuffer-vi-face ((t (:foreground "gray4" ;%
                                    :background "light sea green"))))

     (whitespace-highlight-face ((t (:background "IndianRed1" :foreground "light gray"))))
     (widget-button-face ((t (:bold t :underline t))))
     (widget-button-pressed-face ((t (:bold t :underline t))))
     (widget-documentation-face ((t (:foreground "medium sea green")))) ;%
     (widget-field-face ((t (:background "gray30" :foreground "white"))))
     (widget-inactive-face ((t ,hober2-insignificant-face)))
     (widget-single-line-field-face ((t (:background "gray30" :foreground "white"))))

     (woman-italic-face ((t (:slant italic))))
     (woman-bold-face ((t (:bold t))))
     (woman-unknwon-face ((t (:foreground "cadet blue")))) ;%
     (woman-addition-face ((t (:foreground "medium sea green"))))
     (zmacs-region ((t (:background "dark slate blue" :foreground "white")))))))

(when (eq system-type 'darwin)
  (add-hook 'after-init-hook
            (lambda ()
              (set-face-background 'region "dark slate blue"))))


(provide 'color-theme-justin)

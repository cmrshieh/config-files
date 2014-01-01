;;; coffee-mode.el --- Major mode to edit CoffeeScript files in Emacs

;; Copyright (C) 2010 Chris Wanstrath

;; Version: 20131230.1534
;; X-Original-Version: 0.5.0
;; Keywords: CoffeeScript major mode
;; Author: Chris Wanstrath <chris@ozmm.org>
;; URL: http://github.com/defunkt/coffee-mode
;; Package-Requires: ((emacs "24.1"))

;; This file is not part of GNU Emacs.

;; This program is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation; either version 2, or (at your option)
;; any later version.

;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with this program; if not, write to the Free Software
;; Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.

;;; Commentary

;; Provides syntax highlighting, indentation support, imenu support,
;; a menu bar, and a few cute commands.

;; ## Indentation

;; ### TAB Theory

;; It goes like this: when you press `TAB`, we indent the line unless
;; doing so would make the current line more than two indentation levels
;; deepers than the previous line. If that's the case, remove all
;; indentation.

;; Consider this code, with point at the position indicated by the
;; caret:

;;     line1()
;;       line2()
;;       line3()
;;          ^

;; Pressing `TAB` will produce the following code:

;;     line1()
;;       line2()
;;         line3()
;;            ^

;; Pressing `TAB` again will produce this code:

;;     line1()
;;       line2()
;;     line3()
;;        ^

;; And so on. I think this is a pretty good way of getting decent
;; indentation with a whitespace-sensitive language.

;; ### Newline and Indent

;; We all love hitting `RET` and having the next line indented
;; properly. Given this code and cursor position:

;;     line1()
;;       line2()
;;       line3()
;;             ^

;; Pressing `RET` would insert a newline and place our cursor at the
;; following position:

;;     line1()
;;       line2()
;;       line3()

;;       ^

;; In other words, the level of indentation is maintained. This
;; applies to comments as well. Combined with the `TAB` you should be
;; able to get things where you want them pretty easily.

;; ### Indenters

;; `class`, `for`, `if`, and possibly other keywords cause the next line
;; to be indented a level deeper automatically.

;; For example, given this code and cursor position::

;;     class Animal
;;                 ^

;; Pressing enter would produce the following:

;;     class Animal

;;       ^

;; That is, indented a column deeper.

;; This also applies to lines ending in `->`, `=>`, `{`, `[`, and
;; possibly more characters.

;; So this code and cursor position:

;;     $('#demo').click ->
;;                        ^

;; On enter would produce this:

;;     $('#demo').click ->

;;       ^

;; Pretty slick.

;; Thanks to Jeremy Ashkenas for CoffeeScript, and to
;; http://xahlee.org/emacs/elisp_syntax_coloring.html, Jason
;; Blevins's markdown-mode.el and Steve Yegge's js2-mode for guidance.

;; TODO:
;; - Make prototype accessor assignments like `String::length: -> 10` pretty.
;; - mirror-mode - close brackets and parens automatically

;;; Code:

(require 'comint)
(require 'easymenu)
(require 'font-lock)
(require 'rx)

(eval-when-compile
  (require 'cl))

;;
;; Customizable Variables
;;

(defconst coffee-mode-version "0.5.0"
  "The version of `coffee-mode'.")

(defgroup coffee nil
  "A CoffeeScript major mode."
  :group 'languages)

(defcustom coffee-tab-width tab-width
  "The tab width to use when indenting."
  :type 'integer
  :group 'coffee
  :safe 'integerp)

(defcustom coffee-command "coffee"
  "The CoffeeScript command used for evaluating code."
  :type 'string
  :group 'coffee)

(defcustom coffee-js-directory ""
  "The directory for compiled JavaScript files output. This can
be an absolute path starting with a `/`, or it can be path
relative to the directory containing the coffeescript sources to
be compiled."
  :type 'string
  :group 'coffee)

(defcustom js2coffee-command "js2coffee"
  "The js2coffee command used for evaluating code."
  :type 'string
  :group 'coffee)

(defcustom coffee-args-repl '("-i")
  "The arguments to pass to `coffee-command' to start a REPL."
  :type 'list
  :group 'coffee)

(defcustom coffee-args-compile '("-c")
  "The arguments to pass to `coffee-command' to compile a file."
  :type 'list
  :group 'coffee)

(defcustom coffee-compiled-buffer-name "*coffee-compiled*"
  "The name of the scratch buffer used for compiled CoffeeScript."
  :type 'string
  :group 'coffee)

(defcustom coffee-repl-buffer "*CoffeeREPL*"
  "The name of the CoffeeREPL buffer."
  :type 'string
  :group 'coffee)

(defcustom coffee-compile-jump-to-error t
  "Whether to jump to the first error if compilation fails.
Since the coffee compiler does not always include a line number in
its error messages, this is not always possible."
  :type 'boolean
  :group 'coffee)

(defcustom coffee-watch-buffer-name "*coffee-watch*"
  "The name of the scratch buffer used when using the --watch flag
with CoffeeScript."
  :type 'string
  :group 'coffee)

(defcustom coffee-mode-hook nil
  "Hook called by `coffee-mode'.  Examples:

      ;; CoffeeScript uses two spaces.
      (make-local-variable 'tab-width)
      (set 'tab-width 2)

      ;; If you don't want your compiled files to be wrapped
      (setq coffee-args-compile '(\"-c\" \"--bare\"))

      ;; Emacs key binding
      (define-key coffee-mode-map [(meta r)] 'coffee-compile-buffer)

      ;; Bleeding edge.
      (setq coffee-command \"~/dev/coffee\")

      ;; Compile '.coffee' files on every save
      (and (file-exists-p (buffer-file-name))
           (file-exists-p (coffee-compiled-file-name))
           (coffee-cos-mode t)))"
  :type 'hook
  :group 'coffee)

(defvar coffee-mode-map
  (let ((map (make-sparse-keymap)))
    ;; key bindings
    (define-key map (kbd "A-r") 'coffee-compile-buffer)
    (define-key map (kbd "A-R") 'coffee-compile-region)
    (define-key map (kbd "A-M-r") 'coffee-repl)
    (define-key map [remap comment-dwim] 'coffee-comment-dwim)
    (define-key map [remap newline-and-indent] 'coffee-newline-and-indent)
    (define-key map "\C-m" 'coffee-newline-and-indent)
    (define-key map "\C-c\C-o\C-s" 'coffee-cos-mode)
    (define-key map "\177" 'coffee-dedent-line-backspace)
    (define-key map (kbd "C-c C-<") 'coffee-indent-shift-left)
    (define-key map (kbd "C-c C->") 'coffee-indent-shift-right)
    (define-key map (kbd "C-c C-l") 'coffee-send-line)
    (define-key map (kbd "C-c C-r") 'coffee-send-region)
    (define-key map (kbd "C-c C-b") 'coffee-send-buffer)
    (define-key map (kbd "<backtab>") 'coffee-indent-shift-left)
    (define-key map (kbd "C-M-a") 'coffee-beginning-of-defun)
    (define-key map (kbd "C-M-e") 'coffee-end-of-block)
    (define-key map (kbd "C-M-h") 'coffee-mark-defun)
    map)
  "Keymap for CoffeeScript major mode.")

;;
;; Commands
;;
(defun coffee-repl ()
  "Launch a CoffeeScript REPL using `coffee-command' as an inferior mode."
  (interactive)

  (unless (comint-check-proc coffee-repl-buffer)
    (set-buffer
     (apply 'make-comint "CoffeeREPL"
            "env"
            nil
            "NODE_NO_READLINE=1"
            coffee-command
            coffee-args-repl))

    ;; Workaround: https://github.com/defunkt/coffee-mode/issues/30
    (set (make-local-variable 'comint-preoutput-filter-functions)
         (cons (lambda (string)
                 (replace-regexp-in-string "\x1b\\[.[GJK]" "" string)) nil)))

  (pop-to-buffer coffee-repl-buffer))

(defun coffee-compiled-file-name (&optional filename)
  ;; Returns the name of the JavaScript file compiled from a CoffeeScript file.
  ;; If FILENAME is omitted, the current buffer's file name is used.
  (let ((input (expand-file-name (or filename (buffer-file-name)))))
    (unless (string= coffee-js-directory "")
      (setq input
            (expand-file-name
             (concat (unless (file-name-absolute-p coffee-js-directory)
                       (file-name-directory input))
                     (file-name-as-directory coffee-js-directory)
                     (file-name-nondirectory input)))))
    (concat (file-name-sans-extension input) ".js")))

(defun coffee-revert-buffer-compiled-file (file-name)
  "Revert a buffer of compiled file when the buffer exist and is not modified."
  (let ((buffer (find-buffer-visiting file-name)))
    (when (and buffer (not (buffer-modified-p buffer)))
      (with-current-buffer buffer
        (revert-buffer nil t)))))

(defun coffee-compile-file ()
  "Compiles and saves the current file to disk in a file of the same
base name, with extension `.js'.  Subsequent runs will overwrite the
file.

If there are compilation errors, point is moved to the first
See `coffee-compile-jump-to-error'."
  (interactive)
  (let* ((input (buffer-file-name))
         (basename (file-name-sans-extension input))
         (output (if (string-match-p "\\.js\\'" basename)
                     basename
                   (concat basename ".js")))
         (compile-cmd (coffee-command-compile input output))
         (compiler-output (shell-command-to-string compile-cmd)))
    (if (string= compiler-output "")
        (let ((file-name (coffee-compiled-file-name (buffer-file-name))))
          (message "Compiled and saved %s" output)
          (coffee-revert-buffer-compiled-file file-name))
      (let* ((msg (car (split-string compiler-output "[\n\r]+")))
             (line (when (string-match "on line \\([0-9]+\\)" msg)
                     (string-to-number (match-string 1 msg)))))
        (message msg)
        (when (and coffee-compile-jump-to-error line (> line 0))
          (goto-char (point-min))
          (forward-line (1- line)))))))

(defun coffee-compile-buffer ()
  "Compiles the current buffer and displays the JavaScript in a buffer
called `coffee-compiled-buffer-name'."
  (interactive)
  (save-excursion
    (coffee-compile-region (point-min) (point-max))))

(defun coffee-compile-region (start end)
  "Compiles a region and displays the JavaScript in a buffer called
`coffee-compiled-buffer-name'."
  (interactive "r")

  (let ((buffer (get-buffer coffee-compiled-buffer-name)))
    (when buffer
      (with-current-buffer buffer
        (erase-buffer))))

  (apply (apply-partially 'call-process-region start end coffee-command nil
                          (get-buffer-create coffee-compiled-buffer-name)
                          nil)
         (append coffee-args-compile (list "-s" "-p")))

  (let ((buffer (get-buffer coffee-compiled-buffer-name)))
    (display-buffer buffer)
    (with-current-buffer buffer
      (let ((buffer-file-name "tmp.js"))
        (set-auto-mode)))))

(defun coffee-get-repl-proc ()
  (unless (comint-check-proc coffee-repl-buffer)
    (coffee-repl))
  (get-buffer-process coffee-repl-buffer))

(defun coffee-send-line ()
  "Send the current line to the inferior Coffee process."
  (interactive)
  (coffee-send-region (line-beginning-position) (line-end-position)))

(defun coffee-send-region (start end)
  "Send the current region to the inferior Coffee process."
  (interactive "r")
  (comint-simple-send (coffee-get-repl-proc)
                      (buffer-substring-no-properties start end)))

(defun coffee-send-buffer ()
  "Send the current buffer to the inferior Coffee process."
  (interactive)
  (coffee-send-region (point-min) (point-max)))

(defun coffee-js2coffee-replace-region (start end)
  "Convert JavaScript in the region into CoffeeScript."
  (interactive "r")

  (let ((buffer (get-buffer coffee-compiled-buffer-name)))
    (when buffer
      (kill-buffer buffer)))

  (call-process-region start end
                       js2coffee-command nil
                       (current-buffer))
  (delete-region start end))

(defun coffee-version ()
  "Show the `coffee-mode' version in the echo area."
  (interactive)
  (message (concat "coffee-mode version " coffee-mode-version)))

(defun coffee-watch (dir-or-file)
  "Run `coffee-run-cmd' with the --watch flag on a directory or file."
  (interactive "fDirectory or File: ")
  (let ((coffee-compiled-buffer-name coffee-watch-buffer-name)
        (args (mapconcat 'identity (append coffee-args-compile (list "--watch" (expand-file-name dir-or-file))) " ")))
    (coffee-run-cmd args)))

;;
;; Menubar
;;

(easy-menu-define coffee-mode-menu coffee-mode-map
  "Menu for CoffeeScript mode"
  '("CoffeeScript"
    ["Compile File" coffee-compile-file]
    ["Compile Buffer" coffee-compile-buffer]
    ["Compile Region" coffee-compile-region]
    ["REPL" coffee-repl]
    "---"
    ["Version" coffee-version]
    ))

;;
;; Define Language Syntax
;;

;; Instance variables (implicit this)
(defvar coffee-this-regexp "\\(?:@\\w+\\|\\<this\\)\\>")

;; Prototype::access
(defvar coffee-prototype-regexp "[[:word:].$]+?::")

;; Assignment
(defvar coffee-assign-regexp "\\(@?[[:word:].$]+?\\)\\s-*:")

;; Local Assignment
(defvar coffee-local-assign-regexp "\\s-*\\([[:word:].$]+\\)\\s-*=\\(?:[^>]\\|$\\)")

;; Lambda
(defvar coffee-lambda-regexp "\\(?:(.+)\\)?\\s-*\\(->\\|=>\\)")

;; Namespaces
(defvar coffee-namespace-regexp "\\b\\(?:class\\s-+\\(\\S-+\\)\\)\\b")

;; Booleans
(defvar coffee-boolean-regexp
  (regexp-opt '("true" "false" "yes" "no" "on" "off" "null" "undefined")
              'words))

;; Regular expressions
(eval-and-compile
  (defvar coffee-regexp-regexp "\\s$\\(\\(?:\\\\/\\|[^/\n\r]\\)*\\)\\s$"))

;; String Interpolation(This regexp is taken from ruby-mode)
(defvar coffee-string-interpolation-regexp "#{[^}\n\\\\]*\\(?:\\\\.[^}\n\\\\]*\\)*}")

;; JavaScript Keywords
(defvar coffee-js-keywords
  '("if" "else" "new" "return" "try" "catch"
    "finally" "throw" "break" "continue" "for" "in" "while"
    "delete" "instanceof" "typeof" "switch" "super" "extends"
    "class" "until" "loop"))

;; Reserved keywords either by JS or CS.
(defvar coffee-js-reserved
  '("case" "default" "do" "function" "var" "void" "with"
    "const" "let" "debugger" "enum" "export" "import" "native"
    "__extends" "__hasProp"))

;; CoffeeScript keywords.
(defvar coffee-cs-keywords
  '("then" "unless" "and" "or" "is" "own"
    "isnt" "not" "of" "by" "when"))

;; Iced CoffeeScript keywords
(defvar iced-coffee-cs-keywords
  '("await" "defer"))

;; Regular expression combining the above three lists.
(defvar coffee-keywords-regexp
  ;; keywords can be member names.
  (regexp-opt (append coffee-js-reserved
                      coffee-js-keywords
                      coffee-cs-keywords
                      iced-coffee-cs-keywords) 'symbols))

;; Create the list for font-lock. Each class of keyword is given a
;; particular face.
(defvar coffee-font-lock-keywords
  ;; *Note*: order below matters. `coffee-keywords-regexp' goes last
  ;; because otherwise the keyword "state" in the function
  ;; "state_entry" would be highlighted.
  `((,coffee-regexp-regexp . font-lock-constant-face)
    (,coffee-this-regexp . font-lock-variable-name-face)
    (,coffee-prototype-regexp . font-lock-type-face)
    (,coffee-assign-regexp . font-lock-type-face)
    (,coffee-local-assign-regexp 1 font-lock-variable-name-face)
    (,coffee-boolean-regexp . font-lock-constant-face)
    (,coffee-lambda-regexp 1 font-lock-function-name-face)
    (,coffee-keywords-regexp 1 font-lock-keyword-face)
    (,coffee-string-interpolation-regexp 0 font-lock-variable-name-face t)))

;;
;; Helper Functions
;;

(defun coffee-comment-dwim (arg)
  "Comment or uncomment current line or region in a smart way.
For details, see `comment-dwim'."
  (interactive "*P")
  (require 'newcomment)
  (let ((deactivate-mark nil) (comment-start "#") (comment-end ""))
    (comment-dwim arg)))

(defsubst coffee-command-compile-arg-as-string (output)
  (mapconcat 'identity
             (or (and output (append coffee-args-compile (list "-j" output)))
                 coffee-args-compile)
             " "))

(defun coffee-command-compile (input &optional output)
  "Run `coffee-command' to compile FILE-NAME to file with default
.js output file, or optionally to OUTPUT-FILE-NAME."
  (let* ((full-file-name (expand-file-name input))
         (output-file (coffee-compiled-file-name full-file-name))
         (output-dir (file-name-directory output-file)))
    (unless (file-directory-p output-dir)
      (make-directory output-dir t))
    (format "%s %s -o %s %s"
            (shell-quote-argument coffee-command)
            (coffee-command-compile-arg-as-string output)
            (shell-quote-argument output-dir)
            (shell-quote-argument full-file-name))))

(defun coffee-run-cmd (args)
  "Run `coffee-command' with the given arguments, and display the
output in a compilation buffer."
  (interactive "sArguments: ")
  (let ((compilation-buffer-name-function
         (lambda (this-mode)
           (generate-new-buffer-name coffee-compiled-buffer-name))))
    (compile (concat coffee-command " " args))))

;;
;; imenu support
;;

(defconst coffee-imenu-index-regexp
  (concat "^\\(\\s-*\\)" ; $1
          "\\(?:"
          coffee-assign-regexp ; $2
          "\\s-+"
          coffee-lambda-regexp
          "\\|"
          coffee-namespace-regexp ; $4
          "\\|"
          "\\(@?[[:word:]:.$]+\\)\\s-*=\\(?:[^>]\\|$\\)" ; $5 match prototype access too
          "\\(?:" "\\s-*" "\\(" coffee-lambda-regexp "\\)" "\\)?" ; $6
          "\\)"))

(defun coffee-imenu-create-index ()
  "Create an imenu index of all methods in the buffer."
  (interactive)

  ;; This function is called within a `save-excursion' so we're safe.
  (goto-char (point-min))

  (let ((index-alist '())
        (ns-indent 0)
        ns-name)
    ;; Go through every assignment that includes -> or => on the same
    ;; line or starts with `class'.
    (while (re-search-forward coffee-imenu-index-regexp nil t)
      (let ((current-indent (- (match-end 1) (match-beginning 1)))
            (property-name (match-string-no-properties 2))
            (class-name (match-string-no-properties 4))
            (variable-name (match-string-no-properties 5))
            (func-assign (match-string-no-properties 6)))

        ;; If this is the start of a new namespace, save the namespace's
        ;; indentation level and name.
        (if class-name
            (setq ns-name (concat class-name "::")
                  ns-indent current-indent)
          (when (and variable-name (<= current-indent ns-indent))
            (setq ns-name (concat variable-name ".")
                  ns-indent current-indent)))

        (if func-assign
            (push (cons variable-name (match-beginning 5)) index-alist)
          (when (and ns-name property-name)
            (let ((index-pos (match-beginning 2)))
              (if (<= current-indent ns-indent)
                  ;; Clear the namespace if we're no longer indented deeper
                  (setq ns-name nil ns-indent nil)
                ;; Register as index-name if we are within the context of a namespace
                (push (cons (concat ns-name property-name) index-pos) index-alist)))))))
    index-alist))

;;
;; Indentation
;;

(defsubst coffee-insert-spaces (count)
  (insert-char ?  count))

;;; The theory is explained in the README.

(defun coffee-indent-line ()
  "Indent current line as CoffeeScript."
  (interactive)

  (if (= (point) (line-beginning-position))
      (coffee-insert-spaces coffee-tab-width)
    (save-excursion
      (let ((prev-indent (coffee-previous-indent))
            (cur-indent (current-indentation)))
        ;; Shift one column to the left
        (beginning-of-line)
        (coffee-insert-spaces coffee-tab-width)

        (when (= (point-at-bol) (point))
          (forward-char coffee-tab-width))

        ;; We're too far, remove all indentation.
        (when (> (- (current-indentation) prev-indent) coffee-tab-width)
          (backward-to-indentation 0)
          (delete-region (point-at-bol) (point)))))))

(defun coffee-previous-indent ()
  "Return the indentation level of the previous non-blank line."
  (save-excursion
    (forward-line -1)
    (if (bobp)
        0
      (while (and (looking-at "^[ \t]*$") (not (bobp)))
        (forward-line -1))
      (current-indentation))))

(defun coffee-newline-and-indent ()
  "Insert a newline and indent it to the same level as the previous line."
  (interactive)

  ;; Remember the current line indentation level,
  ;; insert a newline, and indent the newline to the same
  ;; level as the previous line.
  (let ((prev-indent (current-indentation))
        (indent-next nil))
    (delete-horizontal-space t)
    (newline)
    (coffee-insert-spaces prev-indent)

    ;; We need to insert an additional tab because the last line was special.
    (when (coffee-line-wants-indent)
      (coffee-insert-spaces coffee-tab-width))

    ;; Last line was a comment so this one should probably be,
    ;; too. Makes it easy to write multi-line comments (like the one I'm
    ;; writing right now).
    (when (coffee-previous-line-is-single-line-comment)
      (insert "# "))))

(defun coffee-dedent-line-backspace (arg)
  "Unindent to increment of `coffee-tab-width' with ARG==1 when
called from first non-blank char of line.

Delete ARG spaces if ARG!=1."
  (interactive "*p")
  (if (and (= 1 arg)
           (= (point) (save-excursion
                        (back-to-indentation)
                        (point)))
           (not (bolp)))
      (let ((extra-space-count (% (current-column) coffee-tab-width)))
        (backward-delete-char-untabify
         (if (zerop extra-space-count)
             coffee-tab-width
           extra-space-count)))
    (backward-delete-char-untabify arg)))

;; Indenters help determine whether the current line should be
;; indented further based on the content of the previous line. If a
;; line starts with `class', for instance, you're probably going to
;; want to indent the next line.

(defvar coffee-indenters-bol '("class" "for" "if" "else" "while" "until"
                               "try" "catch" "finally" "switch")
  "Keywords or syntax whose presence at the start of a line means the
next line should probably be indented.")

(defun coffee-indenters-bol-regexp ()
  "Builds a regexp out of `coffee-indenters-bol' words."
  (regexp-opt coffee-indenters-bol 'words))

(defvar coffee-indenters-eol '(?> ?{ ?\[)
  "Single characters at the end of a line that mean the next line
should probably be indented.")

(defun coffee-line-wants-indent ()
  "Return t if the current line should be indented relative to the
previous line."
  (save-excursion
    (back-to-indentation)
    (skip-chars-backward "\r\n\t ")
    (let ((char-of-eol (char-before (line-end-position))))
      (or (and char-of-eol (memq char-of-eol coffee-indenters-eol))
          (progn
            (back-to-indentation)
            (looking-at (coffee-indenters-bol-regexp)))))))

(defun coffee-previous-line-is-single-line-comment ()
  "Return t if the previous line is a CoffeeScript single line comment."
  (save-excursion
    (forward-line -1)
    (back-to-indentation)
    (and (looking-at "#")
         (not (looking-at "###\\(?:\\s-+.*\\)?$"))
         (progn
           (goto-char (line-end-position))
           (nth 4 (syntax-ppss))))))

(defun coffee-indent-shift-amount (start end dir)
  "Compute distance to the closest increment of `coffee-tab-width'."
  (let ((min most-positive-fixnum))
    (save-excursion
      (goto-char start)
      (while (< (point) end)
        (let ((current (current-indentation)))
          (when (< current min)
            (setq min current)))
        (forward-line))
      (let ((rem (% min coffee-tab-width)))
        (if (zerop rem)
            coffee-tab-width
          (cond ((eq dir 'left) rem)
                ((eq dir 'right) (- coffee-tab-width rem))
                (t 0)))))))

(defun coffee-indent-shift-left (start end &optional count)
  "Shift lines contained in region START END by COUNT columns to the left.
If COUNT is not given, indents to the closest increment of
`coffee-tab-width'. If region isn't active, the current line is
shifted. The shifted region includes the lines in which START and
END lie. An error is signaled if any lines in the region are
indented less than COUNT columns."
  (interactive
   (if mark-active
       (list (region-beginning) (region-end) current-prefix-arg)
     (list (line-beginning-position) (line-end-position) current-prefix-arg)))
  (let ((amount (if count (prefix-numeric-value count)
                  (coffee-indent-shift-amount start end 'left))))
    (when (> amount 0)
      (let (deactivate-mark)
        (save-excursion
          (goto-char start)
          ;; Check that all lines can be shifted enough
          (while (< (point) end)
            (if (and (< (current-indentation) amount)
                     (not (looking-at "[ \t]*$")))
                (error "Can't shift all lines enough"))
            (forward-line))
          (indent-rigidly start end (- amount)))))))

(add-to-list 'debug-ignored-errors "^Can't shift all lines enough")

(defun coffee-indent-shift-right (start end &optional count)
  "Shift lines contained in region START END by COUNT columns to the right.
if COUNT is not given, indents to the closest increment of
`coffee-tab-width'. If region isn't active, the current line is
shifted. The shifted region includes the lines in which START and
END lie."
  (interactive
   (if mark-active
       (list (region-beginning) (region-end) current-prefix-arg)
     (list (line-beginning-position) (line-end-position) current-prefix-arg)))
  (let (deactivate-mark
        (amount (if count (prefix-numeric-value count)
                  (coffee-indent-shift-amount start end 'right))))
    (indent-rigidly start end amount)))

;;
;; Fill
;;

(defun coffee-fill-forward-paragraph-function (&optional count)
  "`fill-forward-paragraph-function' which correctly handles block
comments such as the following:

  class Klass
    method: ->
      ###
      This is a method doc comment that spans multiple lines.
      If `fill-paragraph' is applied to this paragraph, the comment
      should preserve its format, with the delimiters on separate lines.
      ###
      ..."
  (let ((ret (forward-paragraph count)))
    (when (and (= count -1)
               (looking-at "[[:space:]]*###[[:space:]]*$"))
      (forward-line))
    ret))

;;
;; Define navigation functions
;;

(defconst coffee-defun-regexp
  (concat "^\\s-*\\(?:"
          coffee-assign-regexp
          "\\s-+"
          coffee-lambda-regexp
          "\\|"
          coffee-namespace-regexp
          "\\|"
          "@?[[:word:]:.$]+\\s-*=\\(?:[^>]\\|$\\)"
          "\\s-*"
          coffee-lambda-regexp
          "\\)"))

(defun coffee-in-comment-p ()
  (unless (eobp)
    (save-excursion
      (back-to-indentation)
      (when (eq (char-after) ?#)
        (forward-char 1))
      (nth 4 (syntax-ppss)))))

(defsubst coffee-current-line-empty-p ()
  (let ((line (buffer-substring-no-properties
               (line-beginning-position) (line-end-position))))
    (string-match-p "^\\s-*$" line)))

(defun coffee-current-line-is-defun ()
  (save-excursion
    (goto-char (line-end-position))
    (re-search-backward coffee-defun-regexp (line-beginning-position) t)))

(defun coffee-current-line-is-assignment ()
  (save-excursion
    (goto-char (line-end-position))
    (re-search-backward "^[[:word:].$]+\\s-*=\\(?:[^>]\\|$\\)"
                        (line-beginning-position) t)))

(defun coffee-curline-defun-type (parent-indent start-is-defun)
  (save-excursion
    (goto-char (line-end-position))
    (if (not (re-search-backward coffee-defun-regexp (line-beginning-position) t))
        (when (and (zerop parent-indent) (coffee-current-line-is-assignment))
          'other)
      (if (not start-is-defun)
          'other
        (if (< parent-indent (current-indentation))
            'child
          'other)))))

(defun coffee-same-block-p (block-indent start-is-defun)
  (let ((type (coffee-curline-defun-type block-indent start-is-defun)))
    (cond ((eq type 'child) t)
          ((eq type 'other) nil)
          (t (>= (current-indentation) block-indent)))))

(defsubst coffee-skip-line-p ()
  (or (coffee-in-comment-p) (coffee-current-line-empty-p)))

(defun coffee-skip-forward-lines (arg)
  (let ((pred (if (> arg 0)
                  (lambda () (not (eobp)))
                (lambda () (not (bobp))))))
   (while (and (funcall pred) (coffee-skip-line-p))
     (forward-line arg))))

(defun coffee-beginning-of-defun (&optional count)
  (interactive "p")
  (unless count
    (setq count 1))
  (let ((next-indent nil))
    (when (coffee-skip-line-p)
      (save-excursion
        (coffee-skip-forward-lines +1)
        (setq next-indent (current-indentation))))
    (coffee-skip-forward-lines -1)
    (let ((start-indent (or next-indent (current-indentation))))
      (when (and (not (eq this-command 'coffee-mark-defun)) (looking-back "^\\s-*"))
        (forward-line -1))
      (let ((finish nil))
        (goto-char (line-end-position))
        (while (and (not finish) (re-search-backward coffee-defun-regexp nil 'move))
          (let ((cur-indent (current-indentation)))
            (when (<= cur-indent start-indent)
              (setq start-indent cur-indent)
              (decf count)))
          (when (<= count 0)
            (back-to-indentation)
            (setq finish t)))))))

(defun coffee-end-of-block (&optional count)
  "Move point to the end of the block."
  (interactive "p")
  (unless count
    (setq count 1))
  (dotimes (i count)
    (let* ((curline-is-defun (coffee-current-line-is-defun))
           start-indent)
      (coffee-skip-forward-lines 1)
      (setq start-indent (current-indentation))
      (when (and (zerop start-indent) (not curline-is-defun))
        (when (re-search-forward coffee-defun-regexp nil 'move)
          (back-to-indentation)
          (setq curline-is-defun t)))
      (let ((finish nil))
        (while (not finish)
          (forward-line 1)
          (coffee-skip-forward-lines 1)
          (when (or (not (coffee-same-block-p start-indent curline-is-defun))
                    (eobp))
            (setq finish t)))
        (forward-line -1)
        (coffee-skip-forward-lines -1)
        (forward-line 1)))))

(defun coffee-mark-defun ()
  (interactive)
  (let ((be-actived transient-mark-mode))
    (push-mark (point))
    (let ((cur-indent (current-indentation)))
      (coffee-beginning-of-defun)
      (push-mark (point))
      (coffee-end-of-block)
      (push-mark (point) nil be-actived)
      (let ((next-indent nil))
        (when (coffee-skip-line-p)
          (save-excursion
            (coffee-skip-forward-lines +1)
            (setq next-indent (current-indentation))))
        (when (and next-indent (< next-indent cur-indent))
          (coffee-skip-forward-lines -1))
        (coffee-beginning-of-defun)))))

;;
;; hs-minor-mode
;;

;; support for hs-minor-mode
(add-to-list 'hs-special-modes-alist
             '(coffee-mode "\\s-*\\(?:class\\|.+[-=]>$\\)" nil "#"
                           coffee-end-of-block nil))

;;
;; Based on triple quote of python.el
;;
(eval-and-compile
  (defconst coffee-block-strings-delimiter
    (rx (and
         ;; Match even number of backslashes.
         (or (not (any ?\\ ?\' ?\"))
             point
             ;; Quotes might be preceded by a escaped quote.
             (and (or (not (any ?\\)) point)
                  ?\\
                  (* ?\\ ?\\)
                  (any ?\' ?\")))
         (* ?\\ ?\\)
         ;; Match single or triple quotes of any kind.
         (group (or "'''" "\"\"\""))))))

(defsubst coffee-syntax-count-quotes (quote-char start-point limit)
  (let ((i 0))
    (while (and (< i 3)
                (< (+ start-point i) limit)
                (eq (char-after (+ start-point i)) quote-char))
      (incf i))
    i))

(defun coffee-syntax-block-strings-stringify ()
  (let* ((ppss (prog2
                   (backward-char 3)
                   (syntax-ppss)
                 (forward-char 3)))
         (string-start (and (not (nth 4 ppss)) (nth 8 ppss)))
         (quote-starting-pos (- (point) 3))
         (quote-ending-pos (point))
         (num-closing-quotes
          (and string-start
               (coffee-syntax-count-quotes
                (char-before) string-start quote-starting-pos))))
    (cond ((and string-start (= num-closing-quotes 0))
           ;; This set of quotes doesn't match the string starting
           ;; kind. Do nothing.
           nil)
          ((not string-start)
           ;; This set of quotes delimit the start of a string.
           (put-text-property quote-starting-pos (1+ quote-starting-pos)
                              'syntax-table (string-to-syntax "|")))
          ((= num-closing-quotes 3)
           ;; This set of quotes delimit the end of a string.
           (put-text-property (1- quote-ending-pos) quote-ending-pos
                              'syntax-table (string-to-syntax "|"))))))

(defun coffee-syntax-propertize-function (start end)
  (goto-char start)
  (funcall
   (syntax-propertize-rules
    (coffee-block-strings-delimiter
     (0 (ignore (coffee-syntax-block-strings-stringify))))
    ("\\(?:[^\\]\\)\\(/\\)"
     (1 (ignore
         (let ((ppss (progn
                       (goto-char (match-beginning 1))
                       (syntax-ppss))))
           (when (nth 8 ppss)
             (put-text-property (match-beginning 1) (match-end 1)
                                'syntax-table (string-to-syntax "_")))))))
    (coffee-regexp-regexp (1 (string-to-syntax "_")))
    ("^[[:space:]]*\\(###\\)\\([[:space:]]+.*\\)?$"
     (1 (ignore
         (let ((after-triple-hash (match-string-no-properties 2)))
           (when (or (not after-triple-hash)
                     (not (string-match-p "###\\'" after-triple-hash)))
             (put-text-property (match-beginning 1) (match-end 1)
                                'syntax-table (string-to-syntax "!"))))))))
   (point) end))

;;
;; Define Major Mode
;;

;;;###autoload
(define-derived-mode coffee-mode prog-mode "Coffee"
  "Major mode for editing CoffeeScript."

  ;; code for syntax highlighting
  (setq font-lock-defaults '((coffee-font-lock-keywords)))

  ;; treat "_" as part of a word
  (modify-syntax-entry ?_ "w" coffee-mode-syntax-table)

  ;; perl style comment: "# ..."
  (modify-syntax-entry ?# "< b" coffee-mode-syntax-table)
  (modify-syntax-entry ?\n "> b" coffee-mode-syntax-table)

  ;; Treat slashes as paired delimiters; useful for finding regexps.
  (modify-syntax-entry ?/ "$" coffee-mode-syntax-table)

  (set (make-local-variable 'comment-start) "#")

  ;; single quote strings
  (modify-syntax-entry ?' "\"" coffee-mode-syntax-table)

  ;; indentation
  (make-local-variable 'coffee-tab-width)
  (set (make-local-variable 'indent-line-function) 'coffee-indent-line)
  (set (make-local-variable 'tab-width) coffee-tab-width)

  (set (make-local-variable 'syntax-propertize-function)
       'coffee-syntax-propertize-function)

  ;; fill
  (set (make-local-variable 'fill-forward-paragraph-function)
       'coffee-fill-forward-paragraph-function)

  (set (make-local-variable 'beginning-of-defun-function)
       'coffee-beginning-of-defun)
  (set (make-local-variable 'end-of-defun-function)
       'coffee-end-of-block)

  ;; imenu
  (set (make-local-variable 'imenu-create-index-function)
       'coffee-imenu-create-index)

  ;; Don't let electric-indent-mode break coffee-mode.
  (set (make-local-variable 'electric-indent-functions)
       (list (lambda (arg) 'no-indent)))

  ;; no tabs
  (setq indent-tabs-mode nil))

;;
;; Compile-on-Save minor mode
;;

(defcustom coffee-cos-mode-line " CoS"
  "Lighter of `coffee-cos-mode'"
  :type 'string
  :group 'coffee)

(define-minor-mode coffee-cos-mode
  "Toggle compile-on-save for coffee-mode.

Add `'(lambda () (coffee-cos-mode t))' to `coffee-mode-hook' to turn
it on by default."
  :group 'coffee :lighter coffee-cos-mode-line
  (if coffee-cos-mode
      (add-hook 'after-save-hook 'coffee-compile-file nil t)
    (remove-hook 'after-save-hook 'coffee-compile-file t)))

(provide 'coffee-mode)

;;
;; On Load
;;

;; Run coffee-mode for files ending in .coffee.
;;;###autoload
(add-to-list 'auto-mode-alist '("\\.coffee\\'" . coffee-mode))
;;;###autoload
(add-to-list 'auto-mode-alist '("\\.iced\\'" . coffee-mode))
;;;###autoload
(add-to-list 'auto-mode-alist '("Cakefile\\'" . coffee-mode))
;;;###autoload
(add-to-list 'interpreter-mode-alist '("coffee" . coffee-mode))

;;; coffee-mode.el ends here

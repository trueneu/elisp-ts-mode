(require 'elisp-mode)

;; TODO: add:
;; - dolist bindings
;; - function declarations (defun, maybe lambdas, aio-defun)
;; -

(defvar elisp-ts--binding-special-forms
  ["let" "let*"]
  "Special forms binding variables.")

(defvar elisp-ts-font-lock-rules
  `(:language elisp
    :override t
    :feature comment
    ((function_definition
      name: (symbol) @font-lock-function-name-face))

    :language elisp
    :override t
    :feature comment
    (((function_definition
       parameters: (list (symbol) @font-lock-variable-name-face))
      (:match "\\(?:^[^&]\\)" @font-lock-variable-name-face))) ;; match anything that doesn't start with &

    :language elisp
    :override t
    :feature comment
    ((comment) @font-lock-comment-face)

    :language elisp
    :override t
    :feature comment
    ((((list :anchor (symbol) @font-lock-comment-face))
      (:match "\\`comment\\'" @font-lock-comment-face)))

    ;; FIXME: features
    :language elisp
    :override t
    :feature comment
    ;; can I specify more than one string here? what is string here, a regex? Or full text? maybe a vector?
    (((special_form ,elisp-ts--binding-special-forms :anchor (list (list ((symbol) @font-lock-variable-name-face (_)))))))

    :language elisp
    :override t
    :feature comment
    (((special_form ,elisp-ts--binding-special-forms :anchor (list (symbol) @font-lock-variable-name-face))))

    :language elisp
    :override t
    :feature comment
    ((((symbol) @variable-declaration :anchor (symbol) @font-lock-variable-name-face)
      (:match "\\`\\(defcustom\\|defvar-local\\)\\'" @variable-declaration)))

    :language elisp
    :override t
    :feature comment
    (((special_form "defvar" (symbol) @font-lock-variable-name-face)))

    ;; TODO: string
    :language elisp
    :override t
    :feature constant
    (((string) @font-lock-string-face))

    :language elisp
    :override t
    :feature constant
    (((integer) @font-lock-constant-face))

    :language elisp
    :override t
    :feature constant
    (((float) @font-lock-constant-face))

    :language elisp
    :override t
    :feature constant
    (((symbol ["t" "nil"]) @font-lock-constant-face))

    :language elisp
    :override t
    :feature constant
    (((symbol) @font-lock-constant-face
      (:match "\\`:" @font-lock-constant-face)))))

(rx (or "blah"
        "foo"))

(defun elisp-ts-setup ()
  "Handle the TS setup."
  (setq-local
   treesit-font-lock-feature-list
   '((comment)
     (constant tag attribute)
     (declaration)
     (delimiter)))

  (setq-local
   treesit-font-lock-settings
   (apply #'treesit-font-lock-rules
          elisp-ts-font-lock-rules))

  (treesit-major-mode-setup))

;;;###autoload
(define-derived-mode elisp-ts-mode emacs-lisp-mode "ELisp [TS]"
  "Major mode for emacs lisp with tree-sitter."
  :syntax-table emacs-lisp-mode-syntax-table

  (setq-local font-lock-defaults nil)
  (when (treesit-ready-p 'elisp)
    (treesit-parser-create 'elisp))
  (elisp-ts-setup))


(provide 'elisp-ts)

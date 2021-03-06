;; (require 'python)
(require 'comint)

(setq gud-pdb-command-name "python -m pdb ")

(eval-after-load 'python
  '(progn
     (evil-make-overriding-map inferior-python-mode-map 'motion)
     (evil-make-overriding-map inferior-python-mode-map 'normal)
     (bind-key "C-d" 'evil-scroll-down inferior-python-mode-map)

     (add-hook 'python-mode-hook
       (lambda ()
         (setq-local tab-width 4)
         (setq python-indent-offset 4)))))

(add-to-list 'comint-output-filter-functions 'python-pdbtrack-comint-output-filter-function)
(add-to-list 'comint-preoutput-filter-functions  'python-pdbtrack-comint-output-filter-function)

(use-package elpy
  :hook (python-mode . elpy-enable)
  :bind (:map elpy-mode-map
          ("C-c C-l" . elpy-occur-definitions)
          ("C-c C-e" . elpy-multiedit-python-symbol-at-point)
          ("C-c C-r f" . elpy-format-code)
          ("C-c C-r r" . elpy-refactor))
  :config
  (setq
    elpy-modules (delq 'elpy-module-highlight-indentation elpy-modules)
    elpy-modules (delq 'elpy-module-flymake elpy-modules)
    elpy-rpc-backend "jedi"
    python-shell-interpreter "ipython"
    python-shell-interpreter-args "-i --simple-prompt")

  (evil-define-key '(normal motion visual) elpy-mode-map
    (kbd "M-.") #'xref-find-definitions
    (kbd "M-,") #'xref-pop-marker-stack)

  ;; (setq
  ;; python-shell-interpreter "python"
  ;; python-shell-interpreter-args "-i")

  ;; (elpy-enable)
  ;; (add-hook 'elpy-mode-hook 'flycheck-mode)

  (advice-add 'keyboard-quit :before 'elpy-multiedit-stop)

  ;; https://www.thedigitalcatonline.com/blog/2020/07/18/emacs-configuration-for-python-javascript-terraform-and-blogging/
  ;; Prevent Elpy from overriding Windmove shortcuts
  ;; (eval-after-load "elpy"
  ;;   '(cl-dolist (key '("M-<up>" "M-<down>" "M-<left>" "M-<right>"))
  ;;      (define-key elpy-mode-map (kbd key) nil)))

  ;; Prevent Elpy from overriding standard cursor movements
  ;; (eval-after-load "elpy"
  ;;   '(cl-dolist (key '("C-<left>" "C-<right>"))
  ;;      (define-key elpy-mode-map (kbd key) nil)))

  (when (executable-find "black")
    (add-hook 'elpy-mode-hook
      (lambda () (add-hook 'before-save-hook 'elpy-black-fix-code nil t)))))

;; (use-package guess-style
;; :config
;; (progn
;; (add-hook 'python-mode-hook 'guess-style-guess-tabs-mode)))

(provide 'my-python)
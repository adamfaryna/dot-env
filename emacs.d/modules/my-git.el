(require 'smerge-mode)
(require 'vc-git)
;; (require 'git-rebase)

;; (use-package git-timemachine)

(setq vc-follow-symlinks t)
(setq vc-handled-backends '(Git))

(use-package smerge-mode
  :bind (:map smerge-mode-map
          ("[w" . #'smerge-prev)
          ("]w" . #'smerge-next)))

(use-package projectile
  :diminish projectile-mode
  :custom
  (projectile-completion-system 'ivy)
  (projectile-indexing-method 'hybrid)
  (projectile-enable-caching t)
  (projectile-verbose nil)
  (projectile-do-log nil)
  (projectile-mode-line '(:eval (format " [%s]" (projectile-project-name))))
  (projectile-track-known-projects-automatically nil)
  (projectile-globally-ignored-file-suffixes '(".png" ".gif" ".pdf" ".class"))
  (projectile-globally-ignored-files '("TAGS" ".DS_Store" ".keep"))
  :config
  (setq projectile-globally-ignored-directories (append '("node-modules" "dist" "target" "*elpa") projectile-globally-ignored-directories))

  (unbind-key "C-c p" projectile-mode-map)

  (if (executable-find "ctags")
    (setq projectile-tags-command "ctags -R -e .")
    (user-error "'ctags' not installed!"))

  ;; (add-hook 'projectile-after-switch-project-hook (lambda () (my/projectile-invalidate-cache nil)))
  (projectile-mode 1))

(use-package counsel-projectile
  :after projectile ivy
  :config
  (counsel-projectile-mode 1))

  ;; (add-hook 'after-init-hook
  ;;           (lambda ()
  ;;             (mapc (lambda (project-root)
  ;;                     (remhash project-root projectile-project-type-cache)
  ;;                     (remhash project-root projectile-projects-cache)
  ;;                     (remhash project-root projectile-projects-cache-time)
  ;;                     (when projectile-verbose
  ;;                       (message "Invalidated Projectile cache for %s."
  ;;                                (propertize project-root 'face 'font-lock-keyword-face))))
  ;;                   projectile-known-projects)
  ;;             (projectile-serialize-cache))))

(defun jarfar/projectile-show-relative-path ()
  (interactive)
  (when (projectile-project-root)
    (message (substring buffer-file-name (length (projectile-project-root))))))

(defun my/projectile-add-known-project (project-root)
  (interactive (list (read-directory-name "Add to known projects: ")))
  (projectile-add-known-project project-root)
  (projectile-cleanup-known-projects))

(defun my/projectile-invalidate-cache (arg)
  "Remove the current project's files from `projectile-projects-cache'.

With a prefix argument ARG prompts for the name of the project whose cache
to invalidate."
  (interactive "P")
  (let ((project-root
         (if arg
             (completing-read "Remove cache for: " projectile-projects-cache)
           (projectile-project-root))))
    (setq projectile-project-root-cache (make-hash-table :test 'equal))
    (remhash project-root projectile-project-type-cache)
    (remhash project-root projectile-projects-cache)
    (remhash project-root projectile-projects-cache-time)
    (projectile-serialize-cache)
    (when projectile-verbose
      (message "Invalidated Projectile cache for %s."
               (propertize project-root 'face 'font-lock-keyword-face)))))

;; (use-package counsel-projectile
;;   :config
;;   (progn
;;     (counsel-projectile-mode 1)))

(use-package git-commit
  :custom
  (git-commit-style-convention-checks nil))

(use-package git-gutter
  :diminish git-gutter-mode
  :demand t
  :bind (("C-c p" . 'git-gutter:previous-hunk)
          ("C-c n" . 'git-gutter:next-hunk))
  :config
  (global-git-gutter-mode 1))

(use-package git-rebase
  :ensure nil
  :config
  (add-hook 'git-rebase-mode-hook (lambda () (read-only-mode -1))))

;; magit dependency
(use-package transient
  :defer 0.3)

(use-package magit
  :defer 0.3
  :diminish magit-auto-revert-mode
  :after transient
  :hook ((magit-git-mode . (lambda () (read-only-mode nil)))
          (magit-status-mode . (lambda () (save-some-buffers t))))
  :bind (:map magit-mode-map
          ("|" . evil-window-set-width)
          ("}" . evil-forward-paragraph)
          ("]" . evil-forward-paragraph)
          ("{" . evil-backward-paragraph)
          ("[" . evil-backward-paragraph)
          ("C-d" . evil-scroll-down)
          ("C-u" . evil-scroll-up)
          ("C-s" . isearch-forward)
          ("=" . balance-windows)
          ("C-w" . my/copy-diff-region)
          :map magit-process-mode-map
          ("k" . magit-process-kill)
          :map magit-file-section-map
          ("RET" . magit-diff-visit-file-other-window)
          :map magit-hunk-section-map
          ("r" . magit-reverse)
          ("v" . evil-visual-char)
          ("RET" . magit-diff-visit-file-other-window)
          :map magit-revision-mode-map
          ("C-s" . isearch-forward)
          ("n" . evil-search-next)
          ("p" . evil-search-previous)
          ("=" . balance-windows)
          :map magit-status-mode-map
          ("\\w" . avy-goto-word-or-subword-1)
          ("\\c" . avy-goto-char))
  :custom
  (magit-completing-read-function 'ivy-completing-read)
  (magit-refresh-status-buffer nil)
  (magit-item-highlight-face 'bold)
  (magit-diff-paint-whitespace nil)
  (magit-ediff-dwim-show-on-hunks t)
  (magit-diff-hide-trailing-cr-characters t)
  (magit-bury-buffer-function 'quit-window)
  (magit-commit-ask-to-stage nil)
  (magit-commit-squash-confirm nil)
  (magit-no-confirm '(stage-all-changes unstage-all-changes set-and-push edit-published rebase-published amend-published))
  (auto-revert-buffer-list-filter 'magit-auto-revert-repository-buffer-p)
  (magit-blame-styles '((margin
                          (margin-format " %s%f" " %C %a" " %H")
                          (margin-width . 42)
                          (margin-face . magit-blame-margin)
                          (margin-body-face magit-blame-dimmed))
                         (headings
                           (heading-format . "%-20a %C %s"))))
  :config
  (add-to-list 'magit-blame-disable-modes 'evil-mode)

  (defalias 'magit-blame-echo 'magit-blame-addition)

  (magit-add-section-hook 'magit-status-sections-hook 'magit-insert-unpushed-to-upstream 'magit-insert-unpushed-to-upstream-or-recent)
  (magit-add-section-hook 'magit-status-sections-hook 'magit-insert-recent-commits 'magit-insert-unpushed-to-upstream-or-recent)
  (remove-hook 'magit-status-sections-hook 'magit-insert-unpushed-to-upstream-or-recent))

(defun my/copy-diff-region ()
  "Copy diff region without + or - markers."
  (interactive)
  (deactivate-mark)
  (let ((text (buffer-substring-no-properties
               (region-beginning) (region-end))))
    (kill-new (replace-regexp-in-string "^[\\+\\-]" "" text))))

(provide 'my-git)
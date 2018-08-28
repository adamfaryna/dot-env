(use-package evil
  :init
  (progn
    (setq
      evil-want-C-u-scroll t
      evil-want-C-i-jump nil))
  :config
  (progn
    (evil-mode 1)
    (bind-key "C-d"    #'evil-scroll-down)
    (bind-key "C-u"    #'evil-scroll-up)
    (bind-key "C-e"    #'move-end-of-line                    evil-normal-state-map)
    (bind-key "C-e"    #'move-end-of-line                    evil-visual-state-map)
    (bind-key "C-a"    #'my/smarter-move-beginning-of-line   evil-normal-state-map)
    (bind-key "C-a"    #'my/smarter-move-beginning-of-line   evil-visual-state-map)
    (bind-key "TAB"    #'indent-for-tab-command              evil-normal-state-map)
    (bind-key "TAB"    #'indent-for-tab-command              evil-visual-state-map)
    (bind-key "TAB"    #'tab-to-tab-stop                     evil-insert-state-map)
    ;; (bind-key "/"      #'swiper                              evil-normal-state-map)
    (bind-key "C-x T"  #'my/move-current-window-to-new-frame evil-normal-state-map)
    (bind-key ", s"    #'flyspell-mode                       evil-normal-state-map)
    (bind-key ", g s"  #'magit-status                        evil-normal-state-map)
    (bind-key "C-w"    #'evil-delete-char                    evil-visual-state-map)
    (bind-key "h"      #'evil-first-non-blank                evil-normal-state-map)
    (bind-key "h"      #'evil-first-non-blank                evil-visual-state-map)
    (bind-key "l"      #'evil-end-of-line                    evil-normal-state-map)
    (bind-key "l"      #'evil-end-of-line                    evil-visual-state-map)
    (bind-key "}"      #'forward-paragraph                   evil-motion-state-map)
    (bind-key "{"      #'backward-paragraph                  evil-motion-state-map)
    (bind-key "C-k"    #'kill-line                           evil-insert-state-map)
    (bind-key "C-y"    #'yank                                evil-normal-state-map)
    (bind-key "C-d"    #'evil-scroll-down                    evil-motion-state-map)
    (bind-key "C-d"    #'evil-scroll-down                    evil-normal-state-map)
    (bind-key "C-u"    #'evil-scroll-up                      evil-motion-state-map)
    (bind-key "C-u"    #'evil-scroll-up                      evil-normal-state-map)
    (bind-key "C-w T"  #'my/move-current-window-to-new-frame evil-normal-state-map)
    (bind-key "C-w T"  #'my/move-current-window-to-new-frame evil-motion-state-map)
    (bind-key "<down>" #'evil-next-visual-line               evil-motion-state-map)
    (bind-key "<up>"   #'evil-previous-visual-line           evil-motion-state-map)
    (bind-key ", f"    #'my/rgrep                            evil-normal-state-map)
    (bind-key "]c"     #'git-gutter:next-hunk                evil-normal-state-map)
    (bind-key "[c"     #'git-gutter:previous-hunk            evil-normal-state-map)
    (bind-key ", ."    #'dired-jump                          evil-normal-state-map)
    (bind-key ", m"    #'my/dired-jump-make-new-window       evil-normal-state-map)
    (bind-key "C-n"    #'company-next-page                   evil-insert-state-map)
    (bind-key "C-p"    #'company-previous-page               evil-insert-state-map)
    (bind-key ", x b"  #'my/kill-all-buffers-except-toolkit  evil-normal-state-map)
    (bind-key ", x t"  #'delete-frame                        evil-normal-state-map)
    (bind-key "]e"     #'next-error                          evil-normal-state-map)
    (bind-key "[e"     #'previous-error                      evil-normal-state-map)
    (bind-key ", l"    #'avy-goto-char                       evil-normal-state-map)
    (bind-key ", t"    #'my/google-translate-at-point        evil-visual-state-map)
    (bind-key ", t"    #'my/google-translate-at-point        evil-normal-state-map)

    (add-hook 'with-editor-mode-hook 'evil-insert-state)
    (advice-add 'eval-region :after (lambda (&rest r)
                                      (deactivate-mark)
                                      (when (fboundp 'evil-exit-visual-state)
                                        (evil-exit-visual-state))))

    (add-to-list 'evil-emacs-state-modes 'org-agenda-mode)
    (add-to-list 'evil-emacs-state-modes 'mu4e-view-mode)
    (add-to-list 'evil-emacs-state-modes 'org-toc-mode)
    (add-to-list 'evil-emacs-state-modes 'eww-mode)
    (add-to-list 'evil-emacs-state-modes 'magit-mode)
    (add-to-list 'evil-emacs-state-modes 'mu4e-main-mode)
    (add-to-list 'evil-emacs-state-modes 'mu4e-headers-mode)
    (add-to-list 'evil-emacs-state-modes 'woman-mode)
    (add-to-list 'evil-emacs-state-modes 'help-mode)
    (add-to-list 'evil-emacs-state-modes 'debugger-mode-map)
    (add-to-list 'evil-emacs-state-modes 'ediff-mode-map)
    (add-to-list 'evil-emacs-state-modes 'messages-buffer-mode-map)

    (evil-declare-change-repeat 'company-complete)

    (defvar org-mode-map (make-sparse-keymap))
    (defvar mu4e:view-mode-map (make-sparse-keymap))
    (defvar mu4e-headers-mode-map (make-sparse-keymap))
    (defvar flyspell-mode-map (make-sparse-keymap))
    (defvar help-mode-map (make-sparse-keymap))
    (defvar ediff-mode-map (make-sparse-keymap))

    (evil-define-key '(motion normal) org-mode-map
      (kbd "C-c C-s") #'org-schedule)

    (dolist (element my/text-modes)
      (evil-define-key '(motion normal) element
        (kbd "<down>") #'evil-next-visual-line
        (kbd "<up>")   #'evil-previous-visual-line))

    (bind-key "C-c w t"
      (lambda ()
        (interactive)
        "Move current window to new frame."
        (let ((buffer (current-buffer)))
          (unless (one-window-p)
            (delete-window))
          (display-buffer-pop-up-frame buffer nil)))
      evil-normal-state-map)

    (evil-define-key '(motion emacs normal) mu4e:view-mode-map
      "C-d" #'evil-scroll-down
      "C-u" #'evil-scroll-up)

    (evil-define-key '(motion emacs) mu4e-headers-mode-map
      "C-d" #'evil-scroll-down
      "C-u" #'evil-scroll-up)

    (evil-define-key 'normal flyspell-mode-map
      "[s" 'flyspell-goto-next-error
      "]s" 'flyspell-goto-next-error)

    (evil-define-key '(motion normal) help-mode-map
      "l" 'help-go-back
      "r" 'help-go-forward
      "s-TAB" 'backward-button
      "TAB" 'forward-button)

    (evil-define-key 'normal ediff-mode-map
      "[c" 'ediff-next-difference
      "]c" 'ediff-previous-difference))

  (defalias #'forward-evil-word #'forward-evil-symbol))

(use-package evil-surround
  :config
  (progn
    (global-evil-surround-mode 1)))

(use-package evil-matchit
  :config
  (progn
    (global-evil-matchit-mode 1)))

(use-package evil-visualstar
  :config
  (progn
    (global-evil-visualstar-mode)))

(evil-declare-change-repeat 'company-complete)

(provide 'my-evil)

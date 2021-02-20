;; (setq debug-on-error t)
;; (setq debug-on-error nil)
;; (setq debug-on-quit nil)

(let ((file-name-handler-alist nil))
  (setq
   gc-cons-threshold (* 1024 800)
   gc-cons-percentage 0.1
   read-process-output-max (* 1024 1024 512))
  ;; (setq gc-cons-threshold 402653184)
  ;; (setq gc-cons-percentage 0.6)

  (defun farynaio/debug-on-error-toggle ()
    (interactive)
    (setq debug-on-error (not debug-on-error)))

  (eval-when-compile
    (defvar oauth--token-data ())
    (defvar url-http-method ())
    (defvar url-http-data ())
    (defvar url-http-extra-headers ())
    (defvar url-callback-function ())
    (defvar url-callback-arguments ()))

  ;; (setenv "LC_ALL" "en_US.UTF-8")
  ;; (setenv "LANG" "en_US.UTF-8")
  ;; (setenv "LANGUAGE" "en_US.UTF-8")
  ;; (setenv "LC_COLLATE" "en_US.UTF-8")
  ;; (setenv "LC_CTYPE" "en_US.UTF-8")
  ;; (setenv "LC_MESSAGES" "en_US.UTF-8")
  ;; (setenv "LC_MONETARY" "en_US.UTF-8")
  ;; (setenv "LC_NUMERIC" "en_US.UTF-8")
  ;; (setenv "LC_TIME" "en_US.UTF-8")
  (setenv "SHELL" "/usr/local/bin/bash")
  (setq shell-file-name "/bin/sh")
  ;; (setenv "PATH" (concat "/usr/local/opt/rbenv/shims:/usr/local/opt/rbenv/bin:" (getenv "PATH")))
  ;; (setenv "PATH" (concat "~/.rbenv/shims:" "~/.rbenv/bin:" "/usr/local/bin:" (getenv "PATH")))

  (when (eq system-type 'darwin)
    (setq browse-url-chrome-program "chrome")
    (when (file-accessible-directory-p "/Applications/Firefox.app")
      ;; (setenv "PATH" (concat "~/Applications/Firefox.app/Contents/MacOS:" (getenv "PATH")))
      ;; (add-to-list 'exec-path "/Applications/Firefox.app/Contents/MacOS")
      (setq
       browse-url-generic-program "/Applications/Firefox.app/Contents/MacOS/firefox")))

  (add-to-list 'load-path "~/.emacs.d/lisp/")
  (add-to-list 'load-path "~/.emacs.d/modules/")
  (add-to-list 'load-path "~/.emacs.d/modules/devel")
  ;; (add-to-list 'exec-path "/usr/local/opt/rbenv/shims")
  ;; (add-to-list 'exec-path "/usr/local/opt/rbenv/bin")

  (add-to-list 'exec-path "~/.npm-packages/bin")
  (add-to-list 'exec-path "~/.rbenv/bin")
  (add-to-list 'exec-path "~/.rbenv/shims")
  (add-to-list 'exec-path "/usr/local/bin")

  (setq package-check-signature nil)

  (require 'package)
  (unless (assoc-default "melpa" package-archives)
    (add-to-list 'package-archives '("melpa" . "http://melpa.org/packages/")))
  (unless (assoc-default "elpa" package-archives)
    (add-to-list 'package-archives '("elpa" . "https://orgmode.org/elpa/") t))
  (unless (assoc-default "gnu" package-archives)
    (add-to-list 'package-archives '("gnu" . "http://elpa.gnu.org/packages/")))
  ;; (unless (assoc-default "tromey" package-archives)
  ;;   (add-to-list 'package-archives '("tromey" . "http://tromey.com/elpa/")))
  (package-initialize)

  (unless package-archive-contents
    (package-refresh-contents))

  (setq
   use-package-verbose nil
   use-package-always-ensure t)

  (unless (package-installed-p 'org-plus-contrib)
    (package-install 'org-plus-contrib))

  (unless (package-installed-p 'use-package)
    (package-refresh-contents)
    (package-install 'use-package))

  (setq load-prefer-newer t)

  ;; (use-package bind-key)

  (use-package use-package-ensure-system-package)

  (use-package diminish
    :config
    ;; (diminish 'editorconfig-mode)
    (diminish 'emacs-lock-mode)
    (diminish 'auto-revert-mode)
    (diminish 'eldoc-mode)
    (diminish 'visual-line-mode)
    (diminish 'js-mode "JS")
    (diminish 'reveal-mode)
    (diminish 'lisp-interaction-mode "Lisp-interaction"))

  (require 'gnutls)

  (setq-default auth-source '("~/.authinfo.gpg" "~/.netrc.gpg" "~/.authinfo" "~/.netrc"))

  (setq enable-local-eval t)
  ;; (setq safe-local-eval-forms (list))
  (add-to-list 'safe-local-eval-forms '(progn (jarfar/org-tasks-refile-targets-local)))

  (when (eq system-type 'darwin)
    (add-to-list 'gnutls-trustfiles "/usr/local/etc/openssl/cert.pem"))

  (use-package auto-compile
    :config
    (auto-compile-on-load-mode))

  (use-package dash)

  (when (and (fboundp 'native-comp-available-p)
             (native-comp-available-p))
    (setq
     comp-speed 2
     comp-deferred-compilation t
     package-native-compile t
     comp-async-report-warnings-errors nil)
    ;; Using Emacs.app/Contents/MacOS/bin since it was compiled with
    ;; ./configure --prefix="$PWD/nextstep/Emacs.app/Contents/MacOS"
    (add-to-list 'exec-path (concat invocation-directory "bin") t)
    (setenv "LIBRARY_PATH" (concat (getenv "LIBRARY_PATH")
                                   (when (getenv "LIBRARY_PATH")
                                     ":")
                                   ;; This is where Homebrew puts gcc libraries.
                                   (car (file-expand-wildcards
                                         (expand-file-name "~/homebrew/opt/gcc/lib/gcc/*")))))
    ;; Only set after LIBRARY_PATH can find gcc libraries.

    (native--compile-async '("~/.emacs.d/lisp/" "~/.emacs.d/themes/" "~/.emacs.d/modules/" "~/.emacs.d/local-config.el") t)

    (eval-when-compile
      (require 'use-package))
    )

  ;; This is necessary to fix PATH problems in Mac OS environments for shell-command.
  ;; (use-package exec-path-from-shell
  ;;   :if (memq window-system '(mac ns x))
  ;;   :config
  ;;   (exec-path-from-shell-initialize))

  ;; TODO is it needed?
  ;; (setq exec-path-from-shell-check-startup-files nil)
  (when (memq window-system '(mac ns x))
    (use-package exec-path-from-shell
      :custom
      (exec-path-from-shell-arguments '("-l"))
      :config
      (add-to-list 'exec-path-from-shell-variables "NPM_TOKEN")
      (add-to-list 'exec-path-from-shell-variables "LANG")
      (add-to-list 'exec-path-from-shell-variables "LANGUAGE")
      (add-to-list 'exec-path-from-shell-variables "LC_COLLATE")
      (add-to-list 'exec-path-from-shell-variables "LC_CTYPE")
      (add-to-list 'exec-path-from-shell-variables "LC_MESSAGES")
      (add-to-list 'exec-path-from-shell-variables "LC_MONETARY")
      (add-to-list 'exec-path-from-shell-variables "LC_NUMERIC")
      (add-to-list 'exec-path-from-shell-variables "LC_TIME")
      (exec-path-from-shell-initialize)))

  ;; (use-package oauth2)

  (setq my/text-modes (list 'org-mode-map 'emacs-lisp-mode-map))

  (when (display-graphic-p)
    (setq x-select-request-type '(UTF8_STRING COMPOUND_TEXT TEXT STRING)))

  (run-with-idle-timer (* 60 5) t 'garbage-collect)

  ;; My modules
  (require 'my-path)
  (when (file-exists-p my/local-config-file-path)
    (message (concat "Loading " my/local-config-file-path "..."))
    (load my/local-config-file-path))

  (defvar my-utils-activate nil)
  (defvar my-edit-activate nil)
  (defvar my-writing-activate nil)
  (defvar my-evil-activate nil)
  (defvar my-org-activate nil)
  (defvar my-navigation-activate nil)
  (defvar my-devel-activate nil)
  (defvar my-email-activate nil)
  (defvar my-dired-activate nil)
  (defvar my-notifications-activate nil)
  (defvar my-www-activate nil)
  (defvar my-irc-activate nil)
  (defvar my-theme-activate nil)
  (defvar my-shell-activate nil)
  (defvar my-encrypt-activate nil)
  (defvar my-cleanup-activate nil)
  (defvar my-rss-activate nil)
  (defvar my-org-caldav-activate nil)
  (defvar my-taskjuggler-activate nil)
  (defvar my-git-activate nil)
  (defvar my-python-activate nil)
  (defvar my-php-activate nil)
  (defvar my-js-activate nil)
  (defvar my-ruby-activate nil)
  (defvar my-web-activate nil)
  (defvar my-hydra-activate nil)
  (defvar my-presentation-activate nil)

  (setq
   my-utils-activate t
   my-edit-activate t
   my-git-activate t
   my-evil-activate t
   my-navigation-activate t
   my-org-activate t
   my-writing-activate t
   my-devel-activate t
   my-email-activate t
   my-dired-activate t
   my-notifications-activate t
   my-www-activate t
   my-irc-activate t
   my-theme-activate t
   my-shell-activate t
   my-encrypt-activate t
   my-cleanup-activate t
   my-rss-activate t
   my-org-caldav-activate nil
   my-taskjuggler-activate nil
   my-python-activate t
   my-php-activate t
   my-js-activate t
   my-web-activate t
   my-ruby-activate nil
   my-hydra-activate t
   my-presentation-activate nil
   )

  (when my-utils-activate (require 'my-utils))
  (when my-evil-activate (require 'my-evil))
  (when my-edit-activate (require 'my-edit))
  (when my-encrypt-activate (require 'my-encrypt))
  (when my-navigation-activate (require 'my-navigation))
  (when my-theme-activate (require 'my-theme))
  (when my-git-activate (require 'my-git))
  (when my-hydra-activate (require 'my-hydra))
  (when my-org-activate (require 'my-org))
  (when my-writing-activate (require 'my-writing))
  (when my-dired-activate (require 'my-dired))
  (when my-cleanup-activate (require 'my-cleanup))
  (when my-notifications-activate (require 'my-notifications))
  (when my-devel-activate (require 'my-devel))
  (when my-python-activate (require 'my-python))
  (when my-web-activate (require 'my-web))
  (when my-js-activate (require 'my-js))
  (when my-php-activate (require 'my-php))
  (when my-ruby-activate (require 'my-ruby))
  (when my-shell-activate (require 'my-shell))
  (when my-rss-activate (require 'my-rss))
  (when my-email-activate (require 'my-email))
  (when my-www-activate (require 'my-www))
  (when my-presentation-activate (require 'my-presentation))
  (when my-irc-activate (require 'my-irc))
  (when my-taskjuggler-activate (require 'my-taskjuggler))
  (when my-org-caldav-activate (require 'my-org-caldav))

  (server-start)

  (add-hook 'emacs-startup-hook 'jarfar/open-buffers-on-startup)

  (defun jarfar/open-buffers-on-startup ()
    (if (file-exists-p my/notes-file-path)
        (find-file my/notes-file-path)
      (switch-to-buffer "*scratch*")))

  (when (eq system-type 'darwin)
    (setq
     mac-command-modifier 'super
     ns-right-alternate-modifier nil))

  (when (fboundp 'set-charset-priority)
    (set-charset-priority 'unicode))

  (set-default-coding-systems 'utf-8)

  (setq-default
   ring-bell-function 'ignore
   visible-bell nil
   echo-keystrokes 0
   create-lockfiles nil ; this should be safe as long I'm the only user of FS
   enable-recursive-minibuffers nil ;; ?
   apropos-do-all t
   compilation-always-kill t
   compilation-ask-about-save nil
   compilation-scroll-output t
   confirm-nonexistent-file-or-buffer nil
   idle-update-delay 2
   minibuffer-prompt-properties '(read-only t point-entered minibuffer-avoid-prompt face minibuffer-prompt)
   initial-scratch-message nil
   inhibit-startup-screen t
   x-underline-at-descent-line t
   confirm-kill-processes nil
   process-connection-type nil
   fill-column 99
   default-directory "~/"
   initial-buffer-choice t
   confirm-kill-processes nil
   password-cache-expiry nil)

  (setq-default
   make-backup-files nil
   backup-by-copying t
   kept-new-versions 5
   kept-old-versions 5
   delete-old-versions t
   version-control t
   auto-save-file-name-transforms '((".*" "~/.emacs.d/autosaves/" t))
   backup-directory-alist '(("." . "~/.emacs.d/backups")))

  (defun reload-config ()
	  "Reload config."
	  (interactive)
	  (load-file (expand-file-name "init.el" user-emacs-directory))
    (message "Config reloaded."))

  (display-time-mode -1)

  (defvar *protected-buffers* '("*scratch*" "*Messages*" "*dashboard*" "notes.org")
    "Buffers that cannot be killed.")

  (defun my/protected-buffers ()
    "Protects some buffers from being killed."
    (dolist (buffer *protected-buffers*)
      (with-current-buffer buffer
        (emacs-lock-mode 'kill))))

  (add-hook 'emacs-startup-hook 'my/protected-buffers 90)

  (setq safe-local-variable-values
        '(
          (org-hide-emphasis-markers . t)
          (ispell-dictionary . "en")
          (ispell-dictionary . "pl")
          (my/language-local . "pl")
          (my/language-local . "en")
          (org-use-property-inheritance . t)
          (org-confirm-babel-evaluate)
          (eval progn
                (add-hook
                 (quote js-mode-hook)
                 (lambda nil
                   (flycheck-mode -1))
                 t ))))
  )

(find-file "~/.emacs.d/init.el")
(find-file "~/.emacs.d/modules/my-hydra.el")

(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(bmkp-last-as-first-bookmark-file "~/.emacs.d/bookmarks")
 '(custom-enabled-themes '(wombat))
  '(ledger-reports
     (quote
       (("Household expenses period" "ledger [[ledger-mode-flags]] -b 2018/09/14 -e 2018/10/13 -f /Users/devil/Dropbox/emacs/ledger/private.ledger reg \"^Assets:Reimbursements:Household\"")
         (#("Net value balance" 0 1
             (idx 0))
           "%(binary) [[ledger-mode-flags]] -f %(ledger-file) bal Assets Liabilities")
         (#("Net value balance (cleared)" 0 1
             (idx 1))
           "%(binary) [[ledger-mode-flags]] -f %(ledger-file) --cleared bal Assets Liabilities")
         (#("Net value balance (uncleared)" 0 1
             (idx 2))
           "%(binary) [[ledger-mode-flags]] -f %(ledger-file) --uncleared bal Assets Liabilities")
         (#("bal" 0 1
             (idx 3))
           "%(binary) -f %(ledger-file) bal")
         (#("reg" 0 1
             (idx 4))
           "%(binary) -f %(ledger-file) reg")
         (#("payee" 0 1
             (idx 5))
           "%(binary) -f %(ledger-file) reg @%(payee)")
         (#("account" 0 1
             (idx 6))
           "%(binary) -f %(ledger-file) reg %(account)"))))
  '(package-selected-packages
     (quote
       (yaml-mode which-key web-mode web-beautify vue-mode vimrc-mode use-package undo-fu typescript-mode terraform-mode smartscan rjsx-mode request realgud rainbow-mode rainbow-delimiters projectile-rails prettier-js popup php-mode pfuture persistent-scratch org-roam-server org-review org-plus-contrib org-journal org-drill ob-async oauth2 magit ledger-mode langtool json-mode japanese-holidays jade-mode ivy-rich ivy-hydra hl-todo goto-last-change google-translate git-gutter geben flycheck evil-visualstar evil-surround evil-matchit evil-anzu eslintd-fix emojify emmet-mode elpy elfeed-web elfeed-org elfeed-goodies editorconfig dtrt-indent drag-stuff dockerfile-mode diminish dap-mode counsel company-php company-org-roam calfw-org calfw auto-highlight-symbol auto-compile auctex artbollocks-mode all-the-icons ag add-node-modules-path))))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(cursor ((t (:inherit nil :background "gray82" :underline nil))))
 '(hl-line ((t (:background "gray32"))))
 '(org-priority ((t (:inherit font-lock-keyword-face :foreground "gold3"))))
 '(region ((t (:background "DodgerBlue4" :foreground "#f6f3e8")))))
(put 'dired-find-alternate-file 'disabled nil)

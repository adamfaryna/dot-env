;; (setq debug-on-error t)
;; (setq debug-on-error nil)

(setenv "SHELL" "/usr/local/bin/bash")
(setq shell-file-name "/bin/sh")

(require 'package)
(add-to-list 'package-archives '("melpa" . "https://melpa.org/packages/"))

(package-initialize)

(unless package-archive-contents
  (package-refresh-contents))

(setq
 use-package-verbose nil
 use-package-always-ensure t)

(unless (package-installed-p 'use-package)
  (package-refresh-contents)
  (package-install 'use-package))

(require 'use-package)

(setq load-prefer-newer t)

(unless (package-installed-p 'org-plus-contrib)
  (package-install 'org-plus-contrib))
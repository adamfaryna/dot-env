;; (require 'text-mode)
(require 'smart-quotes)
(require 'cl)

;; (if (executable-find "hunspell")
;;     (progn
;;       (setenv "DICPATH" (concat (getenv "HOME") "/Documents/Dropbox/devel/spelling"))
;;       (setq ispell-program-name (executable-find "hunspell")))
;;   (message "'hunspell' not installed!"))


(setq skk-large-jisyo "~/.emacs.d/dict/SKK-JISYO.L") ;; is this needed?

(define-minor-mode my/en-mode
  "Language mode for 'en'."
  :init-value nil
  :lighter " en"
  (setq-local
    ispell-local-dictionary "en"
    local-abbrev-table my/en-abbrevs
    langtool-default-language "en"))

(define-minor-mode my/pl-mode
  "Language mode for 'pl'."
  :init-value nil
  :lighter " pl"
  (setq-local
    ispell-local-dictionary "pl"
    local-abbrev-table my/pl-abbrevs
    langtool-default-language "pl"))

(use-package abbrev
  :ensure nil
  :diminish "Abb"
  :hook ((text-mode . abbrev-mode))
  :custom
  (save-abbrevs 'silently)
  (abbrev-file-name (expand-file-name "abbrev_defs" user-emacs-directory)))

(add-hook 'org-mode-hook 'my/en-mode)
(add-hook 'org-roam-dailies-find-file-hook 'my/en-mode)

(use-package ispell
  :defer 2
  :custom
  (ispell-local-dictionary "en_US")
  (ispell-local-dictionary-alist
    '(("en_US" "[[:alpha:]]" "[^[:alpha:]]" "[']" nil ("-d" "en_US") nil utf-8)
       ("fr_FR" "[[:alpha:]]" "[^[:alpha:]]" "[']" nil ("-d" "fr_FR") nil utf-8)))
  (ispell-dictionary "en_US")
  (ispell-dictionary-alist
    '(("en_US" "[[:alpha:]]" "[^[:alpha:]]" "[']" nil ("-d" "en_US") nil utf-8)
       ("fr_FR" "[[:alpha:]]" "[^[:alpha:]]" "[']" nil ("-d" "fr_FR") nil utf-8)))
  ;; (ispell-program-name (executable-find "hunspell"))
  (ispell-really-hunspell t)
  (ispell-silently-savep t)
  (ispell-extra-args '("--sug-mode=ultra"))
  :preface
  (setq my/lang-modes '((en . my/en-mode) (pl . my/pl-mode)))
  (defun my/lang-modes-deactivate ()
    "Deactivate all lang modes."
    (interactive)
    (my/en-mode -1)
    (my/pl-mode -1))

  (defun my/lang-toggle ()
    "Toggle language modes."
    (interactive)
    (unless (derived-mode-p 'prog-mode)
      (let ((new-mode (symbol-function
                        (cond
                          ((bound-and-true-p my/pl-mode) 'my/en-mode)
                          ((bound-and-true-p my/en-mode) 'my/pl-mode)
                          ((bound-and-true-p my/language-local) (cdr (assoc my/language-local my/lang-modes)))
                          (t 'my/en-mode))
                        )))
        (my/lang-modes-deactivate)
        (funcall new-mode 1)))))

(use-package flyspell
  :commands flyspell-mode
  :diminish "Fly"
  :custom
  (flyspell-issue-message-flag nil)
  (flyspell-issue-welcome-flag nil)
  :config
  (flyspell-prog-mode)
  (evil-define-key 'normal flyspell-mode-map
    ;; (kbd "[s") 'flyspell-goto-next-error
    ;; (kbd "]s") 'flyspell-goto-next-error
    (kbd "[l") #'langtool-goto-previous-error
    (kbd "]l") #'langtool-goto-next-error)

  (add-to-list 'ispell-skip-region-alist '(":PROPERTIES:" ":END:"))
  (add-to-list 'ispell-skip-region-alist '("#\\+BEGIN_SRC" . "#\\+END_SRC"))
  (add-to-list 'ispell-skip-region-alist '("#\\+BEGIN_EXAMPLE" . "#\\+END_EXAMPLE")))

(defvar my/en-abbrevs nil)
(define-abbrev-table
  'my/en-abbrevs '(
                    ("im" "I'm" nil 0)
                    ("ami" "am I" nil 0)
                    ("dont" "don't" nil 0)
                    ("cant" "can't" nil 0)
                    ("aint" "ain't" nil 0)
                    ("isnt" "isn't" nil 0)
                    ("wont" "won't" nil 0)
                    ("couldnt" "couldn't" nil 0)
                    ("Youre" "You're" nil 0)
                    ("youre" "you're" nil 0)
                    ("Youd" "You'd" nil 0)
                    ("youd" "you'd" nil 0)
                    ("arent" "aren't" nil 0)
                    ("mustnt" "mustn't" nil 0)
                    ("shouldnt" "shouldn't" nil 0)
                    ("wouldnt" "wouldn't" nil 0)
                    ("wasnt" "wasn't" nil 0)
                    ("havent" "haven't" nil 0)
                    ("totaly" "totally" nil 0)
                    ("whos" "who's" nil 0)
                    ("everobodys" "everybody's" nil 0)
                    ("doesnt" "doesn't" nil 0)
                    ("didnt" "didn't" nil 0)
                    ("thats" "that's" nil 0)
                    ("chinese" "Chinese" nil 0)
                    ("whats" "what's" nil 0)
                    ("Whats" "What's" nil 0)
                    ("theyre" "they're" nil 0)
                    ("hows" "how's" nil 0)
                    ("Ill" "I'll" nil 0)
                    ("youve" "you've" nil 0)
                    ("youll" "you'll" nil 0)
                    ("theres" "there's" nil 0)
                    ("Weve" "We've" nil 0)
                    ("elses" "else's" nil 0)
                    ))

(defvar my/pl-abbrevs nil)
(define-abbrev-table 'my/pl-abbrevs '())

;; TODO is this working?
(use-package wiki-summary
  :defer 1
  :config
  (defun my/format-summary-in-buffer (summary)
    "Given a summary, sticks it in the *wiki-summary* buffer and displays
     the buffer."
    (let ((buf (generate-new-buffer "*wiki-summary*")))
      (with-current-buffer buf
        (princ summary buf)
        (fill-paragraph)
        (goto-char (point-min))
        (view-mode))
      (pop-to-buffer buf)))

  (advice-add 'wiki-summary/format-summary-in-buffer :override #'my/format-summary-in-buffer))

(use-package langtool
  :commands langtool-check-buffer langtool-check-done
  :init
  (setq langtool-language-tool-jar (expand-file-name "LanguageTool/languagetool-commandline.jar" my/tools-path))
  :custom
  (langtool-default-language "en")
  (langtool-mother-tongue "en")
  (langtool-disabled-rules '("COMMA_PARENTHESIS_WHITESPACE"
                              "COPYRIGHT"
                              "DASH_RULE"
                              "EN_QUOTES"
                              "EN_UNPAIRED_BRACKETS"
                              "UPPERCASE_SENTENCE_START"
                              "WHITESPACE_RULE")))

(use-package google-translate
  :custom
  (google-translate-default-source-language "en")
  (google-translate-default-target-language "pl")
  (google-translate-backend-method 'curl)
  :config
  (defun google-translate--search-tkk () "Search TKK." (list 430675 2721866130))

  (defun my/google-translate-at-point (&optional override-p)
    (interactive "P")
    (save-excursion
      (google-translate-at-point override-p))
    (deactivate-mark)
    (when (fboundp 'evil-exit-visual-state)
      (evil-exit-visual-state))))

(use-package artbollocks-mode
  :commands artbollocks-mode
  :custom
  (artbollocks-weasel-words-regex
    (concat "\\b" (regexp-opt
                    '("one of the" "should" "just" "sort of" "a lot" "probably" "maybe" "perhaps" "I think" "really" "pretty" "nice" "action" "utilize" "leverage"
                                        ; test
                       "clavicles" "collarbones" "tiny birds" "antlers" "thrumming" "pulsing" "wombs" "ribcage" "alabaster" "grandmother" "redacting fairytales" "retelling fairytales" "my sorrow" "the window speaking" "avocados" "the blank page" "marrow" "starlings" "giving birth" "giving birth to weird shit" "apples" "peeling back skin" "god" "the mountain trembling" "poetry is my remedy" "sharp fragments" "shards" "grandpa" "i can remember" "this is how it happened" "the pain" "greek myths" "poems about poems" "scars" "cold, stinging" "oranges" "the body" "struggles" "shadows" "the moon reflecting off the" "waves" "echoes in the night" "painted skies" "a hundred" "again and again" "peace, love" "whimsy" "brooklyn" "the summer solstice" "the lunar eclipse" "veins" "soul"
                       ) t) "\\b")
    artbollocks-jargon nil))

(provide 'my-writing)

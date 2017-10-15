;;; my-force-cli.el ---

(setq my-force-cli-path (executable-find "force"))
(setq my-force-cli-buffer "*my-force-cli*")
(setq my-force-cli-username nil)
(setq my-force-cli-password nil)

(defun my-force-cli-set-username(u)(setq my-force-cli-username u))
(defun my-force-cli-set-username-interactive()(interactive)(my-force-cli-set-username (read-string "User name:")))
(defun my-force-cli-get-username()(interactive)(if my-force-cli-username my-force-cli-username (my-force-cli-set-username-interactive)) )

(defun my-force-cli-set-password(u)(setq my-force-cli-password u))
(defun my-force-cli-set-password-interactive()(interactive)(my-force-cli-set-password (read-passwd "Password:")))
(defun my-force-cli-get-password()(interactive)(if my-force-cli-password my-force-cli-password (my-force-cli-set-password-interactive)) )


(defun my-force-run (run-cmd) (cond ((not my-force-cli-path) (message "Could not run. Force.com CLI Not found on the PATH"))
				    ((not my-force-cli-username) my-force-cli-set-username-interactive)
				    ((not my-force-cli-password) my-force-cli-set-password-interactive)
				    (t run-cmd)
				    ))

(defun my-force-define-shell-command (func command outbuf)
  (lexical-let ((func func) (command command) (outbuf outbuf))
    (defalias func (lambda () (interactive) (my-force-run (async-shell-command command outbuf))))))

(defun my-force-define-shell-command-with-region (func command outbuf)
  (lexical-let ((func func) (command command) (outbuf outbuf))
    (defalias func (lambda () (interactive) (when (region-active-p) (shell-command-on-region (region-beginning) (region-end) command outbuf))))))

(defun my-force-define-shell-command-with-region-param (func command outbuf)
  (lexical-let ((func func) (command command) (outbuf outbuf))
    (defalias func (lambda () (interactive) (async-shell-command (format "%s %s" command (buffer-substring (region-beginning)(region-end)) outbuf))))))

(defun my-force-login()(interactive)(async-shell-command (format "force login -u %s -p %s" (my-force-cli-get-username) (my-force-cli-get-password))))


(my-force-define-shell-command 'force-whoami "force whoami" my-force-cli-buffer)
(my-force-define-shell-command-with-region 'force-apex "force apex" my-force-cli-buffer)
(my-force-define-shell-command-with-region-param 'force-query "force query" my-force-cli-buffer)

(defun my-force-push ()
  (interactive)
  (let ((files (dired-get-marked-files t current-prefix-arg)))
    (dired-do-async-shell-command "force push -f *" nil files)))


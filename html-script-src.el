;;; html-script-src.el --- Insert <script src=".."> for popular JavaScript libraries

;; Copyright (C) 2010 Johan Andersson

;; Author: Johan Andersson <johan.rejeep@gmail.com>
;; Maintainer: Johan Andersson <johan.rejeep@gmail.com>
;; Version: 0.0.1
;; Keywords: tools, convenience
;; URL: http://github.com/rejeep/html-script-src

;; This file is NOT part of GNU Emacs.

;;; License:

;; This program is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation; either version 3, or (at your option)
;; any later version.

;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with GNU Emacs; see the file COPYING.  If not, write to the
;; Free Software Foundation, Inc., 51 Franklin Street, Fifth Floor,
;; Boston, MA 02110-1301, USA.

;;; Commentary:

;; Inserts a script tag for HTML and HAML documents with a URL to a
;; given JavaScript framework taken from: http://scriptsrc.net/

;; To use this, make sure that this file is in Emacs load-path
;; (add-to-list 'load-path "/path/to/directory/or/file")
;;
;; Then require it
;; (require 'html-script-src)
;;
;; Then in your HTML or HAML file, run the function `html-script-src'.


;;; Code:


(defvar html-script-src-completion-fn
  (if (fboundp 'ido-mode) 'ido-completing-read 'completing-read)
  "Function to use for framework completion.")

(defconst html-script-src-re
  "<textarea id=\"fe_text_\\(.+\\)\".*class=\"fetext\".*>\\(.+\\)</textarea>"
  "Regular expression matching a JavaScript framework in the HTML source.")

(defconst html-script-src-scriptsrc-url "http://scriptsrc.net/"
  "URL to Script Src website.")

(defconst html-script-src-haml-script-format
  "%%script{ :src => '%s', :type => 'text/javascript', :charset => 'utf-8' }"
  "Format string for haml script tag.")

(defconst html-script-src-html-script-format
  "<script src='%s' type='text/javascript' charset='utf-8'></script>"
  "Format string for html script tag.")


(defun html-script-src ()
  "Inserts script tag for desired JavaScript framework."
  (interactive)
  (let* ((frameworks (html-script-src-frameworks))
         (framework (funcall html-script-src-completion-fn "Framework: " (mapcar (lambda (x) (car x)) frameworks) nil t)))
    (html-script-src-insert-tag (cdr (assoc framework frameworks)))))

(defun html-script-src-frameworks ()
  "Returns a list of all JavaScript names and URL."
  (let ((buffer (html-script-src-fetch)))
    (with-current-buffer buffer
      (html-script-src-parse))))

(defun html-script-src-parse ()
  "Parses the Script Src website and returns all JavaScript frameworks as a list."
  (goto-char (point-min))
  (let ((frameworks))
    (while (re-search-forward "<textarea id=\"fe_text_\\(.+\\)\".*class=\"fetext\".*>\\(.+\\)</textarea>" nil t)
      (add-to-list 'frameworks
                   (cons
                    (match-string-no-properties 1)
                    (match-string-no-properties 2))))
    frameworks))

(defun html-script-src-fetch ()
  "Fetches the HTML for the Script Src website."
  (let ((url-request-method "GET")
        (url-request-extra-headers nil)
        (url-mime-accept-string "*/*")
        (url (url-generic-parse-url html-script-src-scriptsrc-url)))
    (url-retrieve-synchronously url)))

(defun html-script-src-insert-tag (url)
  "Inserts a tag for URL."
  (let ((format
         (if (eq major-mode 'haml-mode)
             (html-script-src-insert-haml-format)
           (html-script-src-insert-html-format))))
    (insert (format format url))))


(provide 'html-script-src)

;;; html-script-src.el ends here

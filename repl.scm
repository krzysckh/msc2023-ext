;;--- repl.scm - scheme repl

(define repl:ident 'REPL)
(define repl:prompt "> ")
(define repl:font-size 18)
(define repl:prompt-w (car (measure-text repl:prompt repl:font-size)))

(define (repl-start)
  (when (null? *current-mode*)
    (set! *current-mode* 'repl)
    (set! *click-can-be-handled* #f)
    (set! *keypress-can-be-handled* #f)
    (set! *current-keypress-handler* repl:ident)
    (set! *current-click-handler*    repl:ident)
    (set! *mode-display-on* #f)

    (define history nil)
    (define state "")
    (define cursor 0)

    (define (repl-eval)
      (let* ((ret (eval (read (open-input-string state)))))
        (set! history (append history (list (string-append repl:prompt state) (->string ret))))
        (set! state "")
        (set! cursor 0)))

    (let* ((frame-handler
            (add-hook
             'frame
             (lambda ()
               ;; "inputbar"
               (gui/draw-text repl:prompt `(0 . ,(- *SCREEN-HEIGHT* repl:font-size)) repl:font-size (aq 'green *colorscheme*))
               (gui/multiline-text (list repl:prompt-w (- *SCREEN-HEIGHT* repl:font-size)
                                         *SCREEN-WIDTH* repl:font-size)
                                   state
                                   cursor)
               (let ((y-start (- *SCREEN-HEIGHT* repl:font-size (* repl:font-size (length history))))
                     (c (aq 'green *colorscheme*))
                     (pad 1))
                 (for-each
                  (→1 (let ((y (+ y-start (* x repl:font-size) pad)))
                        (draw-text (list-ref history x) `(0 . ,y) repl:font-size c)))
                  (⍳ 0 1 (length history)))))))
           (kp-handler
            (add-hook
             'keypress
             (lambda (c k) ;; zkopiowane z gui/input-popup
               (cond
                ((and (< k 128) (> k 31))
                 (let ((prev (substring state 0 cursor))
                       (rest (substring state cursor (+ cursor (- (string-length state) cursor)))))
                   (set! state (string-append prev (string c) rest)))
                 (++ cursor))
                ((eqv? k 256)
                 (repl-end))
                ((eqv? k 259)
                 (let ((prev (substring state 0 (- cursor 1)))
                       (rest (substring state cursor (+ cursor (- (string-length state) cursor)))))
                   (set! state (string-append prev rest)))
                 (-- cursor))
                ((eqv? k 257) ;; RET
                 (repl-eval))
                ((eqv? k 263) ; ←
                 (set! cursor (max (- cursor 1) 0)))
                ((eqv? k 262) ; →
                 (set! cursor (min (+ cursor 1) (string-length state))))))))
           (repl-end
            (→ (set! *current-mode* nil)
               (set! *click-can-be-handled* #t)
               (set! *keypress-can-be-handled* #t)
               (set! *current-keypress-handler* nil)
               (set! *current-click-handler* nil)
               (set! *mode-display-on* #t)
               (delete-hook 'keypress kp-handler)
               (delete-hook 'frame frame-handler)))))))

;; aliasy
(define repl repl-start)
(define repl-mode repl-start)

(set! advanced-menu (append advanced-menu (list `("uruchom REPL" . ,(→ (repl))))))

(define π 3.14159)
(define sin-min 0)
(define sin-max (* 4 π))
(define sin-step 0.1)

(set!
 create-source-at-mouse-position
 (→ (create-source `((pos . ,(get-mouse-position)) (reactive . #t)))))

(define (pairs l)
  (cond
   ((null? l) '())
   ((eqv? (length l) 1) '())
   (else
    (append (list (list (car l) (cadr l)))
            (pairs (cdr l))))))

(define sin-pts
  (map
   (→1 (cons (* (/ x sin-max) *SCREEN-WIDTH*)
             (* (/ (+ 1 (sin x)) 2) *SCREEN-HEIGHT*)))
   (iota sin-min sin-step sin-max)))

(for-each
 (→1 (add-mirror (car x) (cadr x)))
 (pairs sin-pts))

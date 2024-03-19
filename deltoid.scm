(define p1 '(100 . 100))
(define p2 '(150 . 150))
(define p3 '(100 . 400))
(define p4 '(50  . 150))
(define punkty-deltoidu (list p1 p2 p3 p4))

;; L[1-4] to linie w deltoidzie

(define L1 (list p1 p2))
(define L2 (list p2 p3))
(define L3 (list p3 p4))
(define L4 (list p4 p1))

;;      p1
;;      .
;; L4  / \   L1
;; p4 .   .  p2
;;    \   /
;; L3  \ /   L2
;;      v
;;     p3

;; punkty-deltoidu to wielokąt (poly w customb_data_t), czyli lista punktów.
;; jeśli znajdzie się w niej wiązka światła, program wykona funkcję, która obliczyć ma jak światło powinno się odbić.
;; w tym przypadku będzie to funkcja bounce-fn. dostaje ona jako dane punkt w którym wiązka światła dotknęła wielokątu,
;; oraz kąt względem osi OX
(define (bounce-fn hit-point angle)
  (let* ((hit-line
          (cond
           ((point-in-line? hit-point (car L1) (cadr L1) 2) L1) ;; na początek sprawdzamy o jaką linię deltoidu
           ((point-in-line? hit-point (car L2) (cadr L2) 2) L2) ;; wiązka światła faktycznie się odbiła i zapisujemy ją
           ((point-in-line? hit-point (car L3) (cadr L3) 2) L3) ;; jako hit-line
           ((point-in-line? hit-point (car L4) (cadr L4) 2) L4)
           (else
            (error "not in-line"))))
         (hit-angle (normalize-angle (angle-between (car hit-line) (cadr hit-line)))) ;; kąt pod jakim jest linia deltoidu
         (rel-angle (- hit-angle angle))                                              ;; kąt pod jakim światło padło na deltoid
         (next-angle (normalize-angle (+ hit-angle rel-angle))))                      ;; kąt jaki teraz ma obrać światło
    (list hit-point next-angle)))
;;        ^^^^^^^^^ ^^^^^^^^^^
;;        \____               \_____
;;             \                    \
;; zwrócić mamy to samo co dostaliśmy, t.j. punkt od którego ma wiązka kontynuować, oraz kąt (względem osi OX)

;; musimy oczywiście też zdefiniować funkcję, która pokaże gdzie ten deltoid jest (t.j. narysuje go)
;; funkcja ta będzie wywoływana za każdym razem gdy klatka ma być narysowana (często) więc powinna być jak najkrótsza.
(define kolor-deltoidu lime-green) ; via scm/colors.scm
(define (draw-fn)
  (draw-line p1 p2 1 kolor-deltoidu)
  (draw-line p2 p3 1 kolor-deltoidu)
  (draw-line p3 p4 1 kolor-deltoidu)
  (draw-line p4 p1 1 kolor-deltoidu))

;; na koniec musimy "zarejestrować" deltoid, t.j. przekazać wszystkie informacje o nim programowi
(register-custom
 punkty-deltoidu
 draw-fn
 bounce-fn)

;; początek i koniec portalu mają takie same wymiary i są równoległe do osi OY,
;; żeby można było łatwo policzyć gdzie światło ma sie znaleźć
(define portal-start '((500 . 500) (500 . 700)))
(define portal-end   '((400 . 100) (400 . 200)))

;; portal początkowy rysowany jest kolorem zielonym, a końcowy czerwonym
(define (draw-fn)
  (draw-line (car portal-start) (cadr portal-start) 1 green)
  (draw-line (car portal-end) (cadr portal-end) 1 red))

(define (light-remap-fn hit-point angle)
  (let* ((hit-y (cdr hit-point))
         (diff-y (- hit-y (cdr (car portal-start)))) ;; różnica między początkiem (górą) portalu, a miejscem, gdzie wiązka go dotknęła
         (end-y (+ (cdr (car portal-end)) diff-y)))  ;; finalne y, w którym pojawić ma się wiązka
    (list (cons (caar portal-end) end-y) angle)))
;;              ^^^^^^^^^^^^^^^^  ^^^^^
;;        x portalu końcowego i (y portalu końcowego + diff-y)

(register-custom
 portal-start
 draw-fn
 light-remap-fn)

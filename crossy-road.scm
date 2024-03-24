(define PLAYER-SIZE 32)
(define PLAYER-COLOR (aq 'selected *colorscheme*))
(define PLAYER-PADDING 4)

(define PLANK-PADDING 2)
(define MAX-PLANK-WIDTH 256)
(define MIN-PLANK-WIDTH 32)
(define MAX-PLANK-SPEED 6)
(define MIN-PLANK-SPEED 3)

(define (rand from to)
  (floor (+ (* (rand-float) (- to from -1)) from)))

(define player-∆ nil)
(define current-plank nil)

(define pos `(,(- (/ *SCREEN-WIDTH* 2) (/ PLAYER-SIZE 2)) . 0))
(define planks
  (map
   (→1 (cons 0 x))
   (iota PLAYER-SIZE PLAYER-SIZE (- *SCREEN-HEIGHT* PLAYER-SIZE))))
;; (set! planks (list (car planks)))

(define plank-widths (map (→1 (rand MIN-PLANK-WIDTH MAX-PLANK-WIDTH)) planks))
(define plank-speeds (map (→1 (rand MIN-PLANK-SPEED MAX-PLANK-SPEED)) planks))

(define (restart)
  (set! pos `(,(- (/ *SCREEN-WIDTH* 2) (/ PLAYER-SIZE 2)) . 0)))

;; draw stuff
(add-hook
 'frame
 (→ (for-each
     (→1 (let ((plank (list-ref planks x))
               (width (list-ref plank-widths x)))
           (fill-rect (list (car plank) (+ (cdr plank) PLANK-PADDING)
                            width (- PLAYER-SIZE PLANK-PADDING)) brown)))
     (iota 0 1 (length planks)))

    ;; draw "modulo" of the scene
    (let ((player-rest (- *SCREEN-WIDTH* (car pos)))
          (plank-rests (map (→1 (- *SCREEN-WIDTH* (car x)))
                            (map (→1 (let ((P (list-ref planks x))
                                           (W (list-ref plank-widths x)))
                                       (cons (+ (car P) W) (cdr P))))
                                 (iota 0 1 (length planks))))))
      (for-each
       (→1 (let ((rest (list-ref plank-rests x)))
             (when (< rest 0)
               (fill-rect (list 0 (+ PLANK-PADDING (cdr (list-ref planks x)))
                                (abs rest) (- PLAYER-SIZE PLANK-PADDING))
                          BROWN))))
       (iota 0 1 (length plank-rests)))
      (when (< player-rest 0)
        (fill-rect (list PLAYER-PADDING (+ PLAYER-PADDING (cdr pos))
                         (- (abs player-rest) PLAYER-PADDING PLAYER-PADDING)
                         (- PLAYER-SIZE PLAYER-PADDING PLAYER-PADDING)) PLAYER-COLOR)))

    ;; draw player at the end
    (fill-rect (list (+ PLAYER-PADDING (car pos))
                     (+ PLAYER-PADDING (cdr pos))
                     (- PLAYER-SIZE PLAYER-PADDING PLAYER-PADDING)
                     (- PLAYER-SIZE PLAYER-PADDING PLAYER-PADDING)) PLAYER-COLOR)))

;; actually mod stuff
(add-hook
 'frame
 (→ (set! planks (map (→1 (if (> (car x) *SCREEN-WIDTH*) (cons 0 (cdr x)) x)) planks))))

;; update plank pos + update player pos
(add-hook
 'frame
 (→ (set! planks (map (→1 (let ((plank (list-ref planks x))
                                (speed (list-ref plank-speeds x)))
                            (cons (+ (car plank) speed) (cdr plank))))
                      (iota 0 1 (length planks))))
    (when (not (null? current-plank))
      (let ((plank (list-ref planks current-plank)))
        (set! pos (cons (+ player-∆ (car plank)) (cdr plank)))))

    ;; kill player when not on plank and not on top nor bottom
    (when (null? current-plank)
      (when (not (rect-collision? (list (car pos) (cdr pos) PLAYER-SIZE PLAYER-SIZE)
                                  (list 0 PLAYER-SIZE *SCREEN-WIDTH* (- PLAYER-SIZE *SCREEN-HEIGHT*))))
        (restart)))))

(define (check-if-on-plank)
  (set! current-plank nil)
  (for-each
   (→1 (let ((plank (list-ref planks x))
             (width (list-ref plank-widths x)))
         (when (rect-collision? (list (car plank) (cdr plank) width PLAYER-SIZE)
                                (list (car pos) (cdr pos) PLAYER-SIZE PLAYER-SIZE))
           (set! player-∆ (- (car pos) (car plank)))
           (set! current-plank x))))
   (iota 0 1 (length planks))))

(add-hook
 'keypress
 (→2 (cond
      ((or (eqv? x #\w) (eqv? x #\k))
       (set! pos (cons (car pos) (- (cdr pos) PLAYER-SIZE)))
       (check-if-on-plank))
      ((or (eqv? x #\s) (eqv? x #\j))
       (set! pos (cons (car pos) (+ (cdr pos) PLAYER-SIZE)))
       (check-if-on-plank)))))

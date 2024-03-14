;;--- themes.scm - obsługa dodatkowych kolorytów w msc2023

(define colorschemes
  `((everforest
     . ((drawing-new-mirror . (#xd6 #x99 #xb6 #xff))
        (font               . (#xd3 #xc6 #xaa #xff))
        (frame              . (#xdb #xbc #x7f #xff))
        (default-light      . (#xd6 #x99 #xb6 #xff))
        (background         . (#x2b #x33 #x39 #xff))
        (selection          . (#x9d #xa9 #xa0 #xff))
        (selected           . (#xe6 #x98 #x75 #xff))
        (red                . (#xe6 #x7e #x80 #xff))
        (green              . (#xa7 #xc0 #x80 #xff))))
    (gruber-darker
     . ((drawing-new-mirror . (#xff #xdd #x33 #xff))
        (font               . (#xe4 #xe4 #xef #xff))
        (frame              . (#xff #xff #xff #xff))
        (default-light      . (#xff #xff #xff #xff))
        (background         . (#x18 #x18 #x18 #xff))
        (selection          . (#xcc #x8c #x3c #xff))
        (selected           . (#x96 #xa6 #xc8 #xff))
        (red                . (#xf4 #x38 #x41 #xff))
        (green              . (#x73 #xc9 #x36 #xff))))
    (dracula
     . ((drawing-new-mirror . (241 250 140))
        (font               . (248 248 242))
        (frame              . (98 114 164))
        (default-light      . (255 255 255))
        (background         . (40 42 54))
        (selection          . (68 71 90))
        (selected           . (98 114 164))
        (red                . (255 85 85))
        (green              . (80 250 123))))))

(define (set-bg! c)
  (let ((wc (get-winconf)))
    (apply set-winconf (append (list c) (cdr wc)))))

(define (set-colorscheme! name)
  (let ((s (aq name colorschemes)))
    (set! *colorscheme* s)
    (set-bg! (aq 'background s))))

(define set-theme! set-colorscheme!)
(define theme-menu (map (→1 (cons (symbol->string x) (→ (set-colorscheme! x))))
                        (map car colorschemes)))

(set! advanced-menu
      (append advanced-menu
              (list (cons "zmien koloryt" (→ (_open-menu theme-menu))))))

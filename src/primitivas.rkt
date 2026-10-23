#lang eopl
;Autores: Juan Felipe Aristizabal 2459364-3743, Juan Sebastian Huertas 2459505-3743

;; Taller 2 — El intérprete de Cauca.
;; Las primitivas del lenguaje y las verificaciones de tipo y de
;; cantidad de argumentos que cada una exige. Requiere sintaxis.rkt.
;;
;; Aridades: +, -, *, / son n-arias; add1, sub1, not y abs son unarias;
;; las relacionales, and, or, xor e implica son binarias; entre es
;; ternaria; mcd y mcm son n-arias sobre enteros con al menos dos
;; argumentos; promedio es n-aria sobre números con al menos uno.

(require "sintaxis.rkt")

;; exigir-numeros : lista x symbol -> boolean
;; Retorna #t si todos los argumentos son números; si no, levanta
;; eopl:error a nombre de quien hizo la verificación.
(define exigir-numeros
  (lambda (args quien)
    (cond ((null? args) #t)
          ((number? (car args)) (exigir-numeros (cdr args) quien))
          (else (eopl:error quien "se esperaba un numero y llego ~s" (car args))))))

;; exigir-enteros : lista x symbol -> boolean
;; Retorna #t si todos los argumentos son enteros exactos; si no,
;; levanta error.
(define exigir-enteros
  (lambda (args quien)
    (cond ((null? args) #t)
          ((and (integer? (car args)) (exact? (car args)))
           (exigir-enteros (cdr args) quien))
          (else (eopl:error quien "se esperaba un entero y llego ~s" (car args))))))

;; exigir-booleanos : lista x symbol -> boolean
;; Retorna #t si todos los argumentos son booleanos; si no, levanta error.
(define exigir-booleanos
  (lambda (args quien)
    (cond ((null? args) #t)
          ((boolean? (car args)) (exigir-booleanos (cdr args) quien))
          (else (eopl:error quien "se esperaba un booleano y llego ~s" (car args))))))

;; exigir-cantidad : lista x int x symbol -> boolean
;; Retorna #t si llegaron exactamente n argumentos; si no, levanta error.
(define exigir-cantidad
  (lambda (args n quien)
    (if (= (length args) n)
        #t
        (eopl:error quien "espera ~s argumento(s) y recibio ~s" n (length args)))))

;; exigir-minimo : lista x int x symbol -> boolean
;; Retorna #t si llegaron al menos n argumentos; si no, levanta error.
(define exigir-minimo
  (lambda (args n quien)
    (if (>= (length args) n)
        #t
        (eopl:error quien "espera al menos ~s argumento(s) y recibio ~s" n (length args)))))

;; aritmetica : lista x (num x num -> num) x symbol -> num
;; Aplica una operación aritmética n-aria de izquierda a derecha
;; después de verificar que haya al menos un argumento y que todos
;; sean números.
(define aritmetica
  (lambda (args op quien)
    (and (exigir-minimo args 1 quien)
         (exigir-numeros args quien)
         (if (null? (cdr args))
             (op (car args))
             (plegar op (car args) (cdr args))))))

;; plegar : (num x num -> num) x num x lista de num -> num
;; Acumula op de izquierda a derecha: ((acc op x1) op x2) ...
(define plegar
  (lambda (op acc resto)
    (if (null? resto)
        acc
        (plegar op (op acc (car resto)) (cdr resto)))))

;; dividir : num x num -> num
;; División que levanta eopl:error cuando el divisor es cero.
(define dividir
  (lambda (a b)
    (if (zero? b)
        (eopl:error '/ "division por cero")
        (/ a b))))

;; relacional : lista x (num x num -> bool) x symbol -> bool
;; Verifica dos argumentos numéricos y los compara.
(define relacional
  (lambda (args op quien)
    (and (exigir-cantidad args 2 quien)
         (exigir-numeros args quien)
         (op (car args) (cadr args)))))

;; evaluar-primitiva : primitiva x lista de valores -> valor
;; Verifica la cantidad y el tipo de los argumentos y aplica la
;; primitiva. Se resuelve con cases sobre el datatype primitiva.
(define evaluar-primitiva
  (lambda (prim args)
    (cases primitiva prim
      (sum-prim () (aritmetica args + '+))
      (minus-prim () (aritmetica args - '-))
      (mult-prim () (aritmetica args * '*))
      (div-prim () (aritmetica args dividir '/))
      (add-prim ()
        (and (exigir-cantidad args 1 'add1)
             (exigir-numeros args 'add1)
             (+ (car args) 1)))
      (sub-prim ()
        (and (exigir-cantidad args 1 'sub1)
             (exigir-numeros args 'sub1)
             (- (car args) 1)))
      (mayor-prim () (relacional args > '>))
      (mayorigual-prim () (relacional args >= '>=))
      (menor-prim () (relacional args < '<))
      (menorigual-prim () (relacional args <= '<=))
      (igual-prim () (relacional args = '==))
      (not-prim ()
        (and (exigir-cantidad args 1 'not)
             (exigir-booleanos args 'not)
             (not (car args))))
      (and-prim ()
        (and (exigir-cantidad args 2 'and)
             (exigir-booleanos args 'and)
             (and (car args) (cadr args))))
      (or-prim ()
        (and (exigir-cantidad args 2 'or)
             (exigir-booleanos args 'or)
             (or (car args) (cadr args)))))))

(provide (all-defined-out))

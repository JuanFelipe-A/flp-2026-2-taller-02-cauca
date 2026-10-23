#lang eopl
;Autores: Juan Felipe Aristizabal 2459364-3743, Juan Sebastian Huertas 2459505-3743

;; Taller 2 — El intérprete de Cauca.
;; El TAD ambiente, la búsqueda de ligaduras y el ambiente inicial.
;; Requiere sintaxis.rkt y valores.rkt.
;;
;; Aquí se declara con define-datatype el tipo ambiente, con tres
;; variantes:
;;
;;   ambiente-vacio()
;;   ambiente-extendido(ids, valores, env)
;;     ids      (list-of symbol?)
;;     valores  list?
;;     env      ambiente?
;;   ambiente-recursivo(proc-names, idss, bodies, env)
;;     proc-names  (list-of symbol?)   los nombres declarados en el letrec
;;     idss        list?               la lista de parámetros de cada uno
;;     bodies      (list-of expresion?) los cuerpos, guardados sin evaluar
;;     env         ambiente?
;;
;; La variante recursiva no construye clausuras: las arma apply-env en el
;; momento de la búsqueda, y el ambiente que les entrega es el propio
;; ambiente-recursivo (EOPL, sección 3.4, figura 3.9).

(require "sintaxis.rkt")
(require "valores.rkt")

(define-datatype ambiente ambiente?
  (ambiente-vacio)
  (ambiente-extendido
   (ids (list-of symbol?))
   (valores list?)
   (env ambiente?)))

;; posicion : symbol x lista de symbol x int -> int o #f
;; Retorna la posición de id en la lista ids, contando desde i,
;; o #f si no aparece.
(define posicion
  (lambda (id ids i)
    (cond ((null? ids) #f)
          ((eqv? id (car ids)) i)
          (else (posicion id (cdr ids) (+ i 1))))))

;; apply-env : ambiente x symbol -> valor
;; Busca el identificador desde la ligadura más reciente hacia afuera,
;; de modo que la más interna oculta a las externas (shadowing).
;; Levanta eopl:error si llega al ambiente vacío sin encontrarlo.
(define apply-env
  (lambda (env id)
    (cases ambiente env
      (ambiente-vacio ()
        (eopl:error 'apply-env "la variable ~s no esta ligada" id))
      (ambiente-extendido (ids valores env-externo)
        (let ((pos (posicion id ids 0)))
          (if pos
              (list-ref valores pos)
              (apply-env env-externo id)))))))

;; ambiente-inicial : -> ambiente
;; El ambiente con que arranca todo programa:
;; n = 10, m = 3, p = 7, q = 2, r = 5.
(define ambiente-inicial
  (lambda ()
    (ambiente-extendido '(n m p q r)
                        '(10 3 7 2 5)
                        (ambiente-vacio))))

(provide (all-defined-out))

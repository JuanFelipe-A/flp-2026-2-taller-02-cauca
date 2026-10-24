#lang eopl
;Autores: Nombre1 Codigo1, Nombre2 Codigo2

;; Taller 2 — El intérprete de Cauca.
;; Fachada: reúne los seis módulos de src/ y reexporta todo lo que
;; definen, de modo que quien la requiera vea todos los nombres sin
;; requerir los módulos uno por uno.
;;
;;   src/sintaxis.rkt    especificación léxica y gramatical, scanner, parser
;;   src/valores.rkt     el valor procedimiento
;;   src/ambiente.rkt    el TAD ambiente y el ambiente inicial
;;   src/primitivas.rkt  las primitivas y sus verificaciones
;;   src/interprete.rkt  la evaluación y la aplicación de procedimientos
;;   src/interfaz.rkt    el punto de entrada y el REPL
;;
;; Los require van en un solo sentido. Racket no carga dos módulos que se
;; requieran entre sí.

(require "src/sintaxis.rkt")
(require "src/valores.rkt")
(require "src/ambiente.rkt")
(require "src/primitivas.rkt")
(require "src/interprete.rkt")
(require "src/interfaz.rkt")

(provide (all-from-out "src/sintaxis.rkt"
                       "src/valores.rkt"
                       "src/ambiente.rkt"
                       "src/primitivas.rkt"
                       "src/interprete.rkt"
                       "src/interfaz.rkt"))

;;; ==========================================================
;;; Ejemplos
;;; ==========================================================

#|
  Aquí van los ejemplos que pide el enunciado: 5 del scanner, 5 del
  parser y los de ejecución de cada parte, con el resultado de cada uno
  escrito al lado. Las pruebas con rackunit viven en pruebas-cauca.rkt.

  Scanner
    (scanner "...")   =>

  Parser
    (parser "...")    =>

  Ejecución del lenguaje base
    (interpretar "...")   =>

  Primitivas nuevas
    (interpretar "abs(-7)")               => 7
    (interpretar "abs(-3.5)")             => 3.5
    (interpretar "mcd(12, 18)")           => 6
    (interpretar "mcd(12, 18, 24)")       => 6
    (interpretar "mcd(1.5, 2)")           => error (argumento no entero)
    (interpretar "mcm(4, 6)")             => 12
    (interpretar "mcm(2, 3, 4)")          => 12
    (interpretar "mcm(4)")                => error (mínimo 2 argumentos)
    (interpretar "promedio(1, 2, 3, 4)")  => 5/2
    (interpretar "promedio(10)")          => 10
    (interpretar "xor(true, false)")      => #t
    (interpretar "xor(true, true)")       => #f
    (interpretar "xor(1, true)")          => error (argumento no booleano)
    (interpretar "implica(true, false)")  => #f
    (interpretar "implica(false, false)") => #t
    (interpretar "entre(5, 1, 10)")       => #t
    (interpretar "entre(11, 1, 10)")      => #f
    (interpretar "entre(1, 2)")           => error (cantidad de argumentos)

  Procedimientos
    (interpretar "...")   =>

  Recursión y case
    (interpretar "...")   =>
|#

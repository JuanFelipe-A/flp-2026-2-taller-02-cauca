#lang eopl
;Autores: Juan Felipe Aristizabal 2459364-3743, Juan Sebastian Huertas 2459505-3743

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
    SLLGEN nombra los tokens de palabras reservadas y signos como
    literal-stringN; el N lo pone SLLGEN y cambia si cambia la gramática.

    (scanner "add1(n)")
      => ((literal-stringN "add1" 1) (literal-stringN "(" 1)
          (identificador n 1) (literal-stringN ")" 1))

    (scanner "let x = -3.5 in +(x, 2) end")
      => ((literal-stringN "let" 1) (identificador x 1) (literal-stringN "=" 1)
          (numero -3.5 1) (literal-stringN "in" 1) (literal-stringN "+" 1)
          (literal-stringN "(" 1) (identificador x 1) (literal-stringN "," 1)
          (numero 2 1) (literal-stringN ")" 1) (literal-stringN "end" 1))

    (scanner "// comentario\n>=(m, -7)")
      => ((literal-stringN ">=" 2) (literal-stringN "(" 2) (identificador m 2)
          (literal-stringN "," 2) (numero -7 2) (literal-stringN ")" 2))
         ; el comentario se descarta y la linea pasa a ser la 2

    (scanner "es_par? <= 4.25")
      => ((identificador es_par? 1) (literal-stringN "<=" 1) (numero 4.25 1))

    (scanner "proc (a, b) *(a, b) end")
      => ((literal-stringN "proc" 1) (literal-stringN "(" 1) (identificador a 1)
          (literal-stringN "," 1) (identificador b 1) (literal-stringN ")" 1)
          (literal-stringN "*" 1) (literal-stringN "(" 1) (identificador a 1)
          (literal-stringN "," 1) (identificador b 1) (literal-stringN ")" 1)
          (literal-stringN "end" 1))

  Parser
    (parser "-7")
      => #(struct:a-program #(struct:lit-exp -7))

    (parser "-(10, 3)")
      => #(struct:a-program
           #(struct:prim-exp #(struct:minus-prim)
                             (#(struct:lit-exp 10) #(struct:lit-exp 3))))

    (parser "if >(n, m) then n else m end")
      => #(struct:a-program
           #(struct:if-exp
             #(struct:prim-exp #(struct:mayor-prim)
                               (#(struct:var-exp n) #(struct:var-exp m)))
             #(struct:var-exp n)
             #(struct:var-exp m)))

    (parser "let x = 2 y = 3 in *(x, y) end")
      => #(struct:a-program
           #(struct:let-exp (x y)
                            (#(struct:lit-exp 2) #(struct:lit-exp 3))
                            #(struct:prim-exp #(struct:mult-prim)
                                              (#(struct:var-exp x) #(struct:var-exp y)))))

    (parser "apply f (1, true)")
      => #(struct:a-program
           #(struct:app-exp #(struct:var-exp f)
                            (#(struct:lit-exp 1) #(struct:true-exp))))

  Ejecución del lenguaje base
    (interpretar "42")                                      => 42
    (interpretar "-3.5")                                    => -3.5
    (interpretar "p")                                       => 7
    (interpretar "true")                                    => #t
    (interpretar "-(10, 3, 2)")                             => 5
    (interpretar "/(100, 5, 2)")                            => 10
    (interpretar "add1(sub1(q))")                           => 2
    (interpretar "not(<=(r, q))")                           => #t
    (interpretar "or(==(n, 10), false)")                    => #t
    (interpretar "if >=(m, m) then *(p, q) else 0 end")     => 14
    (interpretar "let x = 1 in let x = +(x, n) in x end end") => 11
    (interpretar "let base = 8 altura = 5 in if and(>(base, 0), >(altura, 0))
                  then *(base, altura) else 0 end end")     => 40
    (interpretar "if n then 1 else 2 end")
      => error if-exp: la condicion debe ser booleana y llego 10
    (interpretar "z")
      => error apply-env: la variable z no esta ligada
    (interpretar "+(1, true)")
      => error +: se esperaba un numero y llego #t
    (interpretar "/(n, 0)")
      => error /: division por cero
    (interpretar "and(true)")
      => error and: espera 2 argumento(s) y recibio 1

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
    ; sin parametros
    (interpretar "let f = proc () 7 end in apply f () end")          => 7
    ; un parametro
    (interpretar "let escalar = proc (v) *(v, 2) end
                  in apply escalar (21) end")                        => 42
    ; varios parametros
    (interpretar "let f = proc (a, b, c) +(a, b, c) end
                  in apply f (1, 2, 3) end")                         => 6
    ; recibe un procedimiento como argumento
    (interpretar "let aplicardos = proc (f, x) apply f (apply f (x)) end
                      doble = proc (v) *(v, 2) end
                  in apply aplicardos (doble, 5) end")               => 20
    ; retorna un procedimiento
    (interpretar "let sumador = proc (a) proc (b) +(a, b) end end
                  in let suma3 = apply sumador (3)
                     in apply suma3 (4) end end")                    => 7
    ; ejemplo de contraste: el cuerpo usa el ambiente de la definicion
    (interpretar "let factor = 10
                  in let escalar = proc (v) *(v, factor) end
                     in let factor = 1000 in apply escalar (5) end end end") => 50
    ; errores
    (interpretar "apply 5 (1)")
      => error app-exp: 5 no es un procedimiento
    (interpretar "let f = proc (a, b) +(a, b) end in apply f (1) end")
      => error apply-procedure: el procedimiento espera 2 argumento(s) y recibio 1

  Recursión y case
    ; recursion simple
    (interpretar "letrec factorial (k) = if ==(k, 0) then 1
                                         else *(k, apply factorial (sub1(k))) end
                  in apply factorial (5) end")                       => 120
    ; dos parametros
    (interpretar "letrec potencia (base, exp) = if ==(exp, 0) then 1
                                         else *(base, apply potencia (base, sub1(exp))) end
                  in apply potencia (2, 10) end")                    => 1024
    ; recursion mutua en el mismo letrec
    (interpretar "letrec par? (k) = if ==(k, 0) then true else apply impar? (sub1(k)) end
                         impar? (k) = if ==(k, 0) then false else apply par? (sub1(k)) end
                  in apply impar? (7) end")                          => #t
    ; letrec con un procedimiento pasado como argumento
    (interpretar "letrec aplicarn (f, x, veces) = if ==(veces, 0) then x
                                         else apply f (apply aplicarn (f, x, sub1(veces))) end
                  in let doble = proc (v) *(v, 2) end
                     in apply aplicarn (doble, 1, 5) end end")       => 32
    ; la misma recursion con let falla: fact no esta en el ambiente de la clausura
    (interpretar "let fact = proc (k) if ==(k, 0) then 1
                                      else *(k, apply fact (sub1(k))) end end
                  in apply fact (3) end")
      => error apply-env: la variable fact no esta ligada
    ; case
    (interpretar "let dia = 3 in case dia of 1 => 100 of 3 => 300 of 7 => 700 otherwise => 0 end end")  => 300
    (interpretar "let dia = 5 in case dia of 1 => 100 of 3 => 300 otherwise => 0 end end")              => 0
    (interpretar "case +(1, 2) of 2 => 20 of 3 => 30 otherwise => 0 end")                              => 30
    (interpretar "case true of 1 => 1 otherwise => 0 end")                                             => error (control no numérico)
|#

(include "sake.scm")
(module foobar ()
  (import scheme chicken srfi-1 sake)
  (define (update-s)
    (call-with-output-file "s.txt"
      (lambda (f)
	(display "Soda\n" f)))
    (print "Hello World")
    #t)
  (define foo
    (task ("s.txt" "b.txt" "x.txt")
	  (update-s)))
  (define bar
    (task (foo)
	  #t))
  (define ss
    (task ("ss")
      #t))
  (define baz
    (task (foo ss)
      #t))
  (update baz))
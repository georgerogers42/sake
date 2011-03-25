(include "sake.scm")
(import sake)
(define main
  (task ("getreal.tex" "hello.rb" "Hello.java")
    (system "lualatex getreal.tex")
    (system "lualatex getreal.tex")))
(update main)
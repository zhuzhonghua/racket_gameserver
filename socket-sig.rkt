#lang racket

(struct socket (id in out
                   [err #:auto]
                   [buf #:auto]                   
                   [act-len #:auto]
                   [out-buf #:auto]
                   [outactlen #:auto])
  #:auto-value 0 #:mutable #:prefab)

(define-signature socket^
  (make-socket
   pack-msg
   read-sock
   send-msg
   flush-sock))

(provide (all-defined-out))

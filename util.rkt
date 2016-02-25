#lang racket

(provide (all-defined-out))

(define (prn-ln . args)
  (displayln (apply format args)))

(define next-sock-id
  (let ((id 0))
    (lambda ()
      (set! id (add1 id))
      id)))

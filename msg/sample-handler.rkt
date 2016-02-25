#lang racket

(require "../op.rkt"
         "../util.rkt"
         "../socket.rkt")

(define (sample-handler sock msg)
  (prn-ln "enter sample-handler")
  (send-msg sock 10 msg)
  (prn-ln "send sample msg"))

(provide (all-defined-out))




#lang racket

(require (planet murphy/protobuf))
(require "../op.rkt"
         "sample-handler.rkt")

(provide (all-defined-out))

(define (handle-msg sock op msg)
  (cond
    [(= op OP-SAMPLE) (sample-handler sock msg)]
    [else #f]))

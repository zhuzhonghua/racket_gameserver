#lang racket

(require (planet murphy/protobuf))
(require "proto/sample.rkt"
         "op.rkt")

(provide (all-defined-out))

(define (make-msg op bytes)
  (cond
    [(= op OP-SAMPLE) (deserialize (person*) (open-input-bytes bytes))]
    [else #f]))

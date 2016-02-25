#lang racket
(require (planet murphy/protobuf))
(require "proto/sample.rkt")

(define p (person* #:name "Philip" #:id 42))

(define po (open-output-bytes))
(serialize p po)

(person-name (deserialize (person*) (open-input-bytes (get-output-bytes po))))

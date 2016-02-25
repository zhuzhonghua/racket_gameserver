#lang racket
(require (planet murphy/protobuf))
(require "proto/sample.rkt")

(define p (person* #:name "Philip" #:id 42))

(serialize p)

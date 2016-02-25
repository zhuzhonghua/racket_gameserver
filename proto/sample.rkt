#lang racket/base
;; Generated using protoc-gen-racket v1.1
(require (planet murphy/protobuf:1/syntax))

(define-message-type
 person
 ((required primitive:string name 1)
  (required primitive:int32 id 2)
  (optional primitive:string email 3)))

(provide (all-defined-out))

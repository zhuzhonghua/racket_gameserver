#lang racket

(require (planet murphy/protobuf))
(require "util.rkt"
         "proto.rkt")

(struct socket (id in out
                   [err #:auto]
                   [buf #:auto]                   
                   [act-len #:auto]
                   [out-buf #:auto]
                   [outactlen #:auto])
  #:auto-value 0 #:mutable #:prefab)

(define (make-socket in out)
  (let ([sock (socket (next-sock-id) in out)])
    (set-socket-buf! sock (make-bytes 2048))
    (set-socket-err! sock #f)
    (set-socket-out-buf! sock (make-bytes 4096))
    sock))

(define (pack-msg sock handle-msg)
  (when (>= (socket-act-len sock) 6)
    (define op-code (integer-bytes->integer (socket-buf sock) #f #f 0 2))
    (define body-len (integer-bytes->integer (socket-buf sock) #f #f 2 6))
    (when (> body-len (- (bytes-length (socket-buf sock)) 6))
      (begin
        (set-socket-err! sock (format "too long body ~a" body-len))
        (error (format "too long body ~a" body-len))))
    (when (>= (socket-act-len sock) (+ 6 body-len))
      (define msg (make-msg op-code (subbytes (socket-buf sock) 6 (+ 6 body-len))))
      (if (not msg)
          (begin
            (set-socket-err! sock (format "no such msg ~a" op-code))
            (error (format "no such msg ~a" op-code)))
          (begin
            (bytes-copy! (socket-buf sock)
                         0
                         (socket-buf sock)
                         (- (socket-act-len sock) 6 body-len))
            (set-socket-act-len! sock (- (socket-act-len sock) 6 body-len))
            (handle-msg sock op-code msg))))))

(define (read-sock sock)
  (when (and (not (port-closed? (socket-in sock)))
             (byte-ready? (socket-in sock)))
    (define len (read-bytes-avail!* (socket-buf sock)
                                    (socket-in sock)
                                    (socket-act-len sock)
                                    (bytes-length (socket-buf sock))))
    (set-socket-act-len! sock (+ (socket-act-len sock) len))))

(define-syntax-rule (send-integer sock n l)
  (begin
    (integer->integer-bytes n l #f #f (socket-out-buf sock) (socket-outactlen sock))
    (set-socket-outactlen! sock (+ l (socket-outactlen sock)))))

(define-syntax-rule (send-bytes sock buf)
  (begin
    (bytes-copy! (socket-out-buf sock)
                 (socket-outactlen sock)
                 buf
                 0)
    (set-socket-outactlen! sock (+ (bytes-length buf) (socket-outactlen sock)))))

(define (send-msg sock op msg)
  (define po (open-output-bytes))
  (serialize msg po)
  (define buf (get-output-bytes po))
  (when (> (+ 6 (bytes-length buf) (socket-outactlen sock))
           (bytes-length (socket-out-buf sock)))
    (error (format "too much bytes ~a op ~a" (bytes-length buf) op)))
  (send-integer sock op 2)
  (send-integer sock (bytes-length buf) 4)
  (send-bytes sock buf)
  (flush-sock sock))

(define (flush-sock sock)
  (when (> (socket-outactlen sock) 0)
    (define ret (write-bytes-avail* (socket-out-buf sock)
                                    (socket-out sock)
                                    0
                                    (socket-outactlen sock)))
    (cond
      [(and (number? ret) (> ret 0)) (begin
                                       (bytes-copy! (socket-out-buf sock)
                                                    0
                                                    (socket-out-buf sock)
                                                    ret
                                                    (socket-outactlen sock))
                                       (set-socket-outactlen! sock (- (socket-outactlen sock) ret)))]
      [else "wait next time"])))

(provide (all-defined-out))


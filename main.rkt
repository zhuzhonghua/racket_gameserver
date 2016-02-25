#lang racket
(require (planet murphy/protobuf:1:1))
(require racket/tcp)
(require racket/port)

(require "proto.rkt"
         "util.rkt"
         "socket.rkt"
         "msg/route.rkt")

(define server-listener #f)
(define end? #f)
(define all-socks (make-hash))
(define msg-head-len 6)

(define (accept-conn listener)
  (when (tcp-accept-ready? listener)
    (define-values (in out) (tcp-accept listener))
    (define sock (make-socket in out))
    (prn-ln "newsocket ~a" (socket-id sock))
    (hash-set! all-socks (socket-id sock) sock)))

(define (read-conn)
  (for ((k (hash-keys all-socks)))
    (let ([c (hash-ref all-socks k)])
      (read-sock c)      
      (pack-msg c handle-msg))))

(define (flush-conn)
  (for ((k (hash-keys all-socks)))
    (let ([c (hash-ref all-socks k)])
      (flush-sock c))))

(define (handle-conn)
  (accept-conn server-listener)
  (read-conn)
  (flush-conn)
  (sleep 0.01)
  (handle-conn))

(define (listen port-no)
  (prn-ln "listen ~a" port-no)
  (set! server-listener (tcp-listen port-no))
  (handle-conn))

(define (game-loop)
  (prn-ln "enter game-loop")
  (when (file-exists? "kill.out")
    (prn-ln "kill.out exist delete it")
    (delete-file "kill.out"))
  
  (define main-cust (make-custodian))
  (parameterize ([current-custodian main-cust])
    (thread (lambda() (listen 8080))))
  
  (define (check-end)
    (when (file-exists? "kill.out")
      (set! end? true))
    
    (unless end?
      (sleep 1)
      (check-end)))
  (check-end)
  
  (custodian-shutdown-all main-cust))

(game-loop)

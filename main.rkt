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

(define (sock-exn-handler k exn)
  (prn-ln "clear socks ~a" k)
  (close-socket (hash-ref all-socks k))
  (prn-ln "remove socks ~a" k)
  (hash-remove! all-socks k)
  (prn-ln "exception raise")
  (prn-ln "~a" exn))

(define (accept-conn listener)
  (when (tcp-accept-ready? listener)
    (define-values (in out) (tcp-accept listener))
    (define sock (make-socket in out))
    (prn-ln "newsocket ~a" (socket-id sock))
    (hash-set! all-socks (socket-id sock) sock)))

(define (read-conn)
  (for ([k (hash-keys all-socks)])
    (define sock (hash-ref all-socks k))
    (with-handlers ([exn:fail? (lambda (exn) (sock-exn-handler k exn))])
      (read-sock sock)
      (pack-msg sock handle-msg))))

(define (flush-conn)
  (for ([k (hash-keys all-socks)])
    (define sock (hash-ref all-socks k))
    (with-handlers ([exn:fail? (lambda (exn) (sock-exn-handler k exn))])
      (flush-sock sock))))

;; 游戏主逻辑
;; 接收新连接
;; 读取客户端发送过来的消息
;; flush给客户端的消息
;; 等待，继续循环
(define (game-loop)
  (accept-conn server-listener)
  (read-conn)
  (flush-conn)
  (sleep 0.01)
  (game-loop))

(define (game-end)
  (prn-ln "game end do clean stuff"))

;; 主入口函数
(define (serve port-no)
  (define main-cust (make-custodian)) ;; 定义守护者，便于清理所有相关资源
  (parameterize ([current-custodian main-cust])
    (prn-ln "listen ~a" port-no)
    (set! server-listener (tcp-listen port-no)) ;; 接收连接
    ;; 进入游戏主循环
    (prn-ln "enter game-loop in thread")
    (thread game-loop))

  ;; 检查游戏是否应该关闭，退出
  (define (check-game-end)
    (when (file-exists? "kill.out")
      (prn-ln "kill.out exist, delete it")
      (delete-file "kill.out")
      (set! end? true)
      (game-end))

    ;; 等待，循环检测
    (unless end?
      (sleep 1)
      (check-game-end))

    (custodian-shutdown-all main-cust))

  (check-game-end))

(serve 8080)

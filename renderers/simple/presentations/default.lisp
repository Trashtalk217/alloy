#|
 This file is a part of Alloy
 (c) 2019 Shirakumo http://tymoon.eu (shinmera@tymoon.eu)
 Author: Nicolas Hafner <shinmera@tymoon.eu>
|#

(in-package #:org.shirakumo.alloy.renderers.simple.presentations)

;; TODO: Pallettes

(defclass default-look-and-feel (renderer)
  ())

(defmethod update-shape ((renderer default-look-and-feel) (renderable alloy:button) (shape text))
  (call-next-method)
  (setf (text shape) (alloy:data renderable)))

(defmethod update-shape ((renderer default-look-and-feel) (renderable alloy:label) (shape text))
  (call-next-method)
  (setf (text shape) (alloy:data renderable)))

(defmethod update-shape ((renderer default-look-and-feel) (renderable alloy:input-line) (shape text))
  (call-next-method)
  (setf (text shape) (alloy:value renderable)))

(define-style (default-look-and-feel renderable)
  (:background
   :fill-color (simple:color 0.15 0.15 0.15))
  (:border
   :fill-color (case (alloy:focus)
                 ((:weak :strong) (simple:color 0.9 0.9 0.9))
                 (T (simple:color 0 0 0 0)))
   :z-index -1)
  (:label
   :fill-color (case (alloy:focus)
                 ((:weak :strong) (simple:color 0 0 0))
                 (T (simple:color 1 1 1)))))

(define-realisation (default-look-and-feel alloy:label)
  ((:label text)
   :text (alloy:data alloy:renderable)
   :extent (alloy:margins)))

(define-realisation (default-look-and-feel alloy:button)
  ((:background filled-box)
   :extent (alloy:margins))
  ((:border outlined-box)
   :extent (alloy:margins (alloy:un -3)))
  ((:label text)
   :text (alloy:data alloy:renderable)
   :extent (alloy:margins (alloy:un 1))
   :halign :middle))

(define-style (default-look-and-feel alloy:button)
  (:background
   :fill-color (case (alloy:focus)
                 (:strong (simple:color 0.9 0.9 0.9))
                 (:weak (simple:color 0.7 0.7 0.7))
                 (T (simple:color 0.25 0.2 0.8)))))

(define-realisation (default-look-and-feel alloy:switch)
  ((:background filled-box)
   :extent (alloy:margins))
  ((:border outlined-box)
   :extent (alloy:margins (alloy:un -3)))
  ((:switch filled-box)
   :extent (alloy:extent 0 0 (alloy:pw 0.3) (alloy:ph))))

(define-style (default-look-and-feel alloy:switch)
  (:switch
   :offset (alloy:point (if (alloy:value alloy:renderable)
                            (alloy:pw 0.7)
                            0))
   :fill-color (case (alloy:focus)
                 (:strong (simple:color 1 1 1))
                 (T (simple:color 0.25 0.2 0.8)))))

(define-realisation (default-look-and-feel alloy:input-line)
  ((:background filled-box)
   :extent (alloy:margins))
  ((:border outlined-box)
   :extent (alloy:margins (alloy:un -3)))
  ((:label text)
   :text (alloy:value alloy:renderable)
   :extent (alloy:margins (alloy:un 1)))
  ((:cursor filled-box)
   :extent (alloy:extent 0 (alloy:ph 0.15) 1 (alloy:ph 0.7))))

(define-style (default-look-and-feel alloy:input-line)
  (:background
   :fill-color (case (alloy:focus)
                 (:strong (simple:color 0.9 0.9 0.9))
                 (:weak (simple:color 0.7 0.7 0.7))
                 (T (simple:color 0.15 0.15 0.15))))
  (:cursor
   :fill-color (case (alloy:focus)
                 (:strong (simple:color 0 0 0))
                 (T (simple:color 0 0 0 0)))))

(define-realisation (default-look-and-feel alloy:slider)
  ((:background filled-box)
   :extent (alloy:margins))
  ((:border outlined-box)
   :extent (alloy:margins (alloy:un -3)))
  ((:handle filled-box)
   :extent (alloy:extent 0 0 (alloy:un 10) (alloy:ph))))

(define-style (default-look-and-feel alloy:slider)
  (:handle
   :offset (alloy:point (alloy:vw (/ (- (alloy:value alloy:renderable) (alloy:minimum alloy:renderable))
                                     (- (alloy:maximum alloy:renderable) (alloy:minimum alloy:renderable))))
                        0)
   :fill-color (case (alloy:focus)
                 (:strong (simple:color 1 1 1))
                 (T (simple:color 0.25 0.2 0.8)))))

#|
 This file is a part of Alloy
 (c) 2019 Shirakumo http://tymoon.eu (shinmera@tymoon.eu)
 Author: Nicolas Hafner <shinmera@tymoon.eu>
|#

(in-package #:org.shirakumo.alloy.renderers.simple.presentations)

;; TODO: Pallettes

(defclass default-look-and-feel (renderer)
  ())

(define-update (default-look-and-feel alloy:renderable)
  (:background
   :pattern (colored:color 0.15 0.15 0.15))
  (:border
   :pattern (colored:color 0.9 0.9 0.9)
   :hidden-p (null alloy:focus)
   :z-index 1)
  (:label
   :pattern (case alloy:focus
              ((:weak :strong) colors:black)
              (T colors:white))))

(define-realization (default-look-and-feel alloy:label)
  ((:label simple:text)
   (alloy:margins)
   (alloy:data alloy:renderable)
   :pattern (colored:color 1 1 1)))

(define-update (default-look-and-feel alloy:label)
  (:label
   :text (alloy:data alloy:renderable)))

(define-realization (default-look-and-feel alloy:icon)
  ((:icon simple:icon)
   (alloy:margins)
   (alloy:data alloy:renderable)))

(define-realization (default-look-and-feel alloy:button)
  ((:background simple:rectangle)
   (alloy:margins))
  ((:border simple:rectangle)
   (alloy:margins -3)
   :line-width (alloy:un 1))
  ((:label simple:text)
   (alloy:margins 1)
   (alloy:data alloy:renderable)
   :halign :middle
   :valign :middle))

(define-update (default-look-and-feel alloy:button)
  (:background
   :pattern (case alloy:focus
                 (:strong (colored:color 0.9 0.9 0.9))
                 (:weak (colored:color 0.7 0.7 0.7))
                 (T (colored:color 0.25 0.2 0.8))))
  (:label
   :text (alloy:data alloy:renderable)))

(define-realization (default-look-and-feel alloy:switch)
  ((:background simple:rectangle)
   (alloy:margins))
  ((:border simple:rectangle)
   (alloy:margins -3)
   :line-width (alloy:un 1))
  ((:switch simple:rectangle)
   (alloy:extent 0 0 (alloy:pw 0.3) (alloy:ph))))

(define-update (default-look-and-feel alloy:switch)
  (:switch
   :offset (alloy:point (if alloy:value
                            (alloy:pw 0.7)
                            0))
   :pattern (case alloy:focus
                 (:strong colors:white)
                 (T (colored:color 0.25 0.2 0.8)))))

(define-realization (default-look-and-feel alloy:input-line)
  ((:background simple:rectangle)
   (alloy:margins))
  ((:border simple:rectangle)
   (alloy:margins -3)
   :line-width (alloy:un 1))
  ((:label simple:text)
   (alloy:margins 1)
   alloy:value
   :valign :middle)
  ((:cursor simple:cursor)
   (find-shape :label alloy:renderable)
   0
   :pattern colors:black))

(define-update (default-look-and-feel alloy:input-line)
  (:background
   :pattern (case alloy:focus
              (:strong (colored:color 0.9 0.9 0.9))
              (:weak (colored:color 0.7 0.7 0.7))
              (T (colored:color 0.15 0.15 0.15))))
  (:cursor
   :hidden-p (null alloy:focus)
   :position (alloy:pos (alloy:cursor alloy:renderable)))
  (:label
   :text alloy:value))

(define-realization (default-look-and-feel alloy:slider)
  ((:background simple:rectangle)
   (ecase (alloy:orientation alloy:renderable)
     (:horizontal (alloy:extent 0 (alloy:ph 0.4) (alloy:pw) (alloy:ph 0.2)))
     (:vertical (alloy:extent (alloy:pw 0.4) 0 (alloy:pw 0.2) (alloy:ph)))))
  ((:border simple:rectangle)
   (alloy:margins -3)
   :line-width (alloy:un 1))
  ((:handle simple:rectangle)
   (ecase (alloy:orientation alloy:renderable)
     (:horizontal (alloy:extent -5 0 10 (alloy:ph)))
     (:vertical (alloy:extent 0 -5 (alloy:pw) 10)))))

(define-update (default-look-and-feel alloy:slider)
  (:handle
   :offset (ecase (alloy:orientation alloy:renderable)
             (:horizontal (alloy:point (alloy:pw (alloy:slider-unit alloy:renderable)) 0))
             (:vertical (alloy:point 0 (alloy:ph (alloy:slider-unit alloy:renderable)))))
   :pattern (case alloy:focus
                 (:strong colors:white)
                 (T (colored:color 0.25 0.2 0.8)))))

(define-realization (default-look-and-feel alloy:progress)
  ((:background simple:rectangle)
   (alloy:margins))
  ((:bar simple:rectangle)
   (alloy:margins 3))
  ((:label simple:text)
   (alloy:margins 1)
   ""
   :halign :middle
   :valign :middle))

(define-update (default-look-and-feel alloy:progress)
  (:bar
   :pattern (colored:color 0.25 0.2 0.8)
   :scale (let ((p (/ alloy:value (alloy:maximum alloy:renderable))))
            (alloy:px-size p 1)))
  (:label
   :text (format NIL "~,1f%" (/ (alloy:value alloy:renderable) (alloy:maximum alloy:renderable) 1/100))
   :pattern colors:white))

(define-realization (default-look-and-feel alloy:radio)
  ((:background simple:ellipse)
   (alloy:extent 0 0 (alloy:ph 1) (alloy:ph 1)))
  ((:inner simple:ellipse)
   (alloy:extent (alloy:ph 0.1) (alloy:ph 0.1) (alloy:ph 0.8) (alloy:ph 0.8)))
  ((:border simple:ellipse)
   (alloy:extent (alloy:ph -0.1) (alloy:ph -0.1) (alloy:ph 1.2) (alloy:ph 1.2))
   :line-width (alloy:un 1)))

(define-update (default-look-and-feel alloy:radio)
  (:inner
   :hidden-p (not (alloy:active-p alloy:renderable))
   :pattern (colored:color 0.25 0.2 0.8)))

(define-realization (default-look-and-feel alloy:combo)
  ((:background simple:rectangle)
   (alloy:margins))
  ((:border simple:rectangle)
   (alloy:margins -3)
   :line-width (alloy:un 1))
  ((:label simple:text)
   (alloy:margins 1)
   (princ-to-string (alloy:value alloy:renderable))))

(define-update (default-look-and-feel alloy:combo)
  (:label
   :pattern colors:white
   :text (princ-to-string (alloy:value alloy:renderable))))

(define-realization (default-look-and-feel alloy:combo-item)
  ((:background simple:rectangle)
   (alloy:margins))
  ((:label simple:text)
   (alloy:margins 1)
   (alloy:data alloy:renderable)))

(define-update (default-look-and-feel alloy:combo-item)
  (:background
   :pattern (case (alloy:focus alloy:renderable)
                 ((:weak :strong) (colored:color 0.25 0.2 0.8))
                 ((NIL) (colored:color 0.15 0.15 0.15))))
  (:label
   :pattern colors:white))

(define-realization (default-look-and-feel alloy:scrollbar)
  ((:background simple:rectangle)
   (alloy:margins))
  ((:handle simple:rectangle)
   (ecase (alloy:orientation alloy:renderable)
     (:horizontal (alloy:extent -10 0 20 (alloy:ph)))
     (:vertical (alloy:extent 0 -10 (alloy:pw) 20)))))

(define-realization (default-look-and-feel alloy:plot)
  ((:background simple:rectangle)
   (alloy:margins))
  ((:border simple:rectangle)
   (alloy:margins -3)
   :line-width (alloy:un 1))
  ((:curve simple:line-strip)
   (alloy:plot-points alloy:renderable)
   :pattern (colored:color 0.25 0.2 0.8)))

(define-update (default-look-and-feel alloy:plot)
  (:curve
   :points (alloy:plot-points alloy:renderable)))

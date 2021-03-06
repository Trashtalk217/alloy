#|
 This file is a part of Alloy
 (c) 2019 Shirakumo http://tymoon.eu (shinmera@tymoon.eu)
 Author: Nicolas Hafner <shinmera@tymoon.eu>
|#

(in-package #:org.shirakumo.alloy.layouts.constraint)

(defvar *expression-transforms* (make-hash-table :test 'eq))

(defmacro define-expression-transform (name args &body expressions)
  `(setf (gethash ',name *expression-transforms*)
         (lambda ,args
           (list ,@expressions))))

(defun rewrite-variable (var element layout)
  (with-vars (rx ry rw rh layout) layout
    (with-vars (x y w h layout) element
      (case var
        (:x x)
        (:y y)
        (:w w)
        (:h h)
        (:l `(- x rx))
        (:b `(- y ry))
        (:r `(- (+ ,rx ,rw) (+ ,x ,w)))
        (:u `(- (+ ,ry ,rh) (+ ,y ,h)))
        (:rx rx)
        (:ry ry)
        (:rw rw)
        (:rh rh)
        (T var)))))

(defun rewrite-expression (expression element layout)
  (etypecase expression
    ((or real cass:variable) expression)
    (symbol (rewrite-variable expression element layout))
    (cons
     (flet ((r (expr)
              (rewrite-expression expr element layout)))
       (case (first expression)
         ((:x :y :w :h :l :b :r :u)
          (rewrite-variable (first expression) (second expression) layout))
         (T
          (list* (first expression)
                 (loop for term in (rest expression)
                       collect (r term)))))))))

(defun transform-expression (expression)
  (typecase expression
    (symbol
     (let ((function (gethash expression *expression-transforms*)))
       (if function
           (funcall function)
           (error "Unknown expression ~s" expression))))
    (cons
     (let ((function (gethash (first expression) *expression-transforms*)))
       (if function
           (apply function (rest expression))
           (list expression))))))

(define-expression-transform :center-x ()
  `(= (/ :rw 2) (- :l (/ :w 2))))

(define-expression-transform :center-y ()
  `(= (/ :rh 2) (- :b (/ :h 2))))

(define-expression-transform :left ()
  `(= :l 0))

(define-expression-transform :right ()
  `(= :r 0))

(define-expression-transform :top ()
  `(= :u 0))

(define-expression-transform :bottom ()
  `(= :b 0))

(define-expression-transform :square ()
  `(= :w :h))

(define-expression-transform :contained ()
  `(<= 0 :l)
  `(<= 0 :r)
  `(<= 0 :u)
  `(<= 0 :b))

(define-expression-transform :left-to (other)
  `(= :r (:l ,other)))

(define-expression-transform :right-to (other)
  `(= :l (:r ,other)))

(define-expression-transform :above (other)
  `(<= (+ (:y ,other) (:h ,other)) :y))

(define-expression-transform :below (other)
  `(<= (+ :y :h) (:y ,other)))

(define-expression-transform :aspect-ratio (ratio)
  `(= :h (* :w ,ratio)))

(define-expression-transform :min-width (width)
  `(<= ,width :w))

(define-expression-transform :min-height (height)
  `(<= ,height :h))

(define-expression-transform :min-size (width height)
  `(<= ,width :w)
  `(<= ,height :h))

(define-expression-transform :max-width (width)
  `(<= :w ,width))

(define-expression-transform :max-height (height)
  `(<= :h ,height))

(define-expression-transform :max-size (width height)
  `(<= ,width :w)
  `(<= ,height :h))

(define-expression-transform :between-x (left right)
  `(<= (:x ,left) :x)
  `(<= (+ :x :w) (:x ,right)))

(define-expression-transform :between-y (left right)
  `(<= (:y ,left) :y)
  `(<= (+ :y :h) (:y ,right)))

#|
 This file is a part of Alloy
 (c) 2019 Shirakumo http://tymoon.eu (shinmera@tymoon.eu)
 Author: Nicolas Hafner <shinmera@tymoon.eu>
|#

(in-package #:org.shirakumo.alloy.renderers.svg)

(defvar *container*)

(defclass image (simple:image)
  ())

(defmethod ->svg ((thing simple:color))
  (format NIL "rgb(~d, ~d, ~d)"
          (floor (* 255 (simple:r thing)))
          (floor (* 255 (simple:g thing)))
          (floor (* 255 (simple:b thing)))))

(defmethod ->svg ((thing vector))
  (format NIL "matrix(~f, ~f, ~f, ~f, ~f, ~f)"
          (aref thing 0) (aref thing 3)
          (aref thing 1) (aref thing 4)
          (aref thing 2) (aref thing 5)))

(defmethod ->svg ((thing float))
  (format NIL "~fpx" thing))

(defmethod ->svg ((thing alloy:extent))
  (format NIL "rect(~dpx, ~dpx, ~dpx, ~dpx)"
          (- (alloy:h *container*) (alloy:y thing) (alloy:h thing))
          (- (alloy:w *container*) (alloy:x thing) (alloy:w thing))
          (alloy:y thing)
          (alloy:x thing)))

(defgeneric svg-parameters (thing)
  (:method-combination append))

(defmethod svg-parameters append ((style simple:style))
  (list*
   :opacity (simple:a (simple:fill-color style))
   (ecase (simple:fill-mode style)
     (:lines
      (list :stroke (->svg (simple:fill-color style))
            :stroke-width (->svg (simple:line-width style))
            :style "fill:none;"))
     (:fill
      (list :fill (->svg (simple:fill-color style)))))))

(defmethod svg-parameters append ((transform simple:transform))
  (list*
   :transform (->svg (simple:transform-matrix transform))
   (when (simple:clip-mask transform)
     (list :clip (->svg (simple:clip-mask transform))))))

(defclass renderer (simple:simple-styled-renderer
                    simple:simple-transformed-renderer)
  ((scene :accessor scene)
   (size :initarg :size :initform (alloy:size 800 600) :reader size)))

(defmethod alloy:h ((renderer renderer))
  (alloy:h (size renderer)))

(defmethod alloy:w ((renderer renderer))
  (alloy:w (size renderer)))

(defmethod alloy:allocate ((renderer renderer))
  (unless (slot-boundp renderer 'scene)
    (setf (scene renderer) (cl-svg:make-svg-toplevel 'cl-svg:svg-1.1-toplevel
                                                     :width (alloy:w (size renderer))
                                                     :height (alloy:h (size renderer))))))

(defmethod alloy:deallocate ((renderer renderer))
  (slot-makunbound renderer 'scene))

(defmethod alloy:register (renderable (renderer renderer)))

(defmethod alloy:render :around ((renderer renderer) (ui alloy:ui))
  (let ((*container* (scene renderer)))
    (call-next-method)))

(defmethod render-to-file (renderable file (renderer renderer) &key (if-exists :supersede))
  (with-open-file (stream file :direction :output
                               :if-exists if-exists)
    (alloy:allocate renderer)
    (unwind-protect
         (progn
           (when renderable
             (alloy:render renderer renderable))
           (cl-svg:stream-out stream (scene renderer))
           file)
      (alloy:deallocate renderer))))

(defmethod simple:make-default-transform ((renderer renderer))
  (let ((transform (call-next-method)))
    (setf (simple:transform-matrix transform)
          (simple:matrix 1  0 0
                         0 -1 (alloy:h renderer)
                         0  0 1))
    transform))

(defmethod draw ((renderer renderer) type &rest parameters)
  (cl-svg:add-element
   (scene *container*)
   (cl-svg::make-svg-element
    type
    (append parameters
            (svg-parameters (simple:style renderer))
            (svg-parameters (simple:transform renderer))))))

(defmethod simple:line ((renderer renderer) point-a point-b)
  (draw renderer :line
        :x1 (alloy:x point-a)
        :y1 (alloy:y point-a)
        :x2 (alloy:x point-b)
        :y2 (alloy:y point-b)))

(defmethod simple:rectangle ((renderer renderer) extent)
  (draw renderer :rect
        :x (alloy:x extent)
        :y (alloy:y extent)
        :width (alloy:w extent)
        :height (alloy:h extent)))

(defmethod simple:ellipse ((renderer renderer) extent)
  (draw renderer :ellipse
        :cx (+ (alloy:x extent) (/ (alloy:w extent) 2))
        :cy (+ (alloy:y extent) (/ (alloy:h extent) 2))
        :rx (/ (alloy:w extent) 2)
        :ry (/ (alloy:h extent) 2)))

(defmethod simple:polygon ((renderer renderer) points)
  (draw renderer :polygon
        :points (with-output-to-string (out)
                  (dolist (point points)
                    (format out "~a,~a "
                            (alloy:x point)
                            (- (alloy:h renderer) (alloy:y point)))))))

(defmethod simple:text ((renderer renderer) point string &key (font (simple:font renderer))
                                                              (size (simple:font-size renderer)))
  (simple:with-pushed-transforms (renderer)
    (simple:scale renderer (alloy:size 1 -1))
    (let ((element (cl-svg::make-svg-element
                    :text
                    (append (list :x (alloy:x point)
                                  :y (- (alloy:y point))
                                  :color (->svg (simple:fill-color renderer))
                                  :opacity (simple:a (simple:fill-color renderer))
                                  :font-family (simple:family font)
                                  :font-style (simple:style font)
                                  :font-variant (simple:variant font)
                                  :font-weight (simple:weight font)
                                  :font-stretch (simple:stretch font)
                                  :font-size size)
                            (svg-parameters (simple:transform renderer))))))
      (cl-svg:add-element (scene *container*) element)
      (cl-svg:add-element element string))))

(defmethod simple:image ((renderer renderer) point (image image) &key (size (size image)))
  (simple:with-pushed-transforms (renderer)
    (simple:scale renderer (alloy:size 1 -1))
    (draw renderer :image
          :x (alloy:x point)
          :y (- (+ (alloy:y point) (alloy:h size)))
          :width (alloy:w size)
          :height (alloy:h size)
          :xlink-href (simple:data image))))

(defmethod simple:clear ((renderer renderer) extent)
  ;; DUMB
  (draw renderer :rect
        :x (alloy:x extent)
        :y (alloy:y extent)
        :width (alloy:w extent)
        :height (alloy:h extent)
        :fill "white"))


(defmethod simple:request-font ((renderer renderer) (font simple:font))
  font)

(defun to-uri (mime-type octets)
  (with-output-to-string (stream)
    (format stream "data:~a;base64," mime-type)
    (base64:usb8-array-to-base64-stream octets stream)))

(defmethod simple:request-image ((renderer renderer) (image simple:image))
  (make-instance 'image :size (simple:size image)
                        :data (to-uri "image/raw" (simple:data image))))

(defmethod simple:request-image ((renderer renderer) (image pathname))
  (let ((mime (cond ((string-equal "png" (pathname-type image)) "image/png")
                    ((string-equal "gif" (pathname-type image)) "image/gif")
                    ((string-equal "jpg" (pathname-type image)) "image/jpeg")
                    ((string-equal "bmp" (pathname-type image)) "image/bmp"))))
    (with-open-file (stream image :direction :input
                                  :element-type '(unsigned-byte 8))
      (let ((vec (make-array (file-length stream) :element-type '(unsigned-byte 8))))
        (read-sequence vec stream)
        (make-instance 'image :size NIL
                              :data (to-uri mime vec))))))
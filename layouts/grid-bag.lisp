(in-package #:org.shirakumo.alloy)

;; This code could potentiall be replaced with the normal extent-calculations.
;; The problem with the normal extent calculations is that they come with an attached unit.

(defclass grid-extent ()
  ((grid-x :initarg :col :accessor col)
  (grid-y :initarg :row :accessor row)
  (grid-width :initarg :width :initform 0 :accessor width)
  (grid-height :initarg :height :initform 0 :accessor height)))

(defun make-grid-extent (col row &optional (width 1) (height 1))
  (make-instance 'grid-extent
                 :col col
                 :row row
                 :width width
                 :height height))

(defmethod grid-overlapping-p ((a grid-extent) (b grid-extent))
  (let* ((x1 (col a))
         (y1 (row a))
         (w1 (width a))
         (h1 (height a))
         (x2 (col b))
         (y2 (row b))
         (w2 (width b))
         (h2 (height b)))
  (and (< x1 (+ x2 w2))
       (< x2 (+ x1 w1))
       (< y1 (+ y2 h2))
       (< y2 (+ y1 h1)))))

(defclass grid-bag-layout (vector-container layout)
  ((element-extents :initform (make-hash-table :test 'eq) :accessor element-extents)
   (cell-margins :initarg :cell-margins :initform (margins 5) :accessor cell-margins)
   (row-sizes :initarg :row-sizes :initform (make-array 0 :adjustable T :fill-pointer T) :reader row-sizes)
   (col-sizes :initarg :col-sizes :initform (make-array 0 :adjustable T :fill-pointer T) :reader col-sizes)
   (aggr-heights :accessor aggr-heights)
   (aggr-widths :accessor aggr-widths)))

(defmethod initialize-instance :after ((layout grid-bag-layout) &key)
  (setf (aggr-widths layout) (aggregate-with-padding (col-sizes layout) 2 3))
  (setf (aggr-heights layout) (aggregate-with-padding (row-sizes layout) 2 3)))

;; useless, maybe, but in the end these methods don't hurt
(defmethod num-cols ((layout grid-bag-layout))
  (length (col-sizes layout)))

(defmethod num-rows ((layout grid-bag-layout))
  (length (row-sizes layout)))

(defun aggregate-with-padding (array pad1 pad2)
  (loop with result = (make-array (length array))
     with total = 0
     for x across array
     for i = 0 then (1+ i)
     do (setf (aref result i) (cons total (incf total x)))
       (incf total (+ pad1 pad2))
     finally (return result)))

;; might be a redundant function
(defmethod look-up-extent-size ((element layout-element) (layout grid-bag-layout))
  (let* ((rect (gethash element (element-extents layout)))
         (aggr-widths (aggr-widths layout))
         (aggr-heights (aggr-heights layout)))
    (px-extent (car (aref aggr-widths (col rect)))
               (car (aref aggr-heights (row rect)))
               (cdr (aref aggr-widths (+ (col rect) (width rect) -1)))
               (cdr (aref aggr-heights (+ (row rect) (height rect) -1))))))

;; eh
(defmethod grid-bag-debug ((layout grid-bag-layout))
  (loop for e across (elements layout)
     do (print e) (print (gethash e (element-extents layout)))))  

(defmethod enter :before ((element layout-element) (layout grid-bag-layout) &key col row (width 1) (height 1))
  (when (and row col) ;; we'll assume that row and col and width and height are inside the bounds
    (when (some (lambda (el)
                  (grid-overlapping-p
                   (gethash el (element-extents layout))
                   (make-grid-extent col row width height)))
                (elements layout))
      (error 'place-already-occupied
             :element element :place (list row col width height) :layout layout))))

(defmethod enter ((element layout-element) (layout grid-bag-layout) &key col row (width 1) (height 1))
  (call-next-method)
  (setf (gethash element (element-extents layout)) (make-grid-extent col row width height)))

(defmethod (setf row-sizes) ((value sequence) (layout grid-layout))
  (adjust-grid layout (length value) (length (col-sizes layout)))
  (adjust-array (row-sizes layout) (length value) :fill-pointer (length value))
  (map-into (row-sizes layout) #'coerce-grid-size value))

(defmethod (setf col-sizes) ((value sequence) (layout grid-layout))
  (adjust-grid layout (length (row-sizes layout)) (length value))
  (adjust-array (col-sizes layout) (length value) :fill-pointer (length value))
  (map-into (col-sizes layout) #'coerce-grid-size value))

(defmethod leave :after ((element layout-element) (layout grid-bag-layout))
  (remhash element (element-extents layout)))

(defmethod notice-bounds ((target layout-element) (layout grid-bag-layout))
  (loop for element across (elements layout)
     do (setf (bounds element)
              (look-up-extent-size element layout))))

(defmethod (setf bounds) :after (extent (layout grid-bag-layout))
    (loop for element across (elements layout)
     do (setf (bounds element)
             (look-up-extent-size element layout))))

(defmethod suggest-bounds (extent (layout grid-layout))
  (let* ((aggr-widths (aggr-widths layout))
         (aggr-heights (aggr-heights layout)))
    (px-extent
     0
     0
     (cdr (aref aggr-widths (1- (length aggr-widths))))
     (cdr (aref aggr-heights (1- (length aggr-heights)))))))
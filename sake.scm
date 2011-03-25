(use srfi-1)
(use posix)
(module sake (task update dirty? make-task dirty-filter)
  (import-for-syntax matchable)
  (import scheme chicken srfi-1 posix)
  (define-syntax (update-time! x ren comp)
    (match x
      ((_ cnd fname)
       `(cond (,cnd
	       (with-output-to-file (string-append "." ,fname ".sake")
		 (lambda ()
		   (write (current-seconds))))
	       #t)
	      (else
	       #f)))))
  (define (stale? fname)
    (or (not (file-exists? fname))
	(update-time! (not (file-exists? (string-append "." fname ".sake")))
		      fname)
	(update-time! (> (file-modification-time fname)
			 (with-input-from-file 
			     (string-append "." fname ".sake") read))
		      fname)))
  (define-record task dirty update)
  (define (dirty? tsk)
    (cond ((task? tsk)
	   (task-dirty tsk))
	  ((string? tsk)
	   (stale? tsk))))
  (define (update tsk)
    (cond ((task? tsk)
	   (if (dirty? tsk)
	       (force (task-update tsk))
	       #f))))
  (define (updates . tsks)
    (for-each update tsks))
  (define (dirty-filter . tsks)
    (if (null? tsks)
	#f
	(filter dirty? tsks)))
  (define-syntax (task x ren comp)
    (match x
	   ((_ deps . body)
	    `(let ((,(ren 'prereqs) (,(ren 'dirty-filter) ,@deps))) 
	       (,(ren 'make-task) (not (null? ,(ren 'prereqs)))
		(delay
		  (begin
		    (if ,(ren 'prereqs)
			(for-each ,(ren 'update) ,(ren 'prereqs)))
		    ,@body))))))))
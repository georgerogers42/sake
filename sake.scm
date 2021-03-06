(use srfi-1)
(use posix)
(use coops)
(use coops-primitive-objects)
(module sake (task update dirty? <task> dirty-filter)
  (import-for-syntax matchable)
  (import scheme chicken srfi-1 posix coops coops-primitive-objects)
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
  (define-generic (dirty? tsk)) 
  (define-class <task> () ((dirty accessor: dirty?) (update accessor: updater)))
  (define-method (dirty? (fname <string>))
    (or (not (file-exists? fname))
       (update-time! (not (file-exists? (string-append "." fname ".sake")))
		     fname)
       (update-time! (> (file-modification-time fname)
			(with-input-from-file 
			    (string-append "." fname ".sake") read))
		     fname)))
  (define-generic (update tsk))
  (define-method (update (tsk <task>))
    (if (dirty? tsk)
	(force (updater tsk))
	#f))
  (define-method (update (tsk <string>))
    (dirty? tsk))
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
	       (,(ren 'make) ,(ren '<task>) 
		'dirty (not (null? ,(ren 'prereqs)))
		'update (delay
			  (begin
			    (if ,(ren 'prereqs)
				(for-each ,(ren 'update) ,(ren 'prereqs)))
			    ,@body))))))))
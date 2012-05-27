
; To compile on Windows MSVC 32bit:
; Komandot i gambit för att kompilera denhär filen: (compile-file "gurobiffi.scm" cc-options: "/ERRORREPORT:PROMPT  -I c:\\gurobi451\\win32\\include" ld-options-prelude: "\\gurobi451\\win32\\lib\\gurobi45.lib \\gurobi451\\win32\\lib\\gurobi_c++mtd2010.lib")
; (load "gurobiffi.oX")

(declare (not interrupts-enabled))

(c-declare #<<c-declare-end

// #pragma comment(lib,"gurobi45.lib")
// #pragma comment(lib,"gurobi_c++mtd2010.lib")
#include <stdio.h>
// #include <float.h>
#include "gurobi_c.h"

// printf("Floating point values are %i bytes on this puter.\n",sizeof(double));

c-declare-end
           )
           

(define testa-c2 (c-lambda () void #<<KODEN
printf("C funkade!\n");
KODEN
                          ))

(c-declare #<<c-declare-end

___SCMOBJ release_grb_env_star(void* p) {
     GRBfreeenv((GRBenv*) p); // fprintf(stderr,"gurobiffi: release_grb_env_star: %i garbage collected.\n",(int) p);
     return ___FIX(___NO_ERR);
}

___SCMOBJ release_grb_model_star(void* p) {
     GRBfreemodel((GRBmodel*) p); // fprintf(stderr,"gurobiffi: release_grb_model_star: %i garbage collected.\n",(int) p);
     return ___FIX(___NO_ERR);
}

c-declare-end
           )

; (c-define-type grb-env "GRBenv")
(c-define-type grb-env*   (nonnull-pointer "GRBenv"   grb-env*   "release_grb_env_star"  ))
(c-define-type grb-model* (nonnull-pointer "GRBmodel" grb-model* "release_grb_model_star"))

; Import constants:
(define grb-less-equal    ((c-lambda () char "___result = GRB_LESS_EQUAL;"   )))
(define grb-greater-equal ((c-lambda () char "___result = GRB_GREATER_EQUAL;")))
(define grb-equal         ((c-lambda () char "___result = GRB_EQUAL;")))

(define grb-continuous ((c-lambda () char "___result = GRB_CONTINUOUS;")))
(define grb-binary     ((c-lambda () char "___result = GRB_BINARY;")))
(define grb-integer    ((c-lambda () char "___result = GRB_INTEGER;")))
(define grb-semicont   ((c-lambda () char "___result = GRB_SEMICONT;")))
(define grb-semiint    ((c-lambda () char "___result = GRB_SEMIINT;")))

(define grb-loaded          ((c-lambda () int "___result = GRB_LOADED;")))
(define grb-optimal         ((c-lambda () int "___result = GRB_OPTIMAL;")))
(define grb-infeasible      ((c-lambda () int "___result = GRB_INFEASIBLE;")))
(define grb-inf-or-unbd     ((c-lambda () int "___result = GRB_INF_OR_UNBD;")))
(define grb-unbounded       ((c-lambda () int "___result = GRB_UNBOUNDED;")))
(define grb-cutoff          ((c-lambda () int "___result = GRB_CUTOFF;")))
(define grb-iteration-limit ((c-lambda () int "___result = GRB_ITERATION_LIMIT;")))
(define grb-node-limit      ((c-lambda () int "___result = GRB_NODE_LIMIT;"))) 
(define grb-time-limit      ((c-lambda () int "___result = GRB_TIME_LIMIT;"))) 
(define grb-solution-limit  ((c-lambda () int "___result = GRB_SOLUTION_LIMIT;"))) 
(define grb-interrupted     ((c-lambda () int "___result = GRB_INTERRUPTED;"))) 
(define grb-numeric         ((c-lambda () int "___result = GRB_NUMERIC;"))) 
(define grb-suboptimal      ((c-lambda () int "___result = GRB_SUBOPTIMAL;"))) 

(define grb-optimize-status-codes (list->table `((,grb-loaded . loaded)
                                                 (,grb-optimal . optimal)
                                                 (,grb-infeasible . infeasible)
                                                 (,grb-inf-or-unbd . inf-or-unbd)
                                                 (,grb-unbounded . unbounded)
                                                 (,grb-cutoff . cutoff)
                                                 (,grb-iteration-limit . iteration-limit)
                                                 (,grb-node-limit . node-limit)
                                                 (,grb-time-limit . time-limit)
                                                 (,grb-solution-limit . solution-limit)
                                                 (,grb-interrupted . interrupted)
                                                 (,grb-numeric . numeric)
                                                 (,grb-suboptimal . suboptimal))
                                               test: eq?))

(define (import-grb-optimize-status-codes v) (table-ref grb-optimize-status-codes v))

(define grb-load-env (c-lambda (char-string) grb-env* #<<c-declare-end
GRBenv* envP;
const char* logfilename = ___arg1;
int r = GRBloadenv(&envP,logfilename);
if (r == 0) ___result_voidstar = envP; else ___result_voidstar = 0;
c-declare-end
))

(define grb-env (grb-load-env #f))

(define f64vectorref   (c-lambda (scheme-object int) double "double* d = &___F64VECTORREF(___arg1,0); ___result = d[___arg2];"))
; obsolete: (define f64vectorref+1/2 (c-lambda (scheme-object) double "double* d = &___F64VECTORREF(___arg1,1); ___result = *d;"))
; obsolete: (define f64vectorref+1/3 (c-lambda (scheme-object) double "double d = ___F64VECTORREF(___arg1,1); ___result = d;"))

; (define model (grb-load-model grb-env "example" 3 2 -1 0. '#f64(1. 1. 2.) (list->string (list grb-less-equal grb-greater-equal))
;                               '#f64(4. 1.) '#s32(0 2 4) '#s32(2 2 1) '#s32(0 1 0 1 0) '#f64(1. 1. 2. 1. 3.)
;                               #f #f #f #f (list->string (list grb-binary grb-binary grb-binary)) '() '()))

(define grb-load-model (c-lambda (grb-env* nonnull-char-string int int int double
                                  scheme-object nonnull-char-string scheme-object scheme-object scheme-object scheme-object
                                  scheme-object
                                  bool scheme-object ; = lb-enabler lb-content
                                  bool scheme-object ; = ub-enabler ub-content
                                  nonnull-char-string ; = vtype
                                  bool nonnull-char-string-list ; = varnames-enabler varnames-content
                                  bool nonnull-char-string-list ; = constrnames-enabler constrnames-content
                                  )
                                 grb-model*
                                 #<<c-declare-end
// printf("Into GRBloadmodel. scheme-object args are: %p %p %p %p %p %p %b %p %b %p\n",___arg7,___arg9,___arg10,___arg11,___arg12,___arg13,___arg14,___arg15,___arg16,___arg17);
{
GRBenv* env = ___arg1;
GRBmodel *modelP;
char* Pname = ___arg2;
double* obj = &___F64VECTORREF(___arg7,0);
char* sense = ___arg8;
double* rhs = &___F64VECTORREF(___arg9,0);
int numvars = ___arg3; int numconsrs = ___arg4; int objsense = ___arg5; int objcon = ___arg6;
int* vbeg = ___CAST(int*,&___FETCH_S32(___BODY(___arg10),___INT(0)));
int* vlen = ___CAST(int*,&___FETCH_S32(___BODY(___arg11),___INT(0)));
int* vind = ___CAST(int*,&___FETCH_S32(___BODY(___arg12),___INT(0)));

double* vval = &___F64VECTORREF(___arg13,0); // ___CAST(double*,___FETCH_U8(___BODY(___arg13),___INT(0)));
// lb sätts såhär: Ifall argument 14 är #f, så används INGEN lb. Ifall argument inte är 14 (så t.ex. #t),
// så förväntas argument 15 vara en lista av strängar (dvs '("a" "b" "c") etc. ), och tas i användning.
double* lb   = ___arg14 ? &___F64VECTORREF(___arg15,0) : NULL; // ___CAST(double*,___FETCH_U8(___BODY(___arg15),___INT(0))) : NULL;
double* ub   = ___arg16 ? &___F64VECTORREF(___arg17,0) : NULL; // ___CAST(double*,___FETCH_U8(___BODY(___arg17),___INT(0))) : NULL;
char* vtype = ___arg18;
char** varnames = ___arg19 ? ___arg20 : NULL;
char** constrnames = ___arg21 ? ___arg22 : NULL;
{
// printf("Varnames: First is %s second is %s.\n",varnames[0],varnames[1]);
// double testval = 1.23; if(___arg1&&___arg3) {testval += 0.2;}
// printf("GRBloadmodel pointers are: %p %p %p %p %p %p %p %p\n",obj,rhs,vbeg,vlen,vind,vval,lb,ub);

// printf("GRBloadmodel is invoked with arguments: %p %p %s %i %i %I %i %p %s %p %p %p %p %p %p %p %s %p %p\n",
//        env,&modelP,Pname,numvars,numconsrs,objsense,objcon,obj,sense,rhs,vbeg,vlen,vind,vval,lb,ub,vtype,varnames,constrnames);

// printf("testval %e\n",testval); testval -= 0.01; printf("testval %f\n",testval);
// printf("obj els are: %i %i %i %i %i %i %i %i\n",obj[0],obj[1],rhs[0],rhs[1],vbeg[0],vbeg[1],vval[0],vval[1]);
// printf("picked directly obj els are: %i %i %i %i %i %i\n",___F64VECTORREF(___arg7,0),___F64VECTORREF(___arg7,1),
//        ___F64VECTORREF(___arg9,0),___F64VECTORREF(___arg9,1),
//        ___F64VECTORREF(___arg13,0),___F64VECTORREF(___arg13,1));
// printf("vbeg vlen vind has: %i %i %i %i %i %i %i %i %i\n",vbeg[0],vbeg[1],vbeg[2],vlen[0],vlen[1],vlen[2],vind[0],vind[1],vind[2]);
{
int r = GRBloadmodel(env, // env
                     &modelP, // modeIP
                     Pname, // Pname
                     numvars,numconsrs,objsense,objcon, // numvars numconsrs objsense objcon
                     obj, // obj
                     sense, // sense
                     rhs, // rhs
                     vbeg, vlen, vind, // vbeg vlen vind
                     vval, lb, ub, // vval lb ub
                     vtype, varnames, constrnames); // vtype varnames constnames
// printf("GRBloadmodel returned! r: %i\n",r);
if (r == 0)
    ___result_voidstar = modelP;
else {
     ___result_voidstar = 0;
     printf("GRBloadmodel error: %s\n",GRBgeterrormsg(___arg1));
}
}}}
c-declare-end
))

(define grb-optimize (c-lambda (grb-env* grb-model*) bool #<<c-declare-end
GRBenv* env = ___arg1;
GRBmodel* model = ___arg2;
int r = GRBoptimize(model);
___result = r == 0;
if (r != 0) printf("GRBloadmodel error: %s\n",GRBgeterrormsg(env));
c-declare-end
))

(define grb-get-int-attr (c-lambda (grb-env* grb-model* nonnull-char-string scheme-object) bool #<<c-declare-end
GRBenv* env = ___arg1;
GRBmodel* model = ___arg2;
char* name = ___arg3;
int* i = ___CAST(int*,&___FETCH_S32(___BODY(___arg4),___INT(0)));
int r = GRBgetintattr(model,name,i);
if (r != 0) printf("GRBloadmodel error: %s\n",GRBgeterrormsg(env));
___result = r == 0;
c-declare-end
 ))

(define grb-get-int-attr*
  (let ((r-container (make-s32vector 1)))
    (lambda (env model param-name)
      (and (grb-get-int-attr env model param-name r-container) (s32vector-ref r-container 0)))))

(define (grb-model-status env model) (import-grb-optimize-status-codes (grb-get-int-attr* env model "Status")))

(define grb-get-dbl-attr (c-lambda (grb-env* grb-model* nonnull-char-string scheme-object) bool #<<c-declare-end
GRBenv* env = ___arg1;
GRBmodel* model = ___arg2;
char* name = ___arg3;
double* d = &___F64VECTORREF(___arg4,0);
int r = GRBgetdblattr(model,name,d);
if (r != 0) printf("GRBloadmodel error: %s\n",GRBgeterrormsg(env));
___result = r == 0;
c-declare-end
 ))

(define grb-get-dbl-attr*
  (let ((r-container (make-f64vector 1)))
    (lambda (env model param-name)
      (and (grb-get-dbl-attr env model param-name r-container) (f64vector-ref r-container 0)))))

(define grb-get-dbl-attr-element (c-lambda (grb-env* grb-model* nonnull-char-string int scheme-object) bool #<<c-declare-end
GRBenv* env = ___arg1;
GRBmodel* model = ___arg2;
char* name = ___arg3;
int index = ___arg4;
double* d = &___F64VECTORREF(___arg5,0);
int r = GRBgetdblattrelement(model,name,index,d);
if (r != 0) printf("GRBloadmodel error: %s\n",GRBgeterrormsg(env));
___result = r == 0;
c-declare-end
 ))

(define grb-get-dbl-attr-element*
  (let ((r-container (make-f64vector 1)))
    (lambda (env model param-name index)
      (and (grb-get-dbl-attr-element env model param-name index r-container) (f64vector-ref r-container 0)))))

(define grb-get-str-attr-element (c-lambda (grb-env* grb-model* nonnull-char-string int) nonnull-char-string #<<c-declare-end
GRBenv* env = ___arg1;
GRBmodel* model = ___arg2;
char* name = ___arg3;
int index = ___arg4;
char* s = NULL;
int r = GRBgetstrattrelement(model,name,index,&s);
if (r != 0) printf("GRBloadmodel error: %s\n",GRBgeterrormsg(env));
___result = r == 0 ? s : NULL;
c-declare-end
 ))

(define grb-get-dbl-param-info (c-lambda (grb-env* nonnull-char-string scheme-object) bool #<<c-declare-end
GRBenv* env = ___arg1;
char* s = ___arg2;
double* rvalues = &___F64VECTORREF(___arg3,0);
int r = GRBgetdblparaminfo(env,s,&rvalues[0],&rvalues[1],&rvalues[2],&rvalues[3]);
___result = r == 0;
if (r != 0) printf("GRBloadmodel error: %s\n",GRBgeterrormsg(___arg1));
c-declare-end
))

(define (grb-get-dbl-param-info* env param-name)
  (let ((v (make-f64vector 4)))
    (and (grb-get-dbl-param-info grb-env param-name v) v)))


(define grb-set-method (c-lambda (grb-env* int) bool #<<c-declare-end
GRBenv* env = ___arg1;
int i = ___arg2;
int r =  GRBsetintparam(env, "Method", i);
___result = r == 0;
if (r != 0) printf("GRBloadmodel error: %s\n", GRBgeterrormsg(___arg1));
c-declare-end
))


(define grb-set-number-of-threds (c-lambda (grb-env* int) bool #<<c-declare-end
GRBenv* env = ___arg1;
int i = ___arg2;
int r =  GRBsetintparam(env, "Threads", i);
___result = r == 0;
if (r != 0) printf("GRBloadmodel error: %s\n", GRBgeterrormsg(___arg1));
c-declare-end
))



                                 
                                 
                                 
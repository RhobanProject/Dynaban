/* stdio.h contains printf declaration */
#include <stdio.h>
/* stdlib.h contains malloc declaration */
#include <stdlib.h>
/* math.h contains cos declaration */
/* do not forget to link with -lm */
#include <math.h>
  typedef struct {
    int nb_cels;
    int nb_coeffs;
    int nb_states;
    double *coeffs;
    double *states;
  }s_real_filter_Fz;
  typedef s_real_filter_Fz *p_real_filter_Fz ;
  double one_step_real_filter_Fz(double en,p_real_filter_Fz f) {
    int i;
    double *ci=f->coeffs;
    double *xi=f->states;
    double sn;
    for (i=f->nb_cels;i>0;i--) {
      en+=  *(ci++)*(*xi);  /* en=en-a2.xn_2*/
      sn=   *(ci++)*(*xi);  /* sn=b2.xn_2*/
      *(xi)=*(xi+1);        /* xn_2=xn_1*/
      xi++;                 /* xi is now xn_1*/
      en+=  *(ci++)*(*xi) ; /* en=en-a1.xn_1*/
      sn+=   *(ci++)*(*xi); /* sn=sn+b1.xn_1*/
      *(xi++)=en;           /* xn_1=en */
      en*=   *(ci++)   ;    /* en=b0.en*/
      en+=   sn        ;    /* en=sn+en*/
    }/*for (i=f->nb_cels;i>0;i--) */
    return en; 
  } /*double one_step_real_filter_Fz(...)*/
  p_real_filter_Fz get_memory_real_filter_Fz(int nb_cels,int nb_coeffs_by_cel,int nb_states_by_cel) {
    p_real_filter_Fz f=malloc(sizeof(s_real_filter_Fz));/* get memory for filter structure*/
    f->nb_cels=nb_cels;
    f->nb_coeffs=nb_coeffs_by_cel * nb_cels;
    f->nb_states=nb_states_by_cel*  nb_cels;
  /* get memory for  coeffs and  states */
    f->coeffs=malloc(f->nb_coeffs * sizeof(double));
    f->states=malloc(f->nb_states * sizeof(double));
    return(f);
  } /* p_real_filter_Fz new_real_filter_Fz(int nb_cels,int nb_coeffs_by_cel,int nb_states_by_cel)*/
  void destroy_real_filter_Fz(p_real_filter_Fz f) {
    if (f->nb_coeffs >0) { 
      free((void *)f->coeffs); /* release memory for coeffs */
    } /* if (f->nb_coeffs >0) */ 
    if (f->nb_states >0) { 
      free((void *)f->states); /* release memory for states */
    } /* if (f->nb_states >0) */ 
    free((void *)f);         /* release memory of f */
  } /* void destroy_real_filter_Fz(p_real_filter_Fz f) */
  p_real_filter_Fz new_real_filter_Fz() {
  /* 3 cels, 5 coeffs:-a2,b2,-a1,b1,b0,  2 states xn_2,xn_1*/
    p_real_filter_Fz f =get_memory_real_filter_Fz(3,5,2);
    double *coeffs=f->coeffs;
    double *states=f->states;
    *(coeffs++)=-0.99859529864408436; /* coeffs -a2[1] */
    *(coeffs++)=0.21563311581083344; /* coeffs +b2[1] */
    *(coeffs++)=1.99779569141942637; /* coeffs -a1[1] */
    *(coeffs++)=-0.42973007584848266; /* coeffs +b1[1] */
    *(coeffs++)=0.21563311581083344; /* coeffs +b0[1] */
    *(states++)=0;/* xn_2[1]=0 */
    *(states++)=0;/* xn_1[1]=0 */
    *(coeffs++)=-0.99308247554443407; /* coeffs -a2[2] */
    *(coeffs++)=0.21473884083803649; /* coeffs +b2[2] */
    *(coeffs++)=1.99245998959594117; /* coeffs -a1[2] */
    *(coeffs++)=-0.42918138203500955; /* coeffs +b1[2] */
    *(coeffs++)=0.21473884083803649; /* coeffs +b0[2] */
    *(states++)=0;/* xn_2[2]=0 */
    *(states++)=0;/* xn_1[2]=0 */
    *(coeffs++)=-0.98181969672164837; /* coeffs -a2[3] */
    *(coeffs++)=0.21352667628800515; /* coeffs +b2[3] */
    *(coeffs++)=1.98160309303960180; /* coeffs -a1[3] */
    *(coeffs++)=-0.42684017170932087; /* coeffs +b1[3] */
    *(coeffs++)=0.21352667628800515; /* coeffs +b0[3] */
    *(states++)=0;/* xn_2[3]=0 */
    *(states++)=0;/* xn_1[3]=0 */
    return f;
  }/* p_real_filter_Fz new_real_filter_Fz() */
 void teste_real_Fz(void) {
    long int n=0,NB_ECHS=10; /* YOU CAN CHANGE THIS  */
    double amp_en=1 ;  /* amplitude of input */
    double f_ech=100 ; /* sampling frequency hz */
    double f_reelle=2 ; /* real frequency hz */
    double freq_en=0.1 ; /* f/fe */
    double en ; 
    const double PI=3.141592653589793115998 ; 
    double phi_n=0 ; 
    double sn ;
    p_real_filter_Fz f_real_Fz=new_real_filter_Fz();
    for (n=0;n<NB_ECHS;n++) {
      en=amp_en*cos(phi_n);
      sn =  one_step_real_filter_Fz(en,f_real_Fz) ;
      phi_n+=2*PI*freq_en;
      if (phi_n>2*PI) {
        phi_n-=2*PI;
      }
    } /*for (n=0;n<NB_ECHS;n++) */
    destroy_real_filter_Fz(f_real_Fz) ;
  } /* void teste_real_Fz(void)  */

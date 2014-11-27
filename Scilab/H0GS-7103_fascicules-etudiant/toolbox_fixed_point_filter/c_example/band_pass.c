/* stdio may be useful if you use printf */
#include <stdio.h>
/* stdlib is needed for malloc declaration */
#include <stdlib.h>
# define int_16_band_pass short int
# define int_32_band_pass long int
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
  }s_real_filter_band_pass;
  typedef s_real_filter_band_pass *p_real_filter_band_pass ;
  double one_step_real_filter_band_pass(double en,p_real_filter_band_pass f) {
    int i;
    double *ci=f->coeffs;
    double *xi=f->states;
    double sn,vn;
    sn=0;
    for (i=f->nb_cels;i>0;i--) {
      vn=  en;  /* vn=en*/
      vn+=  *(ci++)*(*xi);  /* vn=vn-a2.xn_2*/
      sn+=  *(ci++)*(*xi);  /* sn=sn+b2.xn_2*/
      *(xi)=*(xi+1);        /* xn_2=xn_1*/
      xi++;                 /* xi is now xn_1*/
      vn+=  *(ci++)*(*xi) ; /* vn=vn-a1.xn_1*/
      sn+=   *(ci++)*(*xi); /* sn=sn+b1.xn_1*/
      *(xi++)=vn;           /* xn_1=vn */
      sn+=   *(ci++)*vn   ;    /* sn=sn+b0.vn*/
    }/*for (i=f->nb_cels;i>0;i--) */
    return sn;
  } /*double one_step_real_filter_band_pass(...)*/
  p_real_filter_band_pass get_memory_real_filter_band_pass(int nb_cels,int nb_coeffs_by_cel,int nb_states_by_cel) {
    p_real_filter_band_pass f=malloc(sizeof(s_real_filter_band_pass));/* get memory for filter structure*/
    f->nb_cels=nb_cels;
    f->nb_coeffs=nb_coeffs_by_cel * nb_cels;
    f->nb_states=nb_states_by_cel*  nb_cels;
  /* get memory for  coeffs and  states */
    f->coeffs=malloc(f->nb_coeffs * sizeof(double));
    f->states=malloc(f->nb_states * sizeof(double));
    return(f);
  } /* p_real_filter_band_pass new_real_filter_band_pass(int nb_cels,int nb_coeffs_by_cel,int nb_states_by_cel)*/
  void destroy_real_filter_band_pass(p_real_filter_band_pass f) {
    if (f->nb_coeffs >0) {
      free((void *)f->coeffs); /* release memory for coeffs */
    } /* if (f->nb_coeffs >0) */
    if (f->nb_states >0) {
      free((void *)f->states); /* release memory for states */
    } /* if (f->nb_states >0) */
    free((void *)f);         /* release memory of f */
  } /* void destroy_real_filter_band_pass(p_real_filter_band_pass f) */
  /* stdio may be useful if you use printf */
  #include <stdio.h>
  /* stdlib is needed for malloc declaration */
  #include <stdlib.h>
  const int_16_band_pass coeffs_16bits_band_pass[31]={
       0 /* no init of cel 1 wich has zero gain*/
       ,14058 /*  cel +2:  -a1.2^13 */
       ,-18837 /*  cel +2:  -a2.2^13 */
       ,22797 /*  cel +2:  b1.2^18, note that b0=0 */
       ,-8059 /*  cel +2:  b2.2^18 */
       ,30623 /*  cel +3:  -a1.2^14 */
       ,-30589 /*  cel +3:  -a2.2^14 */
       ,15337 /*  cel +3:  b1.2^18, note that b0=0 */
       ,-26497 /*  cel +3:  b2.2^18 */
       ,26666 /*  cel +4:  -a1.2^14 */
       ,-30649 /*  cel +4:  -a2.2^14 */
       ,-24271 /*  cel +4:  b1.2^17, note that b0=0 */
       ,-3800 /*  cel +4:  b2.2^17 */
       ,27888 /*  cel +5:  -a1.2^14 */
       ,-32083 /*  cel +5:  -a2.2^14 */
       ,-7001 /*  cel +5:  b1.2^16, note that b0=0 */
       ,22379 /*  cel +5:  b2.2^16 */
       ,27007 /*  cel +6:  -a1.2^14 */
       ,-23817 /*  cel +6:  -a2.2^14 */
       ,17195 /*  cel +6:  b1.2^17, note that b0=0 */
       ,17713 /*  cel +6:  b2.2^17 */
       ,12210 /*  cel +7:  -a1.2^13 */
       ,-19800 /*  cel +7:  -a2.2^13 */
       ,-578 /*  cel +7:  b1.2^15, note that b0=0 */
       ,-20765 /*  cel +7:  b2.2^15 */
  };
    typedef struct {
      int nb_coeffs;
      int nb_states;
      int_16_band_pass *coeffs;
      int_32_band_pass *states;
    }s_16bits_filter_band_pass;
    typedef s_16bits_filter_band_pass *p_16bits_filter_band_pass;
  /* creator of structure p_16bits_filter_band_pass */
    p_16bits_filter_band_pass new_16bits_filter_band_pass() {
      p_16bits_filter_band_pass p_band_pass;
      p_band_pass = (s_16bits_filter_band_pass *) malloc(sizeof(s_16bits_filter_band_pass));
      int_32_band_pass *states;
      int is;
      p_band_pass->nb_coeffs=31;
      p_band_pass->nb_states=12;
      p_band_pass->coeffs=(int_16_band_pass *)&(coeffs_16bits_band_pass[0]);
      states =(int_32_band_pass *) malloc(12 * sizeof(int_32_band_pass));
      p_band_pass->states = states;
      for (is=0;is<12;is++) {
        *(states++)=0;
      }
      return p_band_pass;
    } /* p_16bits_filter_band_pass new_16bits_filter_band_pass()  */
  /* destructor of structure p_16bits_filter_band_pass */
    void  destroy_16bits_filter_band_pass(p_16bits_filter_band_pass p_band_pass) {
      free((void *) (p_band_pass->states) ); /* release memory allocated for states */
      free((void *)p_band_pass) ;/* release memory allocated for structure */
    } /* void destroy_16bits_filter_band_pass(p_16bits_filter_band_pass p_band_pass) */
  int_32_band_pass one_step_16bits_filter_band_pass(int_16_band_pass en_16 , p_16bits_filter_band_pass p_band_pass) {
    int_16_band_pass *coeffs;
    int_32_band_pass *states;
    coeffs=p_band_pass->coeffs;
    states=p_band_pass->states;
    int_16_band_pass vn_16;
    int_16_band_pass x1_16;
    int_16_band_pass x2_16;
    int_32_band_pass en_32;
    int_32_band_pass sn_32;
    sn_32=0;
    /* no accumulation because cel 1 has zero gain */
    /* code of cel 2 */
    en_32= (int_32_band_pass)en_16;
    en_32=en_32<<8; /* en<-en<<L+LA ,L=-5,LA=13*/
    x1_16=(int_16_band_pass)((* states )>>3); /* init x1 */
    x2_16=(int_16_band_pass)((* (states+1))>>3); /* init x2 */
    en_32+=14058*x1_16; /* en<-en - a1 . x1 */
    en_32+=-18837*x2_16; /* en<-en - a2 . x2 */
    vn_16=(int_16_band_pass)(en_32>>13); /* vn<-en >> LA */
    en_32=22797*x1_16; /* en<-b1 . x1 ,because b0=0 */
    en_32+=-8059*x2_16; /* en<-en +b2 . x2  */
    (*states)+= vn_16; /* x1<-old_x1+vn  */
    (*states)-= x1_16; /* x1<-x1-[old_x1.2^-3] */
    states++;
    (*states)+= x1_16; /* x2<-x2+old_x1  */
    (*states)-= x2_16; /* x2<-x2-[old_x2.2^-3] */
    states++;
    en_32=en_32>>1; /* scale output of cel 2*/
    sn_32+=en_32;
    /* code of cel 3 */
    en_32= (int_32_band_pass)en_16;
    en_32=en_32<<8; /* en<-en<<L+LA ,L=-6,LA=14*/
    x1_16=(int_16_band_pass)((* states )>>4); /* init x1 */
    x2_16=(int_16_band_pass)((* (states+1))>>4); /* init x2 */
    en_32+=30623*x1_16; /* en<-en - a1 . x1 */
    en_32+=-30589*x2_16; /* en<-en - a2 . x2 */
    vn_16=(int_16_band_pass)(en_32>>14); /* vn<-en >> LA */
    en_32=15337*x1_16; /* en<-b1 . x1 ,because b0=0 */
    en_32+=-26497*x2_16; /* en<-en +b2 . x2  */
    (*states)+= vn_16; /* x1<-old_x1+vn  */
    (*states)-= x1_16; /* x1<-x1-[old_x1.2^-4] */
    states++;
    (*states)+= x1_16; /* x2<-x2+old_x1  */
    (*states)-= x2_16; /* x2<-x2-[old_x2.2^-4] */
    states++;
     /* scale output of cel 3*/
    sn_32+=en_32;
    /* code of cel 4 */
    en_32= (int_32_band_pass)en_16;
    en_32=en_32<<10; /* en<-en<<L+LA ,L=-4,LA=14*/
    x1_16=(int_16_band_pass)((* states )>>3); /* init x1 */
    x2_16=(int_16_band_pass)((* (states+1))>>3); /* init x2 */
    en_32+=26666*x1_16; /* en<-en - a1 . x1 */
    en_32+=-30649*x2_16; /* en<-en - a2 . x2 */
    vn_16=(int_16_band_pass)(en_32>>14); /* vn<-en >> LA */
    en_32=-24271*x1_16; /* en<-b1 . x1 ,because b0=0 */
    en_32+=-3800*x2_16; /* en<-en +b2 . x2  */
    (*states)+= vn_16; /* x1<-old_x1+vn  */
    (*states)-= x1_16; /* x1<-x1-[old_x1.2^-3] */
    states++;
    (*states)+= x1_16; /* x2<-x2+old_x1  */
    (*states)-= x2_16; /* x2<-x2-[old_x2.2^-3] */
    states++;
    en_32=en_32>>1; /* scale output of cel 4*/
    sn_32+=en_32;
    /* code of cel 5 */
    en_32= (int_32_band_pass)en_16;
    en_32=en_32<<10; /* en<-en<<L+LA ,L=-4,LA=14*/
    x1_16=(int_16_band_pass)((* states )>>4); /* init x1 */
    x2_16=(int_16_band_pass)((* (states+1))>>4); /* init x2 */
    en_32+=27888*x1_16; /* en<-en - a1 . x1 */
    en_32+=-32083*x2_16; /* en<-en - a2 . x2 */
    vn_16=(int_16_band_pass)(en_32>>14); /* vn<-en >> LA */
    en_32=-7001*x1_16; /* en<-b1 . x1 ,because b0=0 */
    en_32+=22379*x2_16; /* en<-en +b2 . x2  */
    (*states)+= vn_16; /* x1<-old_x1+vn  */
    (*states)-= x1_16; /* x1<-x1-[old_x1.2^-4] */
    states++;
    (*states)+= x1_16; /* x2<-x2+old_x1  */
    (*states)-= x2_16; /* x2<-x2-[old_x2.2^-4] */
    states++;
     /* scale output of cel 5*/
    sn_32+=en_32;
    /* code of cel 6 */
    en_32= (int_32_band_pass)en_16;
    en_32=en_32<<10; /* en<-en<<L+LA ,L=-4,LA=14*/
    x1_16=(int_16_band_pass)((* states )>>3); /* init x1 */
    x2_16=(int_16_band_pass)((* (states+1))>>3); /* init x2 */
    en_32+=27007*x1_16; /* en<-en - a1 . x1 */
    en_32+=-23817*x2_16; /* en<-en - a2 . x2 */
    vn_16=(int_16_band_pass)(en_32>>14); /* vn<-en >> LA */
    en_32=17195*x1_16; /* en<-b1 . x1 ,because b0=0 */
    en_32+=17713*x2_16; /* en<-en +b2 . x2  */
    (*states)+= vn_16; /* x1<-old_x1+vn  */
    (*states)-= x1_16; /* x1<-x1-[old_x1.2^-3] */
    states++;
    (*states)+= x1_16; /* x2<-x2+old_x1  */
    (*states)-= x2_16; /* x2<-x2-[old_x2.2^-3] */
    states++;
    en_32=en_32>>1; /* scale output of cel 6*/
    sn_32+=en_32;
    /* code of cel 7 */
    en_32= (int_32_band_pass)en_16;
    en_32=en_32<<10; /* en<-en<<L+LA ,L=-3,LA=13*/
    x1_16=(int_16_band_pass)((* states )>>4); /* init x1 */
    x2_16=(int_16_band_pass)((* (states+1))>>4); /* init x2 */
    en_32+=12210*x1_16; /* en<-en - a1 . x1 */
    en_32+=-19800*x2_16; /* en<-en - a2 . x2 */
    vn_16=(int_16_band_pass)(en_32>>13); /* vn<-en >> LA */
    en_32=-578*x1_16; /* en<-b1 . x1 ,because b0=0 */
    en_32+=-20765*x2_16; /* en<-en +b2 . x2  */
    (*states)+= vn_16; /* x1<-old_x1+vn  */
    (*states)-= x1_16; /* x1<-x1-[old_x1.2^-4] */
    states++;
    (*states)+= x1_16; /* x2<-x2+old_x1  */
    (*states)-= x2_16; /* x2<-x2-[old_x2.2^-4] */
    states++;
     /* scale output of cel 7*/
    sn_32+=en_32;
    sn_32=sn_32>>12; /* scale global output */
    return  ( sn_32) ;
  } /* int_32_band_pass one_step_+16bits_filter_band_pass(..) */
  /* math.h is included only for cos and round function */
  #include <math.h>
   void teste_16bits_filter_band_pass(void) {
      long int n=0,NB_ECHS=10; /* YOU CAN CHANGE THIS  */
      double amp_en=32767 ;  /* amplitude of input */
      double f_ech=100 ; /* sampling frequency hz */
      double f_reelle=2 ; /* real frequency hz */
      double freq_en=f_reelle/f_ech ; /* freelle/fe */
      double en ;
      const double PI=3.141592653589793115998 ;
      int_16_band_pass en_16 ;
      double phi_n=0 ;
      double sn ;
      p_16bits_filter_band_pass p_band_pass=new_16bits_filter_band_pass();
      for (n=0;n<NB_ECHS;n++) {
        en=amp_en*cos(phi_n);
        en_16=(int_16_band_pass) floor(en+0.5);
        sn =  (double)one_step_16bits_filter_band_pass(en_16 , p_band_pass) ;
        phi_n+=2*PI*freq_en;
        if (phi_n>2*PI) {
          phi_n-=2*PI;
        }
      } /*for (n=0;n<NB_ECHS;n++) */
      destroy_16bits_filter_band_pass(p_band_pass) ;
    } /* void teste_16bits_filter_band_pass(void)  */
  p_real_filter_band_pass new_real_filter_band_pass() {
  /* 7 cels, 5 coeffs:-a2,b2,-a1,b1,b0,  2 states xn_2,xn_1*/
    p_real_filter_band_pass f =get_memory_real_filter_band_pass(7,5,2);
    double *coeffs=f->coeffs;
    double *states=f->states;
    *(coeffs++)=-0; /* coeffs -a2[1] */
    *(coeffs++)=0; /* coeffs +b2[1] */
    *(coeffs++)=-0; /* coeffs -a1[1] */
    *(coeffs++)=0; /* coeffs +b1[1] */
    *(coeffs++)=0.00000000098510815; /* coeffs +b0[1] */
    *(states++)=0;/* xn_2[1]=0 */
    *(states++)=0;/* xn_1[1]=0 */
    *(coeffs++)=-0.98924933250095237; /* coeffs -a2[2] */
    *(coeffs++)=-0.00999190732335517; /* coeffs +b2[2] */
    *(coeffs++)=1.96450892851677938; /* coeffs -a1[2] */
    *(coeffs++)=0.01087037088098343; /* coeffs +b1[2] */
    *(coeffs++)=0; /* coeffs +b0[2] */
    *(states++)=0;/* xn_2[2]=0 */
    *(states++)=0;/* xn_1[2]=0 */
    *(coeffs++)=-0.99571441993691800; /* coeffs -a2[3] */
    *(coeffs++)=-0.00382290485596447; /* coeffs +b2[3] */
    *(coeffs++)=1.9918162458590127; /* coeffs -a1[3] */
    *(coeffs++)=0.00365661054699984; /* coeffs +b1[3] */
    *(coeffs++)=0; /* coeffs +b0[3] */
    *(states++)=0;/* xn_2[3]=0 */
    *(states++)=0;/* xn_1[3]=0 */
    *(coeffs++)=-0.97286871859228263; /* coeffs -a2[4] */
    *(coeffs++)=0.01980010442430383; /* coeffs +b2[4] */
    *(coeffs++)=1.9534457331780497; /* coeffs -a1[4] */
    *(coeffs++)=-0.02314638721028456; /* coeffs +b1[4] */
    *(coeffs++)=0; /* coeffs +b0[4] */
    *(states++)=0;/* xn_2[4]=0 */
    *(states++)=0;/* xn_1[4]=0 */
    *(coeffs++)=-0.98629220249986504; /* coeffs -a2[5] */
    *(coeffs++)=0.00759285530417400; /* coeffs +b2[5] */
    *(coeffs++)=1.98138584277524576; /* coeffs -a1[5] */
    *(coeffs++)=-0.00667625343194312; /* coeffs +b1[5] */
    *(coeffs++)=0; /* coeffs +b0[5] */
    *(states++)=0;/* xn_2[5]=0 */
    *(states++)=0;/* xn_1[5]=0 */
    *(coeffs++)=-0.96863111008981606; /* coeffs -a2[6] */
    *(coeffs++)=-0.01223696817450352; /* coeffs +b2[6] */
    *(coeffs++)=1.95604865295546948; /* coeffs -a1[6] */
    *(coeffs++)=0.01639837527094073; /* coeffs +b1[6] */
    *(coeffs++)=0; /* coeffs +b0[6] */
    *(states++)=0;/* xn_2[6]=0 */
    *(states++)=0;/* xn_1[6]=0 */
    *(coeffs++)=-0.97568189282822648; /* coeffs -a2[7] */
    *(coeffs++)=-0.00144162710080037; /* coeffs +b2[7] */
    *(coeffs++)=1.96815680145166905; /* coeffs -a1[7] */
    *(coeffs++)=-0.00110270441728737; /* coeffs +b1[7] */
    *(coeffs++)=0; /* coeffs +b0[7] */
    *(states++)=0;/* xn_2[7]=0 */
    *(states++)=0;/* xn_1[7]=0 */
    return f;
  }/* p_real_filter_band_pass new_real_filter_band_pass() */
 void teste_real_band_pass(void) {
    long int n=0,NB_ECHS=10; /* YOU CAN CHANGE THIS  */
    double amp_en=1 ;  /* amplitude of input */
    double f_ech=100 ; /* sampling frequency hz */
    double f_reelle=2 ; /* real frequency hz */
    double freq_en=0.1 ; /* f/fe */
    double en ;
    const double PI=3.141592653589793115998 ;
    double phi_n=0 ;
    double sn ;
    p_real_filter_band_pass f_real_band_pass=new_real_filter_band_pass();
    for (n=0;n<NB_ECHS;n++) {
      en=amp_en*cos(phi_n);
      sn =  one_step_real_filter_band_pass(en,f_real_band_pass) ;
      phi_n+=2*PI*freq_en;
      if (phi_n>2*PI) {
        phi_n-=2*PI;
      }
    } /*for (n=0;n<NB_ECHS;n++) */
    destroy_real_filter_band_pass(f_real_band_pass) ;
  } /* void teste_real_band_pass(void)  */

/* stdio may be useful if you use printf */
#include <stdio.h>
/* stdlib is needed for malloc declaration */
#include <stdlib.h>
# define int_16_band_pass_alu short int
# define int_32_band_pass_alu long int
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
  }s_real_filter_band_pass_alu;
  typedef s_real_filter_band_pass_alu *p_real_filter_band_pass_alu ;
  double one_step_real_filter_band_pass_alu(double en,p_real_filter_band_pass_alu f) {
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
  } /*double one_step_real_filter_band_pass_alu(...)*/
  p_real_filter_band_pass_alu get_memory_real_filter_band_pass_alu(int nb_cels,int nb_coeffs_by_cel,int nb_states_by_cel) {
    p_real_filter_band_pass_alu f=malloc(sizeof(s_real_filter_band_pass_alu));/* get memory for filter structure*/
    f->nb_cels=nb_cels;
    f->nb_coeffs=nb_coeffs_by_cel * nb_cels;
    f->nb_states=nb_states_by_cel*  nb_cels;
  /* get memory for  coeffs and  states */
    f->coeffs=malloc(f->nb_coeffs * sizeof(double));
    f->states=malloc(f->nb_states * sizeof(double));
    return(f);
  } /* p_real_filter_band_pass_alu new_real_filter_band_pass_alu(int nb_cels,int nb_coeffs_by_cel,int nb_states_by_cel)*/
  void destroy_real_filter_band_pass_alu(p_real_filter_band_pass_alu f) {
    if (f->nb_coeffs >0) { 
      free((void *)f->coeffs); /* release memory for coeffs */
    } /* if (f->nb_coeffs >0) */ 
    if (f->nb_states >0) { 
      free((void *)f->states); /* release memory for states */
    } /* if (f->nb_states >0) */ 
    free((void *)f);         /* release memory of f */
  } /* void destroy_real_filter_band_pass_alu(p_real_filter_band_pass_alu f) */
  /* stdio may be useful if you use printf */
  #include <stdio.h>
  /* stdlib is needed for malloc declaration */
  #include <stdlib.h>
  const int_16_band_pass_alu coeffs_16bits_band_pass_alu[31]={
       18122 /* cel +1:  b0.2^23 */
       ,14875 /*  cel +2:  -a1.2^15 */
       ,-24468 /*  cel +2:  -a2.2^15 */
       ,-17693 /*  cel +2:  b1.2^16, note that b0=0 */
       ,-12304 /*  cel +2:  b2.2^16 */
       ,28233 /*  cel +3:  -a1.2^14 */
       ,-14503 /*  cel +3:  -a2.2^14 */
       ,21938 /*  cel +3:  b1.2^17, note that b0=0 */
       ,-15298 /*  cel +3:  b2.2^17 */
       ,16926 /*  cel +4:  -a1.2^15 */
       ,-13844 /*  cel +4:  -a2.2^15 */
       ,-19772 /*  cel +4:  b1.2^15, note that b0=0 */
       ,28624 /*  cel +4:  b2.2^15 */
       ,24470 /*  cel +5:  -a1.2^14 */
       ,-11014 /*  cel +5:  -a2.2^14 */
       ,-12152 /*  cel +5:  b1.2^15, note that b0=0 */
       ,16483 /*  cel +5:  b2.2^15 */
       ,24899 /*  cel +6:  -a1.2^15 */
       ,-9880 /*  cel +6:  -a2.2^15 */
       ,20389 /*  cel +6:  b1.2^13, note that b0=0 */
       ,-7985 /*  cel +6:  b2.2^13 */
       ,19404 /*  cel +7:  -a1.2^14 */
       ,-7350 /*  cel +7:  -a2.2^14 */
       ,-22918 /*  cel +7:  b1.2^14, note that b0=0 */
       ,6490 /*  cel +7:  b2.2^14 */
  };
    typedef struct {
      int nb_coeffs;
      int nb_states;
      int_16_band_pass_alu *coeffs;
      int_32_band_pass_alu *states;
    }s_16bits_filter_band_pass_alu;
    typedef s_16bits_filter_band_pass_alu *p_16bits_filter_band_pass_alu;
  /* creator of structure p_16bits_filter_band_pass_alu */
    p_16bits_filter_band_pass_alu new_16bits_filter_band_pass_alu() {
      p_16bits_filter_band_pass_alu p_band_pass_alu;
      p_band_pass_alu = (s_16bits_filter_band_pass_alu *) malloc(sizeof(s_16bits_filter_band_pass_alu));
      int_32_band_pass_alu *states;
      int is;
      p_band_pass_alu->nb_coeffs=31;
      p_band_pass_alu->nb_states=12;
      p_band_pass_alu->coeffs=(int_16_band_pass_alu *)&(coeffs_16bits_band_pass_alu[0]);
      states =(int_32_band_pass_alu *) malloc(12 * sizeof(int_32_band_pass_alu));
      p_band_pass_alu->states = states;
      for (is=0;is<12;is++) {
        *(states++)=0;
      }
      return p_band_pass_alu;
    } /* p_16bits_filter_band_pass_alu new_16bits_filter_band_pass_alu()  */
  /* destructor of structure p_16bits_filter_band_pass_alu */
    void  destroy_16bits_filter_band_pass_alu(p_16bits_filter_band_pass_alu p_band_pass_alu) {
      free((void *) (p_band_pass_alu->states) ); /* release memory allocated for states */
      free((void *)p_band_pass_alu) ;/* release memory allocated for structure */
    } /* void destroy_16bits_filter_band_pass_alu(p_16bits_filter_band_pass_alu p_band_pass_alu) */
  int_32_band_pass_alu one_step_16bits_filter_band_pass_alu(int_16_band_pass_alu en_16 , p_16bits_filter_band_pass_alu p_band_pass_alu) {
    int_16_band_pass_alu *coeffs;
    int_32_band_pass_alu *states;
    coeffs=p_band_pass_alu->coeffs;
    states=p_band_pass_alu->states;
    int_32_band_pass_alu tmp_32;
    int_16_band_pass_alu vn_16;
    int_16_band_pass_alu x1_16;
    int_16_band_pass_alu x2_16;
    int_32_band_pass_alu en_32;
    int_32_band_pass_alu sn_32;
    sn_32=0;
    /* code of cel 1 */
    en_32= (int_32_band_pass_alu)en_16;
    en_32=(int_32_band_pass_alu)(en_32); /* en<-en .2^0 */
    en_32=18122* ( (int_16_band_pass_alu) en_32); /* en<-b0 . en */
    en_32=en_32>>12; /* scale output of cel 1*/
    sn_32+=en_32;
    /* code of cel 2 */
    en_32= (int_32_band_pass_alu)en_16;
    en_32=en_32<<12; /* en<-en<<L+LA ,L=-3,LA=15*/
    x1_16= (int_16_band_pass_alu)(* states ); /* init x1 */
    x2_16= (int_16_band_pass_alu)(* (states+1)); /* init x2 */
    en_32+=14875*x1_16; /* en<-en - a1 . x1 */
    en_32+=-24468*x2_16; /* en<-en - a2 . x2 */
    tmp_32=en_32>>14; /* vn<-en >> LA */
    tmp_32+=1;
    vn_16=(int_16_band_pass_alu)(tmp_32>>1);
    en_32=-17693*x1_16; /* en<-b1 . x1 ,because b0=0 */
    en_32+=-12304*x2_16; /* en<-en +b2 . x2  */
    (*states)= (int_32_band_pass_alu)vn_16; /* x1=vn  */
    states++;
    (*states)= (int_32_band_pass_alu)x1_16; /* x2=x1  */
    states++;
    en_32=en_32>>2; /* scale output of cel 2*/
    sn_32+=en_32;
    /* code of cel 3 */
    en_32= (int_32_band_pass_alu)en_16;
    en_32=en_32<<9; /* en<-en<<L+LA ,L=-5,LA=14*/
    x1_16= (int_16_band_pass_alu)(* states ); /* init x1 */
    x2_16= (int_16_band_pass_alu)(* (states+1)); /* init x2 */
    en_32+=28233*x1_16; /* en<-en - a1 . x1 */
    en_32+=-14503*x2_16; /* en<-en - a2 . x2 */
    tmp_32=en_32>>13; /* vn<-en >> LA */
    tmp_32+=1;
    vn_16=(int_16_band_pass_alu)(tmp_32>>1);
    en_32=21938*x1_16; /* en<-b1 . x1 ,because b0=0 */
    en_32+=-15298*x2_16; /* en<-en +b2 . x2  */
    (*states)= (int_32_band_pass_alu)vn_16; /* x1=vn  */
    states++;
    (*states)= (int_32_band_pass_alu)x1_16; /* x2=x1  */
    states++;
    en_32=en_32>>1; /* scale output of cel 3*/
    sn_32+=en_32;
    /* code of cel 4 */
    en_32= (int_32_band_pass_alu)en_16;
    en_32=en_32<<13; /* en<-en<<L+LA ,L=-2,LA=15*/
    x1_16= (int_16_band_pass_alu)(* states ); /* init x1 */
    x2_16= (int_16_band_pass_alu)(* (states+1)); /* init x2 */
    en_32+=16926*x1_16; /* en<-en - a1 . x1 */
    en_32+=-13844*x2_16; /* en<-en - a2 . x2 */
    tmp_32=en_32>>14; /* vn<-en >> LA */
    tmp_32+=1;
    vn_16=(int_16_band_pass_alu)(tmp_32>>1);
    en_32=-19772*x1_16; /* en<-b1 . x1 ,because b0=0 */
    en_32+=28624*x2_16; /* en<-en +b2 . x2  */
    (*states)= (int_32_band_pass_alu)vn_16; /* x1=vn  */
    states++;
    (*states)= (int_32_band_pass_alu)x1_16; /* x2=x1  */
    states++;
    en_32=en_32>>2; /* scale output of cel 4*/
    sn_32+=en_32;
    /* code of cel 5 */
    en_32= (int_32_band_pass_alu)en_16;
    en_32=en_32<<10; /* en<-en<<L+LA ,L=-4,LA=14*/
    x1_16= (int_16_band_pass_alu)(* states ); /* init x1 */
    x2_16= (int_16_band_pass_alu)(* (states+1)); /* init x2 */
    en_32+=24470*x1_16; /* en<-en - a1 . x1 */
    en_32+=-11014*x2_16; /* en<-en - a2 . x2 */
    tmp_32=en_32>>13; /* vn<-en >> LA */
    tmp_32+=1;
    vn_16=(int_16_band_pass_alu)(tmp_32>>1);
    en_32=-12152*x1_16; /* en<-b1 . x1 ,because b0=0 */
    en_32+=16483*x2_16; /* en<-en +b2 . x2  */
    (*states)= (int_32_band_pass_alu)vn_16; /* x1=vn  */
    states++;
    (*states)= (int_32_band_pass_alu)x1_16; /* x2=x1  */
    states++;
     /* scale output of cel 5*/
    sn_32+=en_32;
    /* code of cel 6 */
    en_32= (int_32_band_pass_alu)en_16;
    en_32=en_32<<13; /* en<-en<<L+LA ,L=-2,LA=15*/
    x1_16= (int_16_band_pass_alu)(* states ); /* init x1 */
    x2_16= (int_16_band_pass_alu)(* (states+1)); /* init x2 */
    en_32+=24899*x1_16; /* en<-en - a1 . x1 */
    en_32+=-9880*x2_16; /* en<-en - a2 . x2 */
    tmp_32=en_32>>14; /* vn<-en >> LA */
    tmp_32+=1;
    vn_16=(int_16_band_pass_alu)(tmp_32>>1);
    en_32=20389*x1_16; /* en<-b1 . x1 ,because b0=0 */
    en_32+=-7985*x2_16; /* en<-en +b2 . x2  */
    (*states)= (int_32_band_pass_alu)vn_16; /* x1=vn  */
    states++;
    (*states)= (int_32_band_pass_alu)x1_16; /* x2=x1  */
    states++;
     /* scale output of cel 6*/
    sn_32+=en_32;
    /* code of cel 7 */
    en_32= (int_32_band_pass_alu)en_16;
    en_32=en_32<<11; /* en<-en<<L+LA ,L=-3,LA=14*/
    x1_16= (int_16_band_pass_alu)(* states ); /* init x1 */
    x2_16= (int_16_band_pass_alu)(* (states+1)); /* init x2 */
    en_32+=19404*x1_16; /* en<-en - a1 . x1 */
    en_32+=-7350*x2_16; /* en<-en - a2 . x2 */
    tmp_32=en_32>>13; /* vn<-en >> LA */
    tmp_32+=1;
    vn_16=(int_16_band_pass_alu)(tmp_32>>1);
    en_32=-22918*x1_16; /* en<-b1 . x1 ,because b0=0 */
    en_32+=6490*x2_16; /* en<-en +b2 . x2  */
    (*states)= (int_32_band_pass_alu)vn_16; /* x1=vn  */
    states++;
    (*states)= (int_32_band_pass_alu)x1_16; /* x2=x1  */
    states++;
     /* scale output of cel 7*/
    sn_32+=en_32;
    tmp_32=sn_32>>10; /* scale global output */
    tmp_32+=1;
    sn_32=tmp_32>>1;
    return  ( sn_32) ;
  } /* int_32_band_pass_alu one_step_+16bits_filter_band_pass_alu(..) */
  /* math.h is included only for cos and round function */
  #include <math.h>
   void teste_16bits_filter_band_pass_alu(void) {
      long int n=0,NB_ECHS=10; /* YOU CAN CHANGE THIS  */
      double amp_en=32767 ;  /* amplitude of input */
      double f_ech=100 ; /* sampling frequency hz */
      double f_reelle=2 ; /* real frequency hz */
      double freq_en=f_reelle/f_ech ; /* freelle/fe */
      double en ; 
      const double PI=3.141592653589793115998 ; 
      int_16_band_pass_alu en_16 ; 
      double phi_n=0 ; 
      double sn ;
      p_16bits_filter_band_pass_alu p_band_pass_alu=new_16bits_filter_band_pass_alu();
      for (n=0;n<NB_ECHS;n++) {
        en=amp_en*cos(phi_n);
        en_16=(int_16_band_pass_alu) floor(en+0.5);
        sn =  (double)one_step_16bits_filter_band_pass_alu(en_16 , p_band_pass_alu) ;
        phi_n+=2*PI*freq_en;
        if (phi_n>2*PI) {
          phi_n-=2*PI;
        }
      } /*for (n=0;n<NB_ECHS;n++) */
      destroy_16bits_filter_band_pass_alu(p_band_pass_alu) ;
    } /* void teste_16bits_filter_band_pass_alu(void)  */
  p_real_filter_band_pass_alu new_real_filter_band_pass_alu() {
  /* 7 cels, 5 coeffs:-a2,b2,-a1,b1,b0,  2 states xn_2,xn_1*/
    p_real_filter_band_pass_alu f =get_memory_real_filter_band_pass_alu(7,5,2);
    double *coeffs=f->coeffs;
    double *states=f->states;
    *(coeffs++)=0; /* coeffs -a2[1] */
    *(coeffs++)=0; /* coeffs +b2[1] */
    *(coeffs++)=0; /* coeffs -a1[1] */
    *(coeffs++)=0; /* coeffs +b1[1] */
    *(coeffs++)=0.00216031191272656; /* coeffs +b0[1] */
    *(states++)=0;/* xn_2[1]=0 */
    *(states++)=0;/* xn_1[1]=0 */
    *(coeffs++)=-0.74671837325806578; /* coeffs -a2[2] */
    *(coeffs++)=-0.18774922766859511; /* coeffs +b2[2] */
    *(coeffs++)=0.45393521108454393; /* coeffs -a1[2] */
    *(coeffs++)=-0.26998037065936170; /* coeffs +b1[2] */
    *(coeffs++)=0; /* coeffs +b0[2] */
    *(states++)=0;/* xn_2[2]=0 */
    *(states++)=0;/* xn_1[2]=0 */
    *(coeffs++)=-0.88518989196517595; /* coeffs -a2[3] */
    *(coeffs++)=-0.11671609658575380; /* coeffs +b2[3] */
    *(coeffs++)=1.7231887232369785; /* coeffs -a1[3] */
    *(coeffs++)=0.16737406432967003; /* coeffs +b1[3] */
    *(coeffs++)=0; /* coeffs +b0[3] */
    *(states++)=0;/* xn_2[3]=0 */
    *(states++)=0;/* xn_1[3]=0 */
    *(coeffs++)=-0.42247903728967900; /* coeffs -a2[4] */
    *(coeffs++)=0.87353891994405553; /* coeffs +b2[4] */
    *(coeffs++)=0.51655198218240783; /* coeffs -a1[4] */
    *(coeffs++)=-0.60339977709546722; /* coeffs +b1[4] */
    *(coeffs++)=0; /* coeffs +b0[4] */
    *(states++)=0;/* xn_2[4]=0 */
    *(states++)=0;/* xn_1[4]=0 */
    *(coeffs++)=-0.67224766969481897; /* coeffs -a2[5] */
    *(coeffs++)=0.50300988539138514; /* coeffs +b2[5] */
    *(coeffs++)=1.49353603903445031; /* coeffs -a1[5] */
    *(coeffs++)=-0.37084726028219606; /* coeffs +b1[5] */
    *(coeffs++)=0; /* coeffs +b0[5] */
    *(states++)=0;/* xn_2[5]=0 */
    *(states++)=0;/* xn_1[5]=0 */
    *(coeffs++)=-0.30150324195672817; /* coeffs -a2[6] */
    *(coeffs++)=-0.97468549092240697; /* coeffs +b2[6] */
    *(coeffs++)=0.75985160197061030; /* coeffs -a1[6] */
    *(coeffs++)=2.48889603135433646; /* coeffs +b1[6] */
    *(coeffs++)=0; /* coeffs +b0[6] */
    *(states++)=0;/* xn_2[6]=0 */
    *(states++)=0;/* xn_1[6]=0 */
    *(coeffs++)=-0.44859399836509900; /* coeffs -a2[7] */
    *(coeffs++)=0.39613599762385299; /* coeffs +b2[7] */
    *(coeffs++)=1.18432277351523396; /* coeffs -a1[7] */
    *(coeffs++)=-1.3987969807145404; /* coeffs +b1[7] */
    *(coeffs++)=0; /* coeffs +b0[7] */
    *(states++)=0;/* xn_2[7]=0 */
    *(states++)=0;/* xn_1[7]=0 */
    return f;
  }/* p_real_filter_band_pass_alu new_real_filter_band_pass_alu() */
 void teste_real_band_pass_alu(void) {
    long int n=0,NB_ECHS=10; /* YOU CAN CHANGE THIS  */
    double amp_en=1 ;  /* amplitude of input */
    double f_ech=100 ; /* sampling frequency hz */
    double f_reelle=2 ; /* real frequency hz */
    double freq_en=0.1 ; /* f/fe */
    double en ; 
    const double PI=3.141592653589793115998 ; 
    double phi_n=0 ; 
    double sn ;
    p_real_filter_band_pass_alu f_real_band_pass_alu=new_real_filter_band_pass_alu();
    for (n=0;n<NB_ECHS;n++) {
      en=amp_en*cos(phi_n);
      sn =  one_step_real_filter_band_pass_alu(en,f_real_band_pass_alu) ;
      phi_n+=2*PI*freq_en;
      if (phi_n>2*PI) {
        phi_n-=2*PI;
      }
    } /*for (n=0;n<NB_ECHS;n++) */
    destroy_real_filter_band_pass_alu(f_real_band_pass_alu) ;
  } /* void teste_real_band_pass_alu(void)  */

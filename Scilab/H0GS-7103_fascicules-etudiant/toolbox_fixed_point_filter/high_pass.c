/* stdio may be useful if you use printf */
#include <stdio.h>
/* stdlib is needed for malloc declaration */
#include <stdlib.h>
# define int_16_high_pass short int
# define int_32_high_pass long int
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
  }s_real_filter_high_pass;
  typedef s_real_filter_high_pass *p_real_filter_high_pass ;
  double one_step_real_filter_high_pass(double en,p_real_filter_high_pass f) {
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
  } /*double one_step_real_filter_high_pass(...)*/
  p_real_filter_high_pass get_memory_real_filter_high_pass(int nb_cels,int nb_coeffs_by_cel,int nb_states_by_cel) {
    p_real_filter_high_pass f=malloc(sizeof(s_real_filter_high_pass));/* get memory for filter structure*/
    f->nb_cels=nb_cels;
    f->nb_coeffs=nb_coeffs_by_cel * nb_cels;
    f->nb_states=nb_states_by_cel*  nb_cels;
  /* get memory for  coeffs and  states */
    f->coeffs=malloc(f->nb_coeffs * sizeof(double));
    f->states=malloc(f->nb_states * sizeof(double));
    return(f);
  } /* p_real_filter_high_pass new_real_filter_high_pass(int nb_cels,int nb_coeffs_by_cel,int nb_states_by_cel)*/
  void destroy_real_filter_high_pass(p_real_filter_high_pass f) {
    if (f->nb_coeffs >0) { 
      free((void *)f->coeffs); /* release memory for coeffs */
    } /* if (f->nb_coeffs >0) */ 
    if (f->nb_states >0) { 
      free((void *)f->states); /* release memory for states */
    } /* if (f->nb_states >0) */ 
    free((void *)f);         /* release memory of f */
  } /* void destroy_real_filter_high_pass(p_real_filter_high_pass f) */
  /* stdio may be useful if you use printf */
  #include <stdio.h>
  /* stdlib is needed for malloc declaration */
  #include <stdlib.h>
  const int_16_high_pass coeffs_16bits_high_pass[76]={
       31101 /* cel +1:  b0.2^15 */
       ,31957 /*  cel +2:  -a1.2^14 */
       ,-31927 /*  cel +2:  -a2.2^14 */
       ,-8601 /*  cel +2:  b1.2^19, note that b0=0 */
       ,20156 /*  cel +2:  b2.2^19 */
       ,31372 /*  cel +3:  -a1.2^14 */
       ,-30988 /*  cel +3:  -a2.2^14 */
       ,-16150 /*  cel +3:  b1.2^17, note that b0=0 */
       ,16999 /*  cel +3:  b2.2^17 */
       ,30808 /*  cel +4:  -a1.2^14 */
       ,-29740 /*  cel +4:  -a2.2^14 */
       ,-32031 /*  cel +4:  b1.2^17, note that b0=0 */
       ,4300 /*  cel +4:  b2.2^17 */
       ,30271 /*  cel +5:  -a1.2^14 */
       ,-28219 /*  cel +5:  -a2.2^14 */
       ,-6396 /*  cel +5:  b1.2^16, note that b0=0 */
       ,-30486 /*  cel +5:  b2.2^16 */
       ,29764 /*  cel +6:  -a1.2^14 */
       ,-26473 /*  cel +6:  -a2.2^14 */
       ,7025 /*  cel +6:  b1.2^14, note that b0=0 */
       ,-18757 /*  cel +6:  b2.2^14 */
       ,29292 /*  cel +7:  -a1.2^14 */
       ,-24560 /*  cel +7:  -a2.2^14 */
       ,18682 /*  cel +7:  b1.2^14, note that b0=0 */
       ,-26163 /*  cel +7:  b2.2^14 */
       ,28859 /*  cel +8:  -a1.2^14 */
       ,-22546 /*  cel +8:  -a2.2^14 */
       ,28224 /*  cel +8:  b1.2^14, note that b0=0 */
       ,-25787 /*  cel +8:  b2.2^14 */
       ,28468 /*  cel +9:  -a1.2^14 */
       ,-20504 /*  cel +9:  -a2.2^14 */
       ,31595 /*  cel +9:  b1.2^14, note that b0=0 */
       ,-17653 /*  cel +9:  b2.2^14 */
       ,11737 /*  cel +10:  -a1.2^13 */
       ,-17087 /*  cel +10:  -a2.2^13 */
       ,27086 /*  cel +10:  b1.2^13, note that b0=0 */
       ,18203 /*  cel +10:  b2.2^13 */
       ,22874 /*  cel +11:  -a1.2^14 */
       ,-27270 /*  cel +11:  -a2.2^14 */
       ,7633 /*  cel +11:  b1.2^12, note that b0=0 */
       ,18066 /*  cel +11:  b2.2^12 */
       ,22369 /*  cel +12:  -a1.2^14 */
       ,-21029 /*  cel +12:  -a2.2^14 */
       ,-831 /*  cel +12:  b1.2^12, note that b0=0 */
       ,23333 /*  cel +12:  b2.2^12 */
       ,21963 /*  cel +13:  -a1.2^14 */
       ,-15702 /*  cel +13:  -a2.2^14 */
       ,-10309 /*  cel +13:  b1.2^12, note that b0=0 */
       ,24801 /*  cel +13:  b2.2^12 */
       ,10545 /*  cel +14:  -a1.2^14 */
       ,-19096 /*  cel +14:  -a2.2^14 */
       ,-19176 /*  cel +14:  b1.2^11, note that b0=0 */
       ,28013 /*  cel +14:  b2.2^11 */
       ,20270 /*  cel +15:  -a1.2^15 */
       ,-15845 /*  cel +15:  -a2.2^15 */
       ,-25986 /*  cel +15:  b1.2^11, note that b0=0 */
       ,16839 /*  cel +15:  b2.2^11 */
       ,19859 /*  cel +16:  -a1.2^15 */
       ,-4431 /*  cel +16:  -a2.2^15 */
       ,-29672 /*  cel +16:  b1.2^11, note that b0=0 */
       ,10024 /*  cel +16:  b2.2^11 */
  };
    typedef struct {
      int nb_coeffs;
      int nb_states;
      int_16_high_pass *coeffs;
      int_32_high_pass *states;
    }s_16bits_filter_high_pass;
    typedef s_16bits_filter_high_pass *p_16bits_filter_high_pass;
  /* creator of structure p_16bits_filter_high_pass */
    p_16bits_filter_high_pass new_16bits_filter_high_pass() {
      p_16bits_filter_high_pass p_high_pass;
      p_high_pass = (s_16bits_filter_high_pass *) malloc(sizeof(s_16bits_filter_high_pass));
      int_32_high_pass *states;
      int is;
      p_high_pass->nb_coeffs=76;
      p_high_pass->nb_states=30;
      p_high_pass->coeffs=(int_16_high_pass *)&(coeffs_16bits_high_pass[0]);
      states =(int_32_high_pass *) malloc(30 * sizeof(int_32_high_pass));
      p_high_pass->states = states;
      for (is=0;is<30;is++) {
        *(states++)=0;
      }
      return p_high_pass;
    } /* p_16bits_filter_high_pass new_16bits_filter_high_pass()  */
  /* destructor of structure p_16bits_filter_high_pass */
    void  destroy_16bits_filter_high_pass(p_16bits_filter_high_pass p_high_pass) {
      free((void *) (p_high_pass->states) ); /* release memory allocated for states */
      free((void *)p_high_pass) ;/* release memory allocated for structure */
    } /* void destroy_16bits_filter_high_pass(p_16bits_filter_high_pass p_high_pass) */
  int_32_high_pass one_step_16bits_filter_high_pass(int_16_high_pass en_16 , p_16bits_filter_high_pass p_high_pass) {
    int_16_high_pass *coeffs;
    int_32_high_pass *states;
    coeffs=p_high_pass->coeffs;
    states=p_high_pass->states;
    int_32_high_pass tmp_32;
    int_16_high_pass vn_16;
    int_16_high_pass x1_16;
    int_16_high_pass x2_16;
    int_32_high_pass en_32;
    int_32_high_pass sn_32;
    sn_32=0;
    /* code of cel 1 */
    en_32= (int_32_high_pass)en_16;
    en_32=(int_32_high_pass)(en_32); /* en<-en .2^0 */
    en_32=31101* ( (int_16_high_pass) en_32); /* en<-b0 . en */
    tmp_32=en_32>>5; /* scale output of cel 1*/
    tmp_32+=1;
    en_32=tmp_32>>1;
    sn_32+=en_32;
    /* code of cel 2 */
    en_32= (int_32_high_pass)en_16;
    en_32=en_32<<6; /* en<-en<<L+LA ,L=-8,LA=14*/
    tmp_32=(* states )>>4; /* init x1 */
    tmp_32+=1;
    x1_16=(int_16_high_pass)(tmp_32>>1);
    tmp_32=(* (states+1))>>4; /* init x2 */
    tmp_32+=1;
    x2_16=(int_16_high_pass)(tmp_32>>1);
    en_32+=31957*x1_16; /* en<-en - a1 . x1 */
    en_32+=-31927*x2_16; /* en<-en - a2 . x2 */
    tmp_32=en_32>>13; /* vn<-en >> LA */
    tmp_32+=1;
    vn_16=(int_16_high_pass)(tmp_32>>1);
    en_32=-8601*x1_16; /* en<-b1 . x1 ,because b0=0 */
    en_32+=20156*x2_16; /* en<-en +b2 . x2  */
    (*states)+= vn_16; /* x1<-old_x1+vn  */
    (*states)-= x1_16; /* x1<-x1-[old_x1.2^-5] */
    states++;
    (*states)+= x1_16; /* x2<-x2+old_x1  */
    (*states)-= x2_16; /* x2<-x2-[old_x2.2^-5] */
    states++;
    tmp_32=en_32>>1; /* scale output of cel 2*/
    tmp_32+=1;
    en_32=tmp_32>>1;
    sn_32+=en_32;
    /* code of cel 3 */
    en_32= (int_32_high_pass)en_16;
    en_32=en_32<<8; /* en<-en<<L+LA ,L=-6,LA=14*/
    tmp_32=(* states )>>4; /* init x1 */
    tmp_32+=1;
    x1_16=(int_16_high_pass)(tmp_32>>1);
    tmp_32=(* (states+1))>>4; /* init x2 */
    tmp_32+=1;
    x2_16=(int_16_high_pass)(tmp_32>>1);
    en_32+=31372*x1_16; /* en<-en - a1 . x1 */
    en_32+=-30988*x2_16; /* en<-en - a2 . x2 */
    tmp_32=en_32>>13; /* vn<-en >> LA */
    tmp_32+=1;
    vn_16=(int_16_high_pass)(tmp_32>>1);
    en_32=-16150*x1_16; /* en<-b1 . x1 ,because b0=0 */
    en_32+=16999*x2_16; /* en<-en +b2 . x2  */
    (*states)+= vn_16; /* x1<-old_x1+vn  */
    (*states)-= x1_16; /* x1<-x1-[old_x1.2^-5] */
    states++;
    (*states)+= x1_16; /* x2<-x2+old_x1  */
    (*states)-= x2_16; /* x2<-x2-[old_x2.2^-5] */
    states++;
    tmp_32=en_32>>1; /* scale output of cel 3*/
    tmp_32+=1;
    en_32=tmp_32>>1;
    sn_32+=en_32;
    /* code of cel 4 */
    en_32= (int_32_high_pass)en_16;
    en_32=en_32<<9; /* en<-en<<L+LA ,L=-5,LA=14*/
    tmp_32=(* states )>>4; /* init x1 */
    tmp_32+=1;
    x1_16=(int_16_high_pass)(tmp_32>>1);
    tmp_32=(* (states+1))>>4; /* init x2 */
    tmp_32+=1;
    x2_16=(int_16_high_pass)(tmp_32>>1);
    en_32+=30808*x1_16; /* en<-en - a1 . x1 */
    en_32+=-29740*x2_16; /* en<-en - a2 . x2 */
    tmp_32=en_32>>13; /* vn<-en >> LA */
    tmp_32+=1;
    vn_16=(int_16_high_pass)(tmp_32>>1);
    en_32=-32031*x1_16; /* en<-b1 . x1 ,because b0=0 */
    en_32+=4300*x2_16; /* en<-en +b2 . x2  */
    (*states)+= vn_16; /* x1<-old_x1+vn  */
    (*states)-= x1_16; /* x1<-x1-[old_x1.2^-5] */
    states++;
    (*states)+= x1_16; /* x2<-x2+old_x1  */
    (*states)-= x2_16; /* x2<-x2-[old_x2.2^-5] */
    states++;
    tmp_32=en_32>>2; /* scale output of cel 4*/
    tmp_32+=1;
    en_32=tmp_32>>1;
    sn_32+=en_32;
    /* code of cel 5 */
    en_32= (int_32_high_pass)en_16;
    en_32=en_32<<9; /* en<-en<<L+LA ,L=-5,LA=14*/
    tmp_32=(* states )>>4; /* init x1 */
    tmp_32+=1;
    x1_16=(int_16_high_pass)(tmp_32>>1);
    tmp_32=(* (states+1))>>4; /* init x2 */
    tmp_32+=1;
    x2_16=(int_16_high_pass)(tmp_32>>1);
    en_32+=30271*x1_16; /* en<-en - a1 . x1 */
    en_32+=-28219*x2_16; /* en<-en - a2 . x2 */
    tmp_32=en_32>>13; /* vn<-en >> LA */
    tmp_32+=1;
    vn_16=(int_16_high_pass)(tmp_32>>1);
    en_32=-6396*x1_16; /* en<-b1 . x1 ,because b0=0 */
    en_32+=-30486*x2_16; /* en<-en +b2 . x2  */
    (*states)+= vn_16; /* x1<-old_x1+vn  */
    (*states)-= x1_16; /* x1<-x1-[old_x1.2^-5] */
    states++;
    (*states)+= x1_16; /* x2<-x2+old_x1  */
    (*states)-= x2_16; /* x2<-x2-[old_x2.2^-5] */
    states++;
    tmp_32=en_32>>1; /* scale output of cel 5*/
    tmp_32+=1;
    en_32=tmp_32>>1;
    sn_32+=en_32;
    /* code of cel 6 */
    en_32= (int_32_high_pass)en_16;
    en_32=en_32<<10; /* en<-en<<L+LA ,L=-4,LA=14*/
    tmp_32=(* states )>>4; /* init x1 */
    tmp_32+=1;
    x1_16=(int_16_high_pass)(tmp_32>>1);
    tmp_32=(* (states+1))>>4; /* init x2 */
    tmp_32+=1;
    x2_16=(int_16_high_pass)(tmp_32>>1);
    en_32+=29764*x1_16; /* en<-en - a1 . x1 */
    en_32+=-26473*x2_16; /* en<-en - a2 . x2 */
    tmp_32=en_32>>13; /* vn<-en >> LA */
    tmp_32+=1;
    vn_16=(int_16_high_pass)(tmp_32>>1);
    en_32=7025*x1_16; /* en<-b1 . x1 ,because b0=0 */
    en_32+=-18757*x2_16; /* en<-en +b2 . x2  */
    (*states)+= vn_16; /* x1<-old_x1+vn  */
    (*states)-= x1_16; /* x1<-x1-[old_x1.2^-5] */
    states++;
    (*states)+= x1_16; /* x2<-x2+old_x1  */
    (*states)-= x2_16; /* x2<-x2-[old_x2.2^-5] */
    states++;
    tmp_32=en_32; /* scale output of cel 6*/
    tmp_32+=1;
    en_32=tmp_32>>1;
    sn_32+=en_32;
    /* code of cel 7 */
    en_32= (int_32_high_pass)en_16;
    en_32=en_32<<10; /* en<-en<<L+LA ,L=-4,LA=14*/
    tmp_32=(* states )>>4; /* init x1 */
    tmp_32+=1;
    x1_16=(int_16_high_pass)(tmp_32>>1);
    tmp_32=(* (states+1))>>4; /* init x2 */
    tmp_32+=1;
    x2_16=(int_16_high_pass)(tmp_32>>1);
    en_32+=29292*x1_16; /* en<-en - a1 . x1 */
    en_32+=-24560*x2_16; /* en<-en - a2 . x2 */
    tmp_32=en_32>>13; /* vn<-en >> LA */
    tmp_32+=1;
    vn_16=(int_16_high_pass)(tmp_32>>1);
    en_32=18682*x1_16; /* en<-b1 . x1 ,because b0=0 */
    en_32+=-26163*x2_16; /* en<-en +b2 . x2  */
    (*states)+= vn_16; /* x1<-old_x1+vn  */
    (*states)-= x1_16; /* x1<-x1-[old_x1.2^-5] */
    states++;
    (*states)+= x1_16; /* x2<-x2+old_x1  */
    (*states)-= x2_16; /* x2<-x2-[old_x2.2^-5] */
    states++;
    tmp_32=en_32; /* scale output of cel 7*/
    tmp_32+=1;
    en_32=tmp_32>>1;
    sn_32+=en_32;
    /* code of cel 8 */
    en_32= (int_32_high_pass)en_16;
    en_32=en_32<<10; /* en<-en<<L+LA ,L=-4,LA=14*/
    tmp_32=(* states )>>4; /* init x1 */
    tmp_32+=1;
    x1_16=(int_16_high_pass)(tmp_32>>1);
    tmp_32=(* (states+1))>>4; /* init x2 */
    tmp_32+=1;
    x2_16=(int_16_high_pass)(tmp_32>>1);
    en_32+=28859*x1_16; /* en<-en - a1 . x1 */
    en_32+=-22546*x2_16; /* en<-en - a2 . x2 */
    tmp_32=en_32>>13; /* vn<-en >> LA */
    tmp_32+=1;
    vn_16=(int_16_high_pass)(tmp_32>>1);
    en_32=28224*x1_16; /* en<-b1 . x1 ,because b0=0 */
    en_32+=-25787*x2_16; /* en<-en +b2 . x2  */
    (*states)+= vn_16; /* x1<-old_x1+vn  */
    (*states)-= x1_16; /* x1<-x1-[old_x1.2^-5] */
    states++;
    (*states)+= x1_16; /* x2<-x2+old_x1  */
    (*states)-= x2_16; /* x2<-x2-[old_x2.2^-5] */
    states++;
    tmp_32=en_32; /* scale output of cel 8*/
    tmp_32+=1;
    en_32=tmp_32>>1;
    sn_32+=en_32;
    /* code of cel 9 */
    en_32= (int_32_high_pass)en_16;
    en_32=en_32<<10; /* en<-en<<L+LA ,L=-4,LA=14*/
    tmp_32=(* states )>>4; /* init x1 */
    tmp_32+=1;
    x1_16=(int_16_high_pass)(tmp_32>>1);
    tmp_32=(* (states+1))>>4; /* init x2 */
    tmp_32+=1;
    x2_16=(int_16_high_pass)(tmp_32>>1);
    en_32+=28468*x1_16; /* en<-en - a1 . x1 */
    en_32+=-20504*x2_16; /* en<-en - a2 . x2 */
    tmp_32=en_32>>13; /* vn<-en >> LA */
    tmp_32+=1;
    vn_16=(int_16_high_pass)(tmp_32>>1);
    en_32=31595*x1_16; /* en<-b1 . x1 ,because b0=0 */
    en_32+=-17653*x2_16; /* en<-en +b2 . x2  */
    (*states)+= vn_16; /* x1<-old_x1+vn  */
    (*states)-= x1_16; /* x1<-x1-[old_x1.2^-5] */
    states++;
    (*states)+= x1_16; /* x2<-x2+old_x1  */
    (*states)-= x2_16; /* x2<-x2-[old_x2.2^-5] */
    states++;
    tmp_32=en_32; /* scale output of cel 9*/
    tmp_32+=1;
    en_32=tmp_32>>1;
    sn_32+=en_32;
    /* code of cel 10 */
    en_32= (int_32_high_pass)en_16;
    en_32=en_32<<10; /* en<-en<<L+LA ,L=-3,LA=13*/
    tmp_32=(* states )>>5; /* init x1 */
    tmp_32+=1;
    x1_16=(int_16_high_pass)(tmp_32>>1);
    tmp_32=(* (states+1))>>5; /* init x2 */
    tmp_32+=1;
    x2_16=(int_16_high_pass)(tmp_32>>1);
    en_32+=11737*x1_16; /* en<-en - a1 . x1 */
    en_32+=-17087*x2_16; /* en<-en - a2 . x2 */
    tmp_32=en_32>>12; /* vn<-en >> LA */
    tmp_32+=1;
    vn_16=(int_16_high_pass)(tmp_32>>1);
    en_32=27086*x1_16; /* en<-b1 . x1 ,because b0=0 */
    en_32+=18203*x2_16; /* en<-en +b2 . x2  */
    (*states)+= vn_16; /* x1<-old_x1+vn  */
    (*states)-= x1_16; /* x1<-x1-[old_x1.2^-6] */
    states++;
    (*states)+= x1_16; /* x2<-x2+old_x1  */
    (*states)-= x2_16; /* x2<-x2-[old_x2.2^-6] */
    states++;
    tmp_32=en_32; /* scale output of cel 10*/
    tmp_32+=1;
    en_32=tmp_32>>1;
    sn_32+=en_32;
    /* code of cel 11 */
    en_32= (int_32_high_pass)en_16;
    en_32=en_32<<11; /* en<-en<<L+LA ,L=-3,LA=14*/
    tmp_32=(* states )>>5; /* init x1 */
    tmp_32+=1;
    x1_16=(int_16_high_pass)(tmp_32>>1);
    tmp_32=(* (states+1))>>5; /* init x2 */
    tmp_32+=1;
    x2_16=(int_16_high_pass)(tmp_32>>1);
    en_32+=22874*x1_16; /* en<-en - a1 . x1 */
    en_32+=-27270*x2_16; /* en<-en - a2 . x2 */
    tmp_32=en_32>>13; /* vn<-en >> LA */
    tmp_32+=1;
    vn_16=(int_16_high_pass)(tmp_32>>1);
    en_32=7633*x1_16; /* en<-b1 . x1 ,because b0=0 */
    en_32+=18066*x2_16; /* en<-en +b2 . x2  */
    (*states)+= vn_16; /* x1<-old_x1+vn  */
    (*states)-= x1_16; /* x1<-x1-[old_x1.2^-6] */
    states++;
    (*states)+= x1_16; /* x2<-x2+old_x1  */
    (*states)-= x2_16; /* x2<-x2-[old_x2.2^-6] */
    states++;
     /* scale output of cel 11*/
    sn_32+=en_32;
    /* code of cel 12 */
    en_32= (int_32_high_pass)en_16;
    en_32=en_32<<12; /* en<-en<<L+LA ,L=-2,LA=14*/
    tmp_32=(* states )>>5; /* init x1 */
    tmp_32+=1;
    x1_16=(int_16_high_pass)(tmp_32>>1);
    tmp_32=(* (states+1))>>5; /* init x2 */
    tmp_32+=1;
    x2_16=(int_16_high_pass)(tmp_32>>1);
    en_32+=22369*x1_16; /* en<-en - a1 . x1 */
    en_32+=-21029*x2_16; /* en<-en - a2 . x2 */
    tmp_32=en_32>>13; /* vn<-en >> LA */
    tmp_32+=1;
    vn_16=(int_16_high_pass)(tmp_32>>1);
    en_32=-831*x1_16; /* en<-b1 . x1 ,because b0=0 */
    en_32+=23333*x2_16; /* en<-en +b2 . x2  */
    (*states)+= vn_16; /* x1<-old_x1+vn  */
    (*states)-= x1_16; /* x1<-x1-[old_x1.2^-6] */
    states++;
    (*states)+= x1_16; /* x2<-x2+old_x1  */
    (*states)-= x2_16; /* x2<-x2-[old_x2.2^-6] */
    states++;
    tmp_32=en_32; /* scale output of cel 12*/
    tmp_32+=1;
    en_32=tmp_32>>1;
    sn_32+=en_32;
    /* code of cel 13 */
    en_32= (int_32_high_pass)en_16;
    en_32=en_32<<12; /* en<-en<<L+LA ,L=-2,LA=14*/
    tmp_32=(* states )>>5; /* init x1 */
    tmp_32+=1;
    x1_16=(int_16_high_pass)(tmp_32>>1);
    tmp_32=(* (states+1))>>5; /* init x2 */
    tmp_32+=1;
    x2_16=(int_16_high_pass)(tmp_32>>1);
    en_32+=21963*x1_16; /* en<-en - a1 . x1 */
    en_32+=-15702*x2_16; /* en<-en - a2 . x2 */
    tmp_32=en_32>>13; /* vn<-en >> LA */
    tmp_32+=1;
    vn_16=(int_16_high_pass)(tmp_32>>1);
    en_32=-10309*x1_16; /* en<-b1 . x1 ,because b0=0 */
    en_32+=24801*x2_16; /* en<-en +b2 . x2  */
    (*states)+= vn_16; /* x1<-old_x1+vn  */
    (*states)-= x1_16; /* x1<-x1-[old_x1.2^-6] */
    states++;
    (*states)+= x1_16; /* x2<-x2+old_x1  */
    (*states)-= x2_16; /* x2<-x2-[old_x2.2^-6] */
    states++;
    tmp_32=en_32; /* scale output of cel 13*/
    tmp_32+=1;
    en_32=tmp_32>>1;
    sn_32+=en_32;
    /* code of cel 14 */
    en_32= (int_32_high_pass)en_16;
    en_32=en_32<<13; /* en<-en<<L+LA ,L=-1,LA=14*/
    tmp_32=(* states )>>6; /* init x1 */
    tmp_32+=1;
    x1_16=(int_16_high_pass)(tmp_32>>1);
    tmp_32=(* (states+1))>>6; /* init x2 */
    tmp_32+=1;
    x2_16=(int_16_high_pass)(tmp_32>>1);
    en_32+=10545*x1_16; /* en<-en - a1 . x1 */
    en_32+=-19096*x2_16; /* en<-en - a2 . x2 */
    tmp_32=en_32>>13; /* vn<-en >> LA */
    tmp_32+=1;
    vn_16=(int_16_high_pass)(tmp_32>>1);
    en_32=-19176*x1_16; /* en<-b1 . x1 ,because b0=0 */
    en_32+=28013*x2_16; /* en<-en +b2 . x2  */
    (*states)+= vn_16; /* x1<-old_x1+vn  */
    (*states)-= x1_16; /* x1<-x1-[old_x1.2^-7] */
    states++;
    (*states)+= x1_16; /* x2<-x2+old_x1  */
    (*states)-= x2_16; /* x2<-x2-[old_x2.2^-7] */
    states++;
    tmp_32=en_32; /* scale output of cel 14*/
    tmp_32+=1;
    en_32=tmp_32>>1;
    sn_32+=en_32;
    /* code of cel 15 */
    en_32= (int_32_high_pass)en_16;
    en_32=en_32<<14; /* en<-en<<L+LA ,L=-1,LA=15*/
    tmp_32=(* states )>>6; /* init x1 */
    tmp_32+=1;
    x1_16=(int_16_high_pass)(tmp_32>>1);
    tmp_32=(* (states+1))>>6; /* init x2 */
    tmp_32+=1;
    x2_16=(int_16_high_pass)(tmp_32>>1);
    en_32+=20270*x1_16; /* en<-en - a1 . x1 */
    en_32+=-15845*x2_16; /* en<-en - a2 . x2 */
    tmp_32=en_32>>14; /* vn<-en >> LA */
    tmp_32+=1;
    vn_16=(int_16_high_pass)(tmp_32>>1);
    en_32=-25986*x1_16; /* en<-b1 . x1 ,because b0=0 */
    en_32+=16839*x2_16; /* en<-en +b2 . x2  */
    (*states)+= vn_16; /* x1<-old_x1+vn  */
    (*states)-= x1_16; /* x1<-x1-[old_x1.2^-7] */
    states++;
    (*states)+= x1_16; /* x2<-x2+old_x1  */
    (*states)-= x2_16; /* x2<-x2-[old_x2.2^-7] */
    states++;
    tmp_32=en_32; /* scale output of cel 15*/
    tmp_32+=1;
    en_32=tmp_32>>1;
    sn_32+=en_32;
    /* code of cel 16 */
    en_32= (int_32_high_pass)en_16;
    en_32=en_32<<14; /* en<-en<<L+LA ,L=-1,LA=15*/
    tmp_32=(* states )>>6; /* init x1 */
    tmp_32+=1;
    x1_16=(int_16_high_pass)(tmp_32>>1);
    tmp_32=(* (states+1))>>6; /* init x2 */
    tmp_32+=1;
    x2_16=(int_16_high_pass)(tmp_32>>1);
    en_32+=19859*x1_16; /* en<-en - a1 . x1 */
    en_32+=-4431*x2_16; /* en<-en - a2 . x2 */
    tmp_32=en_32>>14; /* vn<-en >> LA */
    tmp_32+=1;
    vn_16=(int_16_high_pass)(tmp_32>>1);
    en_32=-29672*x1_16; /* en<-b1 . x1 ,because b0=0 */
    en_32+=10024*x2_16; /* en<-en +b2 . x2  */
    (*states)+= vn_16; /* x1<-old_x1+vn  */
    (*states)-= x1_16; /* x1<-x1-[old_x1.2^-7] */
    states++;
    (*states)+= x1_16; /* x2<-x2+old_x1  */
    (*states)-= x2_16; /* x2<-x2-[old_x2.2^-7] */
    states++;
    tmp_32=en_32; /* scale output of cel 16*/
    tmp_32+=1;
    en_32=tmp_32>>1;
    sn_32+=en_32;
    tmp_32=sn_32>>8; /* scale global output */
    tmp_32+=1;
    sn_32=tmp_32>>1;
    return  ( sn_32) ;
  } /* int_32_high_pass one_step_+16bits_filter_high_pass(..) */
  /* math.h is included only for cos and round function */
  #include <math.h>
   void teste_16bits_filter_high_pass(void) {
      long int n=0,NB_ECHS=10; /* YOU CAN CHANGE THIS  */
      double amp_en=32767 ;  /* amplitude of input */
      double f_ech=100 ; /* sampling frequency hz */
      double f_reelle=2 ; /* real frequency hz */
      double freq_en=f_reelle/f_ech ; /* freelle/fe */
      double en ; 
      const double PI=3.141592653589793115998 ; 
      int_16_high_pass en_16 ; 
      double phi_n=0 ; 
      double sn ;
      p_16bits_filter_high_pass p_high_pass=new_16bits_filter_high_pass();
      for (n=0;n<NB_ECHS;n++) {
        en=amp_en*cos(phi_n);
        en_16=(int_16_high_pass) floor(en+0.5);
        sn =  (double)one_step_16bits_filter_high_pass(en_16 , p_high_pass) ;
        phi_n+=2*PI*freq_en;
        if (phi_n>2*PI) {
          phi_n-=2*PI;
        }
      } /*for (n=0;n<NB_ECHS;n++) */
      destroy_16bits_filter_high_pass(p_high_pass) ;
    } /* void teste_16bits_filter_high_pass(void)  */
  p_real_filter_high_pass new_real_filter_high_pass() {
  /* 16 cels, 5 coeffs:-a2,b2,-a1,b1,b0,  2 states xn_2,xn_1*/
    p_real_filter_high_pass f =get_memory_real_filter_high_pass(16,5,2);
    double *coeffs=f->coeffs;
    double *states=f->states;
    *(coeffs++)=0; /* coeffs -a2[1] */
    *(coeffs++)=0; /* coeffs +b2[1] */
    *(coeffs++)=0; /* coeffs -a1[1] */
    *(coeffs++)=0; /* coeffs +b1[1] */
    *(coeffs++)=0.94912248756956852; /* coeffs +b0[1] */
    *(states++)=0;/* xn_2[1]=0 */
    *(states++)=0;/* xn_1[1]=0 */
    *(coeffs++)=-0.99942815234598659; /* coeffs -a2[2] */
    *(coeffs++)=0.00053420994155514; /* coeffs +b2[2] */
    *(coeffs++)=1.99845336039456667; /* coeffs -a1[2] */
    *(coeffs++)=-0.00051268701138111; /* coeffs +b1[2] */
    *(coeffs++)=0; /* coeffs +b0[2] */
    *(states++)=0;/* xn_2[2]=0 */
    *(states++)=0;/* xn_1[2]=0 */
    *(coeffs++)=-0.99829168507035604; /* coeffs -a2[3] */
    *(coeffs++)=0.00385677532306198; /* coeffs +b2[3] */
    *(coeffs++)=1.99733802282672857; /* coeffs -a1[3] */
    *(coeffs++)=-0.00385045270539719; /* coeffs +b1[3] */
    *(coeffs++)=0; /* coeffs +b0[3] */
    *(states++)=0;/* xn_2[3]=0 */
    *(states++)=0;/* xn_1[3]=0 */
    *(coeffs++)=-0.99717516311090482; /* coeffs -a2[4] */
    *(coeffs++)=0.00743011452251806; /* coeffs +b2[4] */
    *(coeffs++)=1.99626226386232974; /* coeffs -a1[4] */
    *(coeffs++)=-0.00763672433190982; /* coeffs +b1[4] */
    *(coeffs++)=0; /* coeffs +b0[4] */
    *(states++)=0;/* xn_2[4]=0 */
    *(states++)=0;/* xn_1[4]=0 */
    *(coeffs++)=-0.99609072025762302; /* coeffs -a2[5] */
    *(coeffs++)=0.00250026191051427; /* coeffs +b2[5] */
    *(coeffs++)=1.99523642415404057; /* coeffs -a1[5] */
    *(coeffs++)=-0.00304985280417241; /* coeffs +b1[5] */
    *(coeffs++)=0; /* coeffs +b0[5] */
    *(states++)=0;/* xn_2[5]=0 */
    *(states++)=0;/* xn_1[5]=0 */
    *(coeffs++)=-0.99505010623690671; /* coeffs -a2[6] */
    *(coeffs++)=-0.01409922576069710; /* coeffs +b2[6] */
    *(coeffs++)=1.99426968565573137; /* coeffs -a1[6] */
    *(coeffs++)=0.01339998088320779; /* coeffs +b1[6] */
    *(coeffs++)=0; /* coeffs +b0[6] */
    *(states++)=0;/* xn_2[6]=0 */
    *(states++)=0;/* xn_1[6]=0 */
    *(coeffs++)=-0.99406456433371637; /* coeffs -a2[7] */
    *(coeffs++)=-0.03607968830382295; /* coeffs +b2[7] */
    *(coeffs++)=1.99337006240047665; /* coeffs -a1[7] */
    *(coeffs++)=0.03563380936249054; /* coeffs +b1[7] */
    *(coeffs++)=0; /* coeffs +b0[7] */
    *(states++)=0;/* xn_2[7]=0 */
    *(states++)=0;/* xn_1[7]=0 */
    *(coeffs++)=-0.99314471540914051; /* coeffs -a2[8] */
    *(coeffs++)=-0.05368755503709748; /* coeffs +b2[8] */
    *(coeffs++)=1.99254442597648973; /* coeffs -a1[8] */
    *(coeffs++)=0.05383279091553757; /* coeffs +b1[8] */
    *(coeffs++)=0; /* coeffs +b0[8] */
    *(states++)=0;/* xn_2[8]=0 */
    *(states++)=0;/* xn_1[8]=0 */
    *(coeffs++)=-0.9923004492422688; /* coeffs -a2[9] */
    *(coeffs++)=-0.05943193346289335; /* coeffs +b2[9] */
    *(coeffs++)=1.99179856043282277; /* coeffs -a1[9] */
    *(coeffs++)=0.06026294152512061; /* coeffs +b1[9] */
    *(coeffs++)=0; /* coeffs +b0[9] */
    *(states++)=0;/* xn_2[9]=0 */
    *(states++)=0;/* xn_1[9]=0 */
    *(coeffs++)=-0.99154082405458666; /* coeffs -a2[10] */
    *(coeffs++)=-0.05031251547903391; /* coeffs +b2[10] */
    *(coeffs++)=1.9911372403678289; /* coeffs -a1[10] */
    *(coeffs++)=0.05166223791112473; /* coeffs +b1[10] */
    *(coeffs++)=0; /* coeffs +b0[10] */
    *(states++)=0;/* xn_2[10]=0 */
    *(states++)=0;/* xn_1[10]=0 */
    *(coeffs++)=-0.99087397500878283; /* coeffs -a2[11] */
    *(coeffs++)=-0.02758427109329164; /* coeffs +b2[11] */
    *(coeffs++)=1.99056432528220739; /* coeffs -a1[11] */
    *(coeffs++)=0.02911605220757743; /* coeffs +b1[11] */
    *(coeffs++)=0; /* coeffs +b0[11] */
    *(states++)=0;/* xn_2[11]=0 */
    *(states++)=0;/* xn_1[11]=0 */
    *(coeffs++)=-0.99030703240877060; /* coeffs -a2[12] */
    *(coeffs++)=0.00450972178394285; /* coeffs +b2[12] */
    *(coeffs++)=1.9900828629342304; /* coeffs -a1[12] */
    *(coeffs++)=-0.00316846852330907; /* coeffs +b1[12] */
    *(coeffs++)=0; /* coeffs +b0[12] */
    *(states++)=0;/* xn_2[12]=0 */
    *(states++)=0;/* xn_1[12]=0 */
    *(coeffs++)=-0.98984605026045447; /* coeffs -a2[13] */
    *(coeffs++)=0.04019006943952072; /* coeffs +b2[13] */
    *(coeffs++)=1.98969519442392739; /* coeffs -a1[13] */
    *(coeffs++)=-0.03932628588445313; /* coeffs +b1[13] */
    *(coeffs++)=0; /* coeffs +b0[13] */
    *(states++)=0;/* xn_2[13]=0 */
    *(states++)=0;/* xn_1[13]=0 */
    *(coeffs++)=-0.98949594578067190; /* coeffs -a2[14] */
    *(coeffs++)=0.07341317852274050; /* coeffs +b2[14] */
    *(coeffs++)=1.98940305404933415; /* coeffs -a1[14] */
    *(coeffs++)=-0.07314981608727389; /* coeffs +b1[14] */
    *(coeffs++)=0; /* coeffs +b0[14] */
    *(states++)=0;/* xn_2[14]=0 */
    *(states++)=0;/* xn_1[14]=0 */
    *(coeffs++)=-0.98926045036242338; /* coeffs -a2[15] */
    *(coeffs++)=0.09885509648367860; /* coeffs +b2[15] */
    *(coeffs++)=1.98920765760232499; /* coeffs -a1[15] */
    *(coeffs++)=-0.09912770403531543; /* coeffs +b1[15] */
    *(coeffs++)=0; /* coeffs +b0[15] */
    *(states++)=0;/* xn_2[15]=0 */
    *(states++)=0;/* xn_1[15]=0 */
    *(coeffs++)=-0.98914207241691854; /* coeffs -a2[16] */
    *(coeffs++)=0.11260587345602306; /* coeffs +b2[16] */
    *(coeffs++)=1.98910977367347908; /* coeffs -a1[16] */
    *(coeffs++)=-0.1131914359805812; /* coeffs +b1[16] */
    *(coeffs++)=0; /* coeffs +b0[16] */
    *(states++)=0;/* xn_2[16]=0 */
    *(states++)=0;/* xn_1[16]=0 */
    return f;
  }/* p_real_filter_high_pass new_real_filter_high_pass() */
 void teste_real_high_pass(void) {
    long int n=0,NB_ECHS=10; /* YOU CAN CHANGE THIS  */
    double amp_en=1 ;  /* amplitude of input */
    double f_ech=100 ; /* sampling frequency hz */
    double f_reelle=2 ; /* real frequency hz */
    double freq_en=0.1 ; /* f/fe */
    double en ; 
    const double PI=3.141592653589793115998 ; 
    double phi_n=0 ; 
    double sn ;
    p_real_filter_high_pass f_real_high_pass=new_real_filter_high_pass();
    for (n=0;n<NB_ECHS;n++) {
      en=amp_en*cos(phi_n);
      sn =  one_step_real_filter_high_pass(en,f_real_high_pass) ;
      phi_n+=2*PI*freq_en;
      if (phi_n>2*PI) {
        phi_n-=2*PI;
      }
    } /*for (n=0;n<NB_ECHS;n++) */
    destroy_real_filter_high_pass(f_real_high_pass) ;
  } /* void teste_real_high_pass(void)  */

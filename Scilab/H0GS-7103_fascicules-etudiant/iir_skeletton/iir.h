/*
 * File:   iir.h
 * Author: ygorra
 *
 * Created on 17 octobre 2013, 11:46
 */

#ifndef IIR_H
#define	IIR_H
typedef long int int_32;
typedef short int int_16;
#define MAX_BUF_SIZE 32

typedef struct {
    // F(z) = (b0+ b1 z^-1)  / (1 + a1.z^-1 )
    // partie relative a la programmation en nombres entiers
    int_16 b0_16,  b1_16,  a1_16  ;
    int Lb0,Lb1,La1;
    int L1, L2, L3, L4;
    double b0_q, b1_q, a1_q; // a deduire de b0_16,Lb0,..., dans la fonction init_fir_int16
    int_16 en_16;
    int_32 sn_32;
    // partie relative a la programmation en nombres reels double precision
    double b0, b1, a1; // coeffs reels double precision
    double en;
    double sn;
} s_iir;
void init_iir_int_16(s_iir *s, int_16 B0_16, int_16 LB0, int_16 B1_16, int_16 LB1, int_16 A1_16, int_16 LA1, int_16 L1, int_16 L2, int_16 L3, int_16 L4);
extern void one_step_iir_int_16(s_iir *s, int_16 en_16); //calcule nouvelle sortie
extern void end_iir_int_16(s_iir *s); //libere ressources occupees par entiers
void init_iir_double(s_iir *s, double b0, double b1, double a1); // init contenu de s (reels)
extern void one_step_iir_double(s_iir *s, double en); //calcule nouvelle sortie
extern void end_iir_double(s_iir *s); //libere ressources
extern void teste_iir(void);


#endif	/* IIR_H */


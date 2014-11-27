/*
 * File:   fir.h
 * Author: ygorra
 *
 * Created on 17 octobre 2013, 11:46
 */

#ifndef FIR_H
#define	FIR_H
    typedef long int int_32;
    typedef short int int_16;
#define MAX_BUF_SIZE 32


    typedef struct {
        // partie relative a la programmation en nombres entiers
        int N_16;
        int_16 gn_16[MAX_BUF_SIZE];
        int_16 en_16[MAX_BUF_SIZE];
        int_32 sn_32;
        // partie relative a la programmation en nombres reels double precision
        int N;
        double gn[MAX_BUF_SIZE];
        double en[MAX_BUF_SIZE];
        double sn;
    } s_fir;
    extern void init_fir_int_16(s_fir *s, int_16 gn[], int size_gn,int LC); // init contenu de s (entiers)
    extern void one_step_fir_int_16(s_fir *s,int_16 en_16); //calcule nouvelle sortie
    extern void end_fir_int_16(s_fir *s); //libere ressources occupees par entiers
    extern void init_fir_double(s_fir *s, double gn[], int size_gn); // init contenu de s (reels)
    extern void one_step_fir_double(s_fir *s, double en); //calcule nouvelle sortie
    extern void end_fir_double(s_fir *s); //libere ressources
    extern void teste_fir(void);


#endif	/* FIR_H */


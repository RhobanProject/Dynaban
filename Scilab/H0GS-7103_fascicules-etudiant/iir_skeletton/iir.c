#include <math.h>
#include <stdio.h>
#include "iir.h"
#include "statistics.h"
#ifndef PI
#define PI 3.14159265358979323846	/* pi */
#endif

void init_iir_int_16(s_iir *s, int_16 B0_16,int_16 LB0, int_16 B1_16,int_16 LB1, int_16 A1_16, int_16 LA1,int_16 L1,int_16 L2,int_16 L3,int_16 L4 ) {
    // initialiser le contenu de la structure  pour quelle fonctionne de maniere autonome
    // les decalages L1..L4 sont les decalages'' eventuellement utiles pour implementer le filtre'':
    // il sont probablement trop nombreux, auquel cas ne pas les utiliser...
    // 1- b0_16,Lb0 ..... dans les champs correspondants de la structure,
    // 2- en deduire les parametres quantifies b0q, b1q ... correspondants
    // 3- initialiser les entrees passes (entieres )
    // 4- copier L1,.. L4 dans les champs correspondants de la structure, si necessaire
}

void end_iir_int_16(s_iir *s) {
    // liberer les ressources employees par le iir,
    // ici il n'y a rien a faire
}

void one_step_iir_int_16(s_iir *s, int_16 en_16) {
    // mettre a jour la sortie sn_32 et les 'memoires= entrees passees' du filtre
        s->sn_32=en_16; // a modifier , et il faudra plus d'une ligne

}

void init_iir_double(s_iir *s, double b0,double b1,double a1) {
    // initialiser le contenu de la structure
    //  pour qu'elle fonctionne de maniere autonome
    // 1- copier b0,b1,a1 dans la structure
    s->b0=b0;
    // 2- initialiser les memoires 
}

void end_iir_double(s_iir *s) {
    // liberer les ressources employees par le iir,
    // ici il n'y a rien a faire
}

void one_step_iir_double(s_iir *s, double en) {
    // mettre a jour la sortie sn ,et les entrees passes (memoires) dans s, 
    // a partir de la nouvelle entree en
    s->sn=en; // a modifier , et il faudra plus d'une ligne
}

void teste_iir() {
    int N_TEST = 1000, N_MESURE = 10;
    s_iir iir_test;
    
    double b0=0.7,b1=-0.7,a1 = -0.9 ; // F(z) = (b0+ b1.z^-1)/ (1 + a1 . z^-1 )
    // coefficients et decalages entiers correspondants (pas optimaux))
    int Lb0=12;int_16 b0_16=round(b0*(1<<Lb0));
    int Lb1=13;int_16 b1_16=round(b1*(1<<Lb1));
    int La1=12;int_16 a1_16=round(a1*(1<<La1));
    // quelques decalages 'implicites', qui peuvent aider a la programmation 
    int L1=0,L2=0,L3=0,L4=0;
    // for sn statistics
    struct_statistics sn_stats, errn_stats;
    double sn, sn_32,errn;
    // entree :
    double en=1.2; // juste pour le test
    // cree un nouveau filtre IIR 
    init_iir_double(&iir_test, b0, b1,a1);

    init_iir_int_16(&iir_test, b0_16,Lb0,b1_16,Lb1,a1_16,La1,L1,L2,L3,L4);
    // boucle de test du filtre
    for (int n = 0; n < N_TEST; n++) {
     en =n; // entree e(n), en fonction de n, a modifier
        // mise a jour des sorties , en fonction  de la nouvelle entree
        one_step_iir_double(&iir_test, en);
        one_step_iir_int_16(&iir_test, (int_16) en);
        // affichage eventuel des signaux (deconseille, peu informatif)
        sn = iir_test.sn;
        sn_32=iir_test.sn_32;
        errn = iir_test.sn - iir_test.sn_32;
        printf(" e(%d)= %e ; s(%d) = %e; s_32(%d) =%e \n",n,en,n,sn,n,sn_32);
        // mise a jour (muette )des statistiques

        if (n == N_MESURE) {
            init_statistics(&sn_stats, sn);
            init_statistics(&errn_stats, errn);
        }
        if (n >= N_MESURE) {
            update_statistics(&sn_stats, sn);
            update_statistics(&errn_stats, errn);
        }
    }
    // finalise et affiche les statistiques des signaux
    finalize_statistics(&sn_stats);
    finalize_statistics(&errn_stats);
    show_statistics(&sn_stats, "sortie ");
    show_statistics(&errn_stats,"erreur");
    // libere les ressources employees par les filtres iir
    end_iir_double(&iir_test);
    end_iir_int_16(&iir_test);
}

#include <stdio.h>
#include <stdlib.h>
#include <math.h>

typedef struct {
    double mean;
    double power, var, sd, v_eff;
    double min, max;
    long int nb_echs;
} struct_statistics;

struct_statistics* new_struct_statistics() {
    struct_statistics *p = malloc(sizeof (struct_statistics));
    p->mean = 0;
    p->power = 0;
    p->nb_echs = 0;
}

void update_struct_statistics(double en, struct_statistics *p) {
    // update min and max
    if (p->nb_echs == 0) {
        p->min = p->max = en;
    } else {
        if (en > p->max) {
            p->max = en;
        } else if (en < p->min) {
            p->min = en;
        }
    }
    p->mean += en;
    p->power += en*en;
    p->nb_echs++;
}
void destroy_struct_statistics(struct_statistics *p) {
    free(p);
}
void finalize_struct_statistics(struct_statistics *p) {
    if (p->nb_echs < 1) return;
    p->mean /= p->nb_echs;
    p->power /= p->nb_echs;
    p->v_eff = sqrt(p->power);
    p->var = p->power - p->mean * p->mean;
    if (p->var < 0) p->var = 0;
    p->sd = sqrt(p->var);
}

void print_struct_statistics(struct_statistics *p, const char * name) {
    printf("------- statisticals results for %s -------------\n", name);
    if (p->nb_echs <= 0) {
        printf("  no samples \n");
        return;
    }
    printf(" nb_samples =%ld \n", p->nb_echs);
    printf("    min  =%e \n", p->min);
    printf("    max  =%e \n", p->max);
    printf("    mean =%e \n", p->mean);
    printf("    sd   =%e \n", p->sd);
    printf("    veff =%e \n", p->v_eff);

}


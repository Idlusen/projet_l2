/** @file
 *  @brief implémentation du rôle de bonus ramassable d’une entité (source)
 */

#include <string.h>

#include "entite_bonus.h"
#include "entite.h"
#include "constantes.h"

/**
 * @brief Alloue la mémoire pour un `t_bonus` et initialise ses champs.
 * 
 * @param id Identifiant de ressource utilisé pour définir les valeurs par défaut.
 * @return pointeur vers le `t_bonus` alloué et initialisé
 */

t_bonus * creer_bonus(char * id) {
    t_bonus * nouv = malloc(sizeof(t_bonus));
    strcpy(nouv->id_son, "ramasser_bonus");
    nouv->valeur = 0;
    nouv->soin = 0;
    if (strcmp(id, "pieces") == 0) {
        nouv->valeur = 5;
    }
    else if (strcmp(id, "coeur") == 0) {
        nouv->soin = 1;
    }
    return nouv;
}

/**
 * @brief Crée une nouvelle structure d'entité bonus avec les attributs spécifiés.
 * 
 * @param id Identifiant de l'entité bonus.
 * @param x Position en x de l'entité bonus.
 * @param y Position en y de l'entité bonus.
 * @param w Largeur de l'entité bonus.
 * @param h Hauteur de l'entité bonus.
 * @param est_relatif 1 si les coordonnées sont relatives, 0 si elles sont absolues.
 * @return Pointeur vers la nouvelle structure d'entité créée.
 */

t_entite * creer_entite_bonus(char * id, float x, float y, float w, float h, int est_relatif) {
    t_entite * nouv = creer_entite(id, x, y, w, h, est_relatif);
    nouv->bonus = creer_bonus(id);
    return nouv;
}

/**
 * @brief Détruit une structure d'entité bonus et libère la mémoire associée.
 * 
 * @param b Pointeur vers le pointeur de la structure d'entité bonus à détruire.
 */

void detruire_bonus(t_bonus ** b) {
    if (*b) {
        free(*b);
    }
    *b = NULL;
}

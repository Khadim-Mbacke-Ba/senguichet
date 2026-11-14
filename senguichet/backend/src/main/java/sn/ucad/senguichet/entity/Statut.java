package sn.ucad.senguichet.entity;

/**
 * Les statuts possibles d'une demande administrative.
 *
 * Le cycle de vie d'une demande :
 *   DEPOSEE -> EN_COURS -> VALIDEE
 *                       -> REJETEE
 */
public enum Statut {
    DEPOSEE,
    EN_COURS,
    VALIDEE,
    REJETEE
}

package sn.ucad.senguichet.entity;

import jakarta.persistence.*;
import jakarta.validation.constraints.NotBlank;
import java.time.LocalDateTime;

/**
 * Une demande administrative deposee par un etudiant.
 * C'est l'entite centrale du fil rouge SenGuichet.
 *
 * Les etudiants enrichiront ce modele au fil des labs
 * (ajout des entites Etudiant, Agent, Document, etc.).
 */
@Entity
@Table(name = "demandes")
public class Demande {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    /** Numero unique de la demande, ex : DEM-2025-0001.
     *  Defini apres le premier enregistrement (derive de l'id). */
    @Column(unique = true)
    private String numero;

    /** Type de demarche : ATTESTATION, INSCRIPTION, BOURSE, RELEVE... */
    @NotBlank(message = "Le type de demande est obligatoire")
    @Column(nullable = false)
    private String type;

    /** Nom complet de l'etudiant demandeur */
    @NotBlank(message = "Le nom de l'etudiant est obligatoire")
    @Column(nullable = false)
    private String nomEtudiant;

    /** Statut courant de la demande */
    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    private Statut statut = Statut.DEPOSEE;

    /** Date et heure de depot */
    @Column(nullable = false)
    private LocalDateTime dateDepot = LocalDateTime.now();

    // ===== Constructeurs =====

    public Demande() {
    }

    public Demande(String numero, String type, String nomEtudiant) {
        this.numero = numero;
        this.type = type;
        this.nomEtudiant = nomEtudiant;
        this.statut = Statut.DEPOSEE;
        this.dateDepot = LocalDateTime.now();
    }

    // ===== Getters et Setters =====

    public Long getId() {
        return id;
    }

    public void setId(Long id) {
        this.id = id;
    }

    public String getNumero() {
        return numero;
    }

    public void setNumero(String numero) {
        this.numero = numero;
    }

    public String getType() {
        return type;
    }

    public void setType(String type) {
        this.type = type;
    }

    public String getNomEtudiant() {
        return nomEtudiant;
    }

    public void setNomEtudiant(String nomEtudiant) {
        this.nomEtudiant = nomEtudiant;
    }

    public Statut getStatut() {
        return statut;
    }

    public void setStatut(Statut statut) {
        this.statut = statut;
    }

    public LocalDateTime getDateDepot() {
        return dateDepot;
    }

    public void setDateDepot(LocalDateTime dateDepot) {
        this.dateDepot = dateDepot;
    }
}

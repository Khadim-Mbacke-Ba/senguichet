package sn.ucad.senguichet.controller;

import jakarta.validation.Valid;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import sn.ucad.senguichet.entity.Demande;
import sn.ucad.senguichet.entity.Statut;
import sn.ucad.senguichet.service.DemandeService;

import java.util.List;
import java.util.Map;

/**
 * API REST des demandes.
 *
 * Expose les operations sous /api/demandes :
 *   GET    /api/demandes        -> liste toutes les demandes
 *   GET    /api/demandes/{id}   -> une demande
 *   POST   /api/demandes        -> creer une demande
 *   PUT    /api/demandes/{id}/statut -> changer le statut
 *   DELETE /api/demandes/{id}   -> supprimer
 */
@RestController
@RequestMapping("/api/demandes")
@CrossOrigin(origins = "*")
public class DemandeController {

    private final DemandeService service;

    public DemandeController(DemandeService service) {
        this.service = service;
    }

    /** Liste toutes les demandes */
    @GetMapping
    public List<Demande> listerToutes() {
        return service.listerToutes();
    }

    /** Retourne une demande par son id, ou 404 si absente */
    @GetMapping("/{id}")
    public ResponseEntity<Demande> trouverParId(@PathVariable Long id) {
        return service.trouverParId(id)
                .map(ResponseEntity::ok)
                .orElse(ResponseEntity.notFound().build());
    }

    /** Cree une nouvelle demande */
    @PostMapping
    public ResponseEntity<Demande> creer(@Valid @RequestBody Demande demande) {
        Demande creee = service.creer(demande);
        return ResponseEntity.status(HttpStatus.CREATED).body(creee);
    }

    /**
     * Change le statut d'une demande.
     * Le corps de la requete doit contenir : { "statut": "VALIDEE" }
     */
    @PutMapping("/{id}/statut")
    public ResponseEntity<Demande> changerStatut(
            @PathVariable Long id,
            @RequestBody Map<String, String> corps) {

        String valeurStatut = corps.get("statut");
        if (valeurStatut == null) {
            return ResponseEntity.badRequest().build();
        }

        try {
            Statut nouveauStatut = Statut.valueOf(valeurStatut);
            return service.changerStatut(id, nouveauStatut)
                    .map(ResponseEntity::ok)
                    .orElse(ResponseEntity.notFound().build());
        } catch (IllegalArgumentException e) {
            // Statut invalide
            return ResponseEntity.badRequest().build();
        }
    }

    /** Supprime une demande */
    @DeleteMapping("/{id}")
    public ResponseEntity<Void> supprimer(@PathVariable Long id) {
        if (service.supprimer(id)) {
            return ResponseEntity.noContent().build();
        }
        return ResponseEntity.notFound().build();
    }
}

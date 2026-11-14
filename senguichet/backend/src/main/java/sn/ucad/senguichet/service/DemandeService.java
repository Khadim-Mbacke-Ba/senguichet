package sn.ucad.senguichet.service;

import org.springframework.stereotype.Service;
import sn.ucad.senguichet.entity.Demande;
import sn.ucad.senguichet.entity.Statut;
import sn.ucad.senguichet.repository.DemandeRepository;

import java.time.Year;
import java.util.List;
import java.util.Optional;

/**
 * Logique metier des demandes.
 *
 * C'est ici que vivent les regles : generation du numero,
 * changement de statut, etc. Le controleur ne fait qu'appeler
 * ces methodes.
 */
@Service
public class DemandeService {

    private final DemandeRepository repository;

    public DemandeService(DemandeRepository repository) {
        this.repository = repository;
    }

    /** Retourne toutes les demandes */
    public List<Demande> listerToutes() {
        return repository.findAll();
    }

    /** Retourne une demande par son identifiant */
    public Optional<Demande> trouverParId(Long id) {
        return repository.findById(id);
    }

    /**
     * Cree une nouvelle demande.
     * Le numero est genere automatiquement au format DEM-ANNEE-XXXX,
     * derive de l'identifiant (monotone, jamais reutilise meme apres
     * une suppression).
     */
    public Demande creer(Demande demande) {
        demande.setStatut(Statut.DEPOSEE);
        // Premier enregistrement : Hibernate genere l'id
        Demande enregistree = repository.save(demande);
        // On derive le numero de l'id, ce qui garantit son unicite
        String numero = String.format("DEM-%d-%04d",
                Year.now().getValue(), enregistree.getId());
        enregistree.setNumero(numero);
        return repository.save(enregistree);
    }

    /**
     * Change le statut d'une demande.
     * Retourne la demande mise a jour, ou Optional.empty() si elle n'existe pas.
     */
    public Optional<Demande> changerStatut(Long id, Statut nouveauStatut) {
        return repository.findById(id).map(demande -> {
            demande.setStatut(nouveauStatut);
            return repository.save(demande);
        });
    }

    /** Supprime une demande. Retourne true si elle existait. */
    public boolean supprimer(Long id) {
        if (repository.existsById(id)) {
            repository.deleteById(id);
            return true;
        }
        return false;
    }
}

package sn.ucad.senguichet.repository;

import org.springframework.data.jpa.repository.JpaRepository;
import sn.ucad.senguichet.entity.Demande;

/**
 * Acces aux donnees des demandes.
 *
 * En etendant JpaRepository, on dispose gratuitement de toutes
 * les operations de base : findAll, findById, save, deleteById...
 */
public interface DemandeRepository extends JpaRepository<Demande, Long> {
    // JpaRepository fournit deja toutes les operations necessaires :
    // findAll, findById, save, deleteById, existsById, count...
}

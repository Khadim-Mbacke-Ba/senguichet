package sn.ucad.senguichet;

import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import sn.ucad.senguichet.entity.Demande;
import sn.ucad.senguichet.entity.Statut;
import sn.ucad.senguichet.service.DemandeService;

import static org.junit.jupiter.api.Assertions.*;

/**
 * Tests du service des demandes.
 *
 * Ces tests serviront au Lab 2 (GitLab CI) : le pipeline les
 * executera automatiquement a chaque push. Les etudiants en
 * ajouteront d'autres au fil des labs.
 */
@SpringBootTest
class DemandeServiceTest {

    @Autowired
    private DemandeService service;

    @Test
    void creer_genere_un_numero_et_statut_depose() {
        Demande demande = new Demande();
        demande.setType("ATTESTATION");
        demande.setNomEtudiant("Ibrahima Fall");

        Demande creee = service.creer(demande);

        assertNotNull(creee.getId());
        assertNotNull(creee.getNumero());
        assertTrue(creee.getNumero().startsWith("DEM-"));
        assertEquals(Statut.DEPOSEE, creee.getStatut());
    }

    @Test
    void changer_statut_met_a_jour_la_demande() {
        Demande demande = new Demande();
        demande.setType("BOURSE");
        demande.setNomEtudiant("Awa Ba");
        Demande creee = service.creer(demande);

        service.changerStatut(creee.getId(), Statut.VALIDEE);

        Demande rechargee = service.trouverParId(creee.getId()).orElseThrow();
        assertEquals(Statut.VALIDEE, rechargee.getStatut());
    }

    @Test
    void supprimer_retourne_false_si_inexistante() {
        boolean resultat = service.supprimer(999999L);
        assertFalse(resultat);
    }
}

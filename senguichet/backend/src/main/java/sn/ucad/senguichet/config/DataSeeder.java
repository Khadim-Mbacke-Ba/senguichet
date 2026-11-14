package sn.ucad.senguichet.config;

import org.springframework.boot.CommandLineRunner;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import sn.ucad.senguichet.entity.Demande;
import sn.ucad.senguichet.entity.Statut;
import sn.ucad.senguichet.repository.DemandeRepository;

/**
 * Insere quelques demandes de demonstration au demarrage,
 * uniquement si la base est vide.
 *
 * Cela permet aux etudiants de voir des donnees des le premier
 * lancement, sans avoir a en saisir manuellement.
 */
@Configuration
public class DataSeeder {

    @Bean
    CommandLineRunner initData(DemandeRepository repository, sn.ucad.senguichet.service.DemandeService service) {
        return args -> {
            if (repository.count() == 0) {
                // On passe par le service pour que les numeros soient
                // generes de facon coherente (meme annee que les demandes
                // creees ensuite par les utilisateurs).
                Demande d1 = new Demande();
                d1.setType("ATTESTATION");
                d1.setNomEtudiant("Fatou Diop");
                service.creer(d1);
                service.changerStatut(d1.getId(), Statut.VALIDEE);

                Demande d2 = new Demande();
                d2.setType("INSCRIPTION");
                d2.setNomEtudiant("Moussa Ndiaye");
                service.creer(d2);
                service.changerStatut(d2.getId(), Statut.EN_COURS);

                Demande d3 = new Demande();
                d3.setType("BOURSE");
                d3.setNomEtudiant("Aminata Sow");
                service.creer(d3);

                System.out.println(">>> SenGuichet : 3 demandes de demonstration inserees.");
            }
        };
    }
}

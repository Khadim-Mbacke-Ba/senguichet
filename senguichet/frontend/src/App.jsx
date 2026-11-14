import { useState, useEffect } from 'react'
import {
  listerDemandes,
  creerDemande,
  changerStatut,
  supprimerDemande,
} from './api'

// Les types de demarches proposes dans le formulaire
const TYPES = ['ATTESTATION', 'INSCRIPTION', 'BOURSE', 'RELEVE']

// Les statuts possibles et leur couleur d'affichage
const STATUTS = {
  DEPOSEE: { libelle: 'Déposée', couleur: '#5a6c80' },
  EN_COURS: { libelle: 'En cours', couleur: '#ea7d2b' },
  VALIDEE: { libelle: 'Validée', couleur: '#3aa84d' },
  REJETEE: { libelle: 'Rejetée', couleur: '#cc1f1f' },
}

function App() {
  const [demandes, setDemandes] = useState([])
  const [nomEtudiant, setNomEtudiant] = useState('')
  const [type, setType] = useState(TYPES[0])
  const [erreur, setErreur] = useState(null)
  const [chargement, setChargement] = useState(true)

  // Charge les demandes au premier affichage
  useEffect(() => {
    rafraichir()
  }, [])

  async function rafraichir() {
    try {
      setChargement(true)
      const data = await listerDemandes()
      setDemandes(data)
      setErreur(null)
    } catch (e) {
      setErreur(e.message)
    } finally {
      setChargement(false)
    }
  }

  async function soumettre(e) {
    e.preventDefault()
    if (!nomEtudiant.trim()) return
    try {
      await creerDemande({ type, nomEtudiant })
      setNomEtudiant('')
      setType(TYPES[0])
      await rafraichir()
    } catch (e) {
      setErreur(e.message)
    }
  }

  async function modifierStatut(id, statut) {
    try {
      await changerStatut(id, statut)
      await rafraichir()
    } catch (e) {
      setErreur(e.message)
    }
  }

  async function retirer(id) {
    try {
      await supprimerDemande(id)
      await rafraichir()
    } catch (e) {
      setErreur(e.message)
    }
  }

  return (
    <div className="conteneur">
      <header className="entete">
        <h1>SénGuichet</h1>
        <p>Guichet unique universitaire — UCAD</p>
      </header>

      {erreur && <div className="erreur">{erreur}</div>}

      <section className="carte">
        <h2>Déposer une demande</h2>
        <form onSubmit={soumettre} className="formulaire">
          <input
            type="text"
            placeholder="Nom de l'étudiant"
            value={nomEtudiant}
            onChange={(e) => setNomEtudiant(e.target.value)}
          />
          <select value={type} onChange={(e) => setType(e.target.value)}>
            {TYPES.map((t) => (
              <option key={t} value={t}>
                {t}
              </option>
            ))}
          </select>
          <button type="submit">Déposer</button>
        </form>
      </section>

      <section className="carte">
        <h2>Demandes ({demandes.length})</h2>
        {chargement ? (
          <p>Chargement...</p>
        ) : demandes.length === 0 ? (
          <p>Aucune demande pour le moment.</p>
        ) : (
          <table className="tableau">
            <thead>
              <tr>
                <th>Numéro</th>
                <th>Type</th>
                <th>Étudiant</th>
                <th>Statut</th>
                <th>Actions</th>
              </tr>
            </thead>
            <tbody>
              {demandes.map((d) => (
                <tr key={d.id}>
                  <td>{d.numero}</td>
                  <td>{d.type}</td>
                  <td>{d.nomEtudiant}</td>
                  <td>
                    <span
                      className="badge"
                      style={{ backgroundColor: STATUTS[d.statut]?.couleur }}
                    >
                      {STATUTS[d.statut]?.libelle || d.statut}
                    </span>
                  </td>
                  <td className="actions">
                    <select
                      value={d.statut}
                      onChange={(e) => modifierStatut(d.id, e.target.value)}
                    >
                      {Object.keys(STATUTS).map((s) => (
                        <option key={s} value={s}>
                          {STATUTS[s].libelle}
                        </option>
                      ))}
                    </select>
                    <button className="bouton-suppr" onClick={() => retirer(d.id)}>
                      Supprimer
                    </button>
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        )}
      </section>

      <footer className="pied">
        <p>SénGuichet — Projet fil rouge AGL — Master 1 SIR — DMI/FST/UCAD</p>
      </footer>
    </div>
  )
}

export default App

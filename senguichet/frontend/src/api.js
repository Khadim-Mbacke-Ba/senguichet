// ============================================================
// Module d'acces a l'API SenGuichet
// ============================================================
// Toutes les fonctions qui parlent au backend sont regroupees ici.
// En developpement, les appels vers /api sont rediriges vers
// http://localhost:8080 par le proxy Vite (voir vite.config.js).
// ============================================================

const BASE_URL = '/api/demandes'

// Recupere toutes les demandes
export async function listerDemandes() {
  const reponse = await fetch(BASE_URL)
  if (!reponse.ok) throw new Error('Erreur lors du chargement des demandes')
  return reponse.json()
}

// Cree une nouvelle demande
export async function creerDemande(demande) {
  const reponse = await fetch(BASE_URL, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify(demande),
  })
  if (!reponse.ok) throw new Error('Erreur lors de la creation de la demande')
  return reponse.json()
}

// Change le statut d'une demande
export async function changerStatut(id, statut) {
  const reponse = await fetch(`${BASE_URL}/${id}/statut`, {
    method: 'PUT',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({ statut }),
  })
  if (!reponse.ok) throw new Error('Erreur lors du changement de statut')
  return reponse.json()
}

// Supprime une demande
export async function supprimerDemande(id) {
  const reponse = await fetch(`${BASE_URL}/${id}`, { method: 'DELETE' })
  if (!reponse.ok) throw new Error('Erreur lors de la suppression')
}

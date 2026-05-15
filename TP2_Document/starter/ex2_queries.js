use healthcare_dz

// 2.1 Patients diabétiques > 50 ans à Alger


print("\n=== EX 2.1 ===")

db.patients.find({
  antecedents: "Diabète",
  "adresse.wilaya": "Alger",
  dateNaissance: {
    $lte: new Date(new Date().setFullYear(new Date().getFullYear() - 50))
  }
}, {
  nom: 1,
  prenom: 1,
  antecedents: 1,
  "adresse.wilaya": 1
})

// 2.2 Allergiques pénicilline avec >= 3 consultations

print("\n=== EX 2.2 ===")

db.patients.find({
  allergies: "Pénicilline",
  $expr: {
    $gte: [
      { $size: "$consultations" },
      3
    ]
  }
}, {
  nom: 1,
  prenom: 1,
  allergies: 1
})

// 2.3 Projection dernière consultation

print("\n=== EX 2.3 ===")

db.patients.aggregate([
  {
    $project: {
      nom: 1,
      prenom: 1,
      derniereConsultation: {
        $arrayElemAt: ["$consultations", -1]
      }
    }
  }
])

// 2.4 Patients sans antécédents avec tension > 140

print("\n=== EX 2.4 ===")

db.patients.aggregate([
  {
    $project: {
      nom: 1,
      prenom: 1,
      antecedents: 1,
      derniereConsultation: {
        $arrayElemAt: ["$consultations", -1]
      }
    }
  },
  {
    $match: {
      antecedents: { $size: 0 },
      "derniereConsultation.tension.systolique": { $gt: 140 }
    }
  }
])

// 2.5 Recherche textuelle diagnostic

print("\n=== EX 2.5 ===")

// Création index text

db.patients.createIndex({
  "consultations.diagnostic": "text"
})

// Recherche

db.patients.find(
  {
    $text: {
      $search: "hypertension"
    }
  },
  {
    nom: 1,
    prenom: 1,
    score: {
      $meta: "textScore"
    }
  }
).sort({
  score: {
    $meta: "textScore"
  }
})

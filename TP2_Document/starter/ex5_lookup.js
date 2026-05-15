use healthcare_dz

// 5.1 Dossier complet patient

print("\n=== EX 5.1 ===")

const patientId = ObjectId("665a123456789abcdef12345")


db.patients.aggregate([
  {
    $match: {
      _id: patientId
    }
  },
  {
    $lookup: {
      from: "analyses",
      localField: "_id",
      foreignField: "patient_id",
      as: "analysesCompletes"
    }
  }
])

// 5.2 Glycémie > 1.26 g/L

print("\n=== EX 5.2 ===")


db.analyses.aggregate([
  {
    $match: {
      type: "Glycémie",
      "resultats.valeur": {
        $gt: 1.26
      }
    }
  },
  {
    $lookup: {
      from: "patients",
      localField: "patient_id",
      foreignField: "_id",
      as: "patient"
    }
  },
  {
    $unwind: "$patient"
  },
  {
    $project: {
      _id: 0,
      nom: "$patient.nom",
      prenom: "$patient.prenom",
      glycémie: "$resultats.valeur"
    }
  }
])

// 5.3 Taux analyses anormales par wilaya

print("\n=== EX 5.3 ===")


db.analyses.aggregate([
  {
    $lookup: {
      from: "patients",
      localField: "patient_id",
      foreignField: "_id",
      as: "patient"
    }
  },
  {
    $unwind: "$patient"
  },
  {
    $group: {
      _id: "$patient.adresse.wilaya",
      totalAnalyses: {
        $sum: 1
      },
      analysesAnormales: {
        $sum: {
          $cond: [
            { $eq: ["$valide", false] },
            1,
            0
          ]
        }
      }
    }
  },
  {
    $project: {
      wilaya: "$_id",
      tauxAnormal: {
        $multiply: [
          {
            $divide: [
              "$analysesAnormales",
              "$totalAnalyses"
            ]
          },
          100
        ]
      }
    }
  },
  {
    $sort: {
      tauxAnormal: -1
    }
  }
])

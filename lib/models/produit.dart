// fichier: lib/produit.dart

class Produit {
  String nom;
  double prixParKilo;
  int nombreCartons;
  double poidsCarton;

  Produit({
    required this.nom,
    required this.prixParKilo,
    required this.nombreCartons,
    required this.poidsCarton,
  });

  double prixCarton() {
    return poidsCarton * prixParKilo;
  }

  double calculerCout() {
    return prixCarton() * nombreCartons;
  }

  double get poidsTotal {
    return nombreCartons * poidsCarton;
  }

  // Nouvelle méthode pour calculer le prix en CFA
  double prixCartonCFA(double tauxConversion) {
    return prixCarton() * tauxConversion;
  }

  // Nouvelle méthode pour calculer le coût total en CFA
  double calculerCoutCFA(double tauxConversion) {
    return calculerCout() * tauxConversion;
  }

  // Nouvelle méthode pour calculer le prix de revient par carton avec taxes ventilées
  double prixRevientCartonAvecTaxes(double coutTotalProduits, double taxesCFA, double tauxConversion) {
    if (coutTotalProduits == 0) return 0;
    
    // Proportion des taxes pour ce produit
    double proportion = calculerCout() / coutTotalProduits;
    double taxesVentilees = taxesCFA * proportion;
    
    // Prix de revient par carton = (coût du produit en CFA + taxes ventilées) / nombre de cartons
    return (calculerCoutCFA(tauxConversion) + taxesVentilees) / nombreCartons;
  }
}
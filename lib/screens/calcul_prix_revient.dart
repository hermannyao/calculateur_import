// fichier: lib/calcul_prix_revient.dart
import 'package:calculateur_import/models/produit.dart';
import 'package:flutter/material.dart';


class CalculPrixRevient extends StatefulWidget {
  const CalculPrixRevient({super.key});

    @override
    CalculPrixRevientState createState() => CalculPrixRevientState();
}

class CalculPrixRevientState extends State<CalculPrixRevient> {
    List<Produit> produits = [];
    List<ProduitControllers> produitsControllers = [];
    TextEditingController taxeController = TextEditingController();
    TextEditingController tauxConversionController = TextEditingController();
    double prixRevientTotal = 0.0;
    double prixRevientTotalCFA = 0.0;
    final ScrollController _scrollController = ScrollController();

    // États pour les accordéons
    bool _configExpanded = true;
    bool _resultsExpanded = true;
    final List<bool> _produitExpanded = [];

    @override
    void initState() {
        super.initState();
        ajouterProduit();
        tauxConversionController.text = "655";
    }

    @override
    void dispose() {
        taxeController.dispose();
        tauxConversionController.dispose();
        _scrollController.dispose();
        for (var controller in produitsControllers) {
            controller.dispose();
        }
        super.dispose();
    }

    void ajouterProduit() {
        final nouveauProduit = Produit(
                nom: 'Produit ${produits.length + 1}',
                prixParKilo: 0.0,
                nombreCartons: 0,
                poidsCarton: 0.0,
    );

        final nouveauxControllers = ProduitControllers(
                nomController: TextEditingController(text: nouveauProduit.nom),
        prixParKiloController: TextEditingController(text: nouveauProduit.prixParKilo.toString()),
        nombreCartonsController: TextEditingController(text: nouveauProduit.nombreCartons.toString()),
        poidsCartonController: TextEditingController(text: nouveauProduit.poidsCarton.toString()),
    );

        setState(() {
            produits.add(nouveauProduit);
            produitsControllers.add(nouveauxControllers);
            _produitExpanded.add(true);
        });

        WidgetsBinding.instance.addPostFrameCallback((_) {
                _scrollController.animateTo(
                        _scrollController.position.maxScrollExtent,
                        duration: Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    });
    }

    void supprimerProduit(int index) {
        setState(() {
            if (produits.length > 1) {
                produitsControllers[index].dispose();
                produits.removeAt(index);
                produitsControllers.removeAt(index);
                _produitExpanded.removeAt(index);
            }
        });
    }

    void _updateProduitFromControllers(int index) {
        final produit = produits[index];
        final controllers = produitsControllers[index];

        setState(() {
            produit.nom = controllers.nomController.text;
            produit.prixParKilo = double.tryParse(controllers.prixParKiloController.text) ?? 0.0;
            produit.nombreCartons = int.tryParse(controllers.nombreCartonsController.text) ?? 0;
            produit.poidsCarton = double.tryParse(controllers.poidsCartonController.text) ?? 0.0;
        });

        calculerPrixRevient();
    }

    void calculerPrixRevient() {
        double coutTotalProduits = 0.0;

        for (var produit in produits) {
            coutTotalProduits += produit.calculerCout();
        }

        double taxesUSD = double.tryParse(taxeController.text) ?? 0.0;
        double tauxConversion = double.tryParse(tauxConversionController.text) ?? 655.0;

        setState(() {
            prixRevientTotal = coutTotalProduits + taxesUSD;
            prixRevientTotalCFA = prixRevientTotal * tauxConversion;
        });
    }

    Widget _buildProduitAccordion(int index) {
        final produit = produits[index];
        final controllers = produitsControllers[index];

        double tauxConversion = double.tryParse(tauxConversionController.text) ?? 655.0;
        double taxesUSD = double.tryParse(taxeController.text) ?? 0.0;
        double taxesCFA = taxesUSD * tauxConversion;
        double coutTotalProduits = produits.fold(0.0, (sum, p) => sum + p.calculerCout());

        double prixRevientAvecTaxes = 0;
        if (produit.nombreCartons > 0) {
            prixRevientAvecTaxes = produit.prixRevientCartonAvecTaxes(
                    coutTotalProduits,
                    taxesCFA,
                    tauxConversion
            );
        }

        return Container(
                margin: EdgeInsets.only(bottom: 12.0),
        decoration: BoxDecoration(
                color: Colors.grey[800],
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
        BoxShadow(
                color: Colors.black26,
                blurRadius: 4,
                offset: Offset(0, 2),
          ),
        ],
      ),
        child: ExpansionTile(
                initiallyExpanded: _produitExpanded[index],
                onExpansionChanged: (bool expanded) {
            setState(() {
                _produitExpanded[index] = expanded;
            });
        },
        leading: Icon(
                Icons.inventory_2,
                color: Colors.white,
        ),
        title: Text(
                produit.nom.isEmpty
                        ? 'Produit ${index + 1}'
                        : produit.nom,
                style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.white,
          ),
        ),
        subtitle: Text(
                '${produit.calculerCout().toStringAsFixed(2)} USD • '
        '${produit.calculerCoutCFA(tauxConversion).toStringAsFixed(0)} CFA',
                style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade300,
          ),
        ),
        trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
        if (produits.length > 1)
            IconButton(
                    icon: Icon(Icons.delete, color: Colors.red.shade300, size: 20),
        onPressed: () => supprimerProduit(index),
                tooltip: 'Supprimer',
              ),
        Icon(
                _produitExpanded[index] ? Icons.expand_less : Icons.expand_more,
                color: Colors.white,
            ),
          ],
        ),
        children: [
        Container(
                color: Colors.grey[700],
                padding: EdgeInsets.all(16.0),
                child: Column(
                children: [
        // Nom du produit
        TextField(
                controller: controllers.nomController,
                style: TextStyle(color: Colors.white),
        decoration: InputDecoration(
                labelText: 'Nom du produit',
                labelStyle: TextStyle(color: Colors.grey.shade300),
        border: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.grey.shade500),
                    ),
        enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.grey.shade500),
                    ),
        focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.blue.shade300),
                    ),
        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                  ),
        onChanged: (value) {
                _updateProduitFromControllers(index);
                  },
                ),
        SizedBox(height: 16),

        // Grille des champs
        Row(
                children: [
        Expanded(
                child: TextField(
                controller: controllers.prixParKiloController,
                style: TextStyle(color: Colors.white),
        keyboardType: TextInputType.numberWithOptions(decimal: true),
        decoration: InputDecoration(
                labelText: 'Prix/kilo (USD)',
                labelStyle: TextStyle(color: Colors.grey.shade300),
        border: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.grey.shade500),
                          ),
        enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.grey.shade500),
                          ),
        focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.blue.shade300),
                          ),
        prefixIcon: Icon(Icons.attach_money, size: 20, color: Colors.grey.shade300),
                        ),
        onChanged: (value) {
                _updateProduitFromControllers(index);
                        },
                      ),
                    ),
        SizedBox(width: 12),
        Expanded(
                child: TextField(
                controller: controllers.nombreCartonsController,
                style: TextStyle(color: Colors.white),
        keyboardType: TextInputType.number,
                decoration: InputDecoration(
                labelText: 'Nb. cartons',
                labelStyle: TextStyle(color: Colors.grey.shade300),
        border: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.grey.shade500),
                          ),
        enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.grey.shade500),
                          ),
        focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.blue.shade300),
                          ),
        prefixIcon: Icon(Icons.inventory_2, size: 20, color: Colors.grey.shade300),
                        ),
        onChanged: (value) {
                _updateProduitFromControllers(index);
                        },
                      ),
                    ),
                  ],
                ),
        SizedBox(height: 12),

        TextField(
                controller: controllers.poidsCartonController,
                style: TextStyle(color: Colors.white),
        keyboardType: TextInputType.numberWithOptions(decimal: true),
        decoration: InputDecoration(
                labelText: 'Poids par carton (kg)',
                labelStyle: TextStyle(color: Colors.grey.shade300),
        border: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.grey.shade500),
                    ),
        enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.grey.shade500),
                    ),
        focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.blue.shade300),
                    ),
        prefixIcon: Icon(Icons.scale, size: 20, color: Colors.grey.shade300),
                  ),
        onChanged: (value) {
                _updateProduitFromControllers(index);
                  },
                ),
        SizedBox(height: 16),

        // Cartes de résultats
        Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                color: Colors.grey[600],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.shade500),
                  ),
        child: Column(
                children: [
        _buildResultCard(
                'Prix par carton',
                '${produit.prixCarton().toStringAsFixed(2)} USD',
                '${produit.prixCartonCFA(tauxConversion).toStringAsFixed(0)} CFA',
                ),
                SizedBox(height: 12),
        _buildResultCard(
                'Coût total',
                '${produit.calculerCout().toStringAsFixed(2)} USD',
                '${produit.calculerCoutCFA(tauxConversion).toStringAsFixed(0)} CFA',
                ),

        if (taxesUSD > 0 && produit.nombreCartons > 0) ...[
        SizedBox(height: 12),
        Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                color: Colors.orange.shade800,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: Colors.orange.shade600),
                          ),
        child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
        Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
        Text(
                'Prix revient/carton',
                style: TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.white,
                                    ),
                                  ),
        Text(
                'Avec taxes incluses',
                style: TextStyle(
                fontSize: 12,
                color: Colors.orange.shade100,
                                    ),
                                  ),
                                ],
                              ),
        Text(
                '${prixRevientAvecTaxes.toStringAsFixed(0)} CFA',
                style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResultCard(String title, String usdValue, String cfaValue) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.w500,
            color: Colors.white,
          ),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              usdValue,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.blue.shade300,
              ),
            ),
            Text(
              cfaValue,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade300,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildConfigurationAccordion() {
    return Container(
      margin: EdgeInsets.only(bottom: 12.0),
      decoration: BoxDecoration(
        color: Colors.grey[800],
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: ExpansionTile(
        initiallyExpanded: _configExpanded,
        onExpansionChanged: (bool expanded) {
          setState(() {
            _configExpanded = expanded;
          });
        },
        leading: Icon(Icons.settings, color: Colors.white),
        title: Text(
          'Configuration',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        trailing: Icon(
          _configExpanded ? Icons.expand_less : Icons.expand_more,
          color: Colors.white,
        ),
        children: [
          Container(
            color: Colors.grey[700],
            padding: EdgeInsets.all(16.0),
            child: Column(
              children: [
                TextField(
                  style: TextStyle(color: Colors.white),
                  controller: taxeController,
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                  decoration: InputDecoration(
                    labelText: 'Taxes et dédouanement (USD)',
                    labelStyle: TextStyle(color: Colors.grey[300]),
                    border: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey.shade500),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey.shade500),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.blue.shade300),
                    ),
                    prefixIcon: Icon(Icons.account_balance, size: 20, color: Colors.grey[300]),
                    hintText: 'Montant total en USD',
                    hintStyle: TextStyle(color: Colors.grey[400]),
                  ),
                  onChanged: (value) {
                    calculerPrixRevient();
                  },
                ),
                SizedBox(height: 12),
                TextField(
                  style: TextStyle(color: Colors.white),
                  controller: tauxConversionController,
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                  decoration: InputDecoration(
                    labelText: 'Taux de conversion (1 USD = X CFA)',
                    labelStyle: TextStyle(color: Colors.grey[300]),
                    border: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey.shade500),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey.shade500),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.blue.shade300),
                    ),
                    prefixIcon: Icon(Icons.currency_exchange, size: 20, color: Colors.grey[300]),
                    hintText: 'Ex: 655 pour 1 USD = 655 CFA',
                    hintStyle: TextStyle(color: Colors.grey[400]),
                  ),
                  onChanged: (value) {
                    calculerPrixRevient();
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResultsAccordion() {
    double coutTotalProduits = produits.fold(0.0, (sum, produit) => sum + produit.calculerCout());
    double poidsTotal = produits.fold(0.0, (sum, produit) => sum + produit.poidsTotal);
    double taxesUSD = double.tryParse(taxeController.text) ?? 0.0;
    double tauxConversion = double.tryParse(tauxConversionController.text) ?? 655.0;

    return Container(
      margin: EdgeInsets.only(bottom: 12.0),
      decoration: BoxDecoration(
        color: Colors.grey[800],
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: ExpansionTile(
        initiallyExpanded: _resultsExpanded,
        onExpansionChanged: (bool expanded) {
          setState(() {
            _resultsExpanded = expanded;
          });
        },
        leading: Icon(Icons.calculate, color: Colors.white),
        title: Text(
          'Résultats Globaux',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '${prixRevientTotalCFA.toStringAsFixed(0)} CFA',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            SizedBox(width: 8),
            Icon(
              _resultsExpanded ? Icons.expand_less : Icons.expand_more,
              color: Colors.white,
            ),
          ],
        ),
        children: [
          Container(
            color: Colors.grey[700],
            padding: EdgeInsets.all(16.0),
            child: Column(
              children: [
                _buildSummaryLine('Coût total produits:', '${coutTotalProduits.toStringAsFixed(2)} USD'),
                _buildSummaryLine('Poids total:', '${poidsTotal.toStringAsFixed(2)} kg'),
                _buildSummaryLine('Taxes et dédouanement:', '${taxesUSD.toStringAsFixed(2)} USD'),
                _buildSummaryLine('Taux de conversion:', '1 USD = ${tauxConversion.toStringAsFixed(0)} CFA'),
                Divider(height: 20, color: Colors.grey.shade500),
                _buildSummaryLine(
                  'Prix de revient total:',
                  '${prixRevientTotal.toStringAsFixed(2)} USD',
                  isTotal: true
                ),
                _buildSummaryLine(
                  'Prix de revient total:',
                  '${prixRevientTotalCFA.toStringAsFixed(0)} CFA',
                  isTotal: true,
                  isCFA: true
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryLine(String label, String value, {bool isTotal = false, bool isCFA = false}) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: isTotal ? 15 : 14,
              fontWeight: isTotal ? FontWeight.w600 : FontWeight.normal,
              color: Colors.white,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: isTotal ? 16 : 14,
              fontWeight: FontWeight.w600,
              color: isCFA ? Colors.orange.shade300 : (isTotal ? Colors.blue.shade300 : Colors.grey[300]),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[900],
      appBar: AppBar(
        title: Text(
          'Calculateur de Prix de Revient',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.grey[800],
        elevation: 0,
        actions: [
          Padding(
            padding: EdgeInsets.only(right: 16),
            child: ElevatedButton.icon(
              icon: Icon(Icons.add, size: 18),
              label: Text('Produit'),
              onPressed: ajouterProduit,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue.shade600,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // En-tête avec statistiques
          Container(
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            decoration: BoxDecoration(
              color: Colors.grey[800],
              boxShadow: [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 4,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatCard('Produits', produits.length.toString()),
                _buildStatCard('Poids Total', '${produits.fold(0.0, (sum, produit) => sum + produit.poidsTotal).toStringAsFixed(1)} kg'),
                _buildStatCard('Coût Total', '${produits.fold(0.0, (sum, produit) => sum + produit.calculerCout()).toStringAsFixed(0)} USD'),
              ],
            ),
          ),
          
          // Contenu principal
          Expanded(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: SingleChildScrollView(
                controller: _scrollController,
                child: Column(
                  children: [
                    // Liste des produits
                    Column(
                      children: List.generate(produits.length, (index) {
                        return _buildProduitAccordion(index);
                      }),
                    ),
                    
                    SizedBox(height: 16),
                    
                    // Configuration
                    _buildConfigurationAccordion(),
                    
                    SizedBox(height: 16),
                    
                    // Résultats
                    _buildResultsAccordion(),
                    
                    SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        SizedBox(height: 4),
        Text(
          title,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[300],
          ),
        ),
      ],
    );
  }
}

class ProduitControllers {
  final TextEditingController nomController;
  final TextEditingController prixParKiloController;
  final TextEditingController nombreCartonsController;
  final TextEditingController poidsCartonController;

  ProduitControllers({
    required this.nomController,
    required this.prixParKiloController,
    required this.nombreCartonsController,
    required this.poidsCartonController,
  });

  void dispose() {
    nomController.dispose();
    prixParKiloController.dispose();
    nombreCartonsController.dispose();
    poidsCartonController.dispose();
  }
}
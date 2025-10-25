import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../utils/app_theme.dart';

class DiseaseInfo {
  final String name;
  final String? symptoms;
  final String? cure;
  final String? tips;
  final String? status;

  DiseaseInfo({
    required this.name,
    this.symptoms,
    this.cure,
    this.tips,
    this.status,
  });
}

final List<DiseaseInfo> diseaseInfos = [
  DiseaseInfo(
    name: "Apple Apple Scab",
    symptoms: "Dark, velvety lesions on leaves and fruit; fruit may become deformed.",
    cure: "Prune infected twigs, remove fallen leaves, and apply fungicides in early spring.",
  ),
  DiseaseInfo(
    name: "Apple Black Rot",
    symptoms: "Concentric black rings on fruit, leaf spots, and cankers on branches.",
    cure: "Destroy affected fruit and limbs; apply sulfur-based sprays during early growth stages.",
  ),
  DiseaseInfo(
    name: "Apple Cedar Apple Rust",
    symptoms: "Bright orange or rust-colored spots on leaves and fruit.",
    cure: "Remove nearby cedar hosts and apply fungicide starting at bud break every 7–10 days.",
  ),
  DiseaseInfo(
    name: "Apple Healthy",
    status: "No visible signs of disease.",
    tips: "Practice regular pruning, seasonal fertilization, and apply preventive sprays annually.",
  ),
  DiseaseInfo(
    name: "Blueberry Healthy",
    status: "Plant is healthy and growing well.",
    tips: "Maintain pH at 4.5–5.5, use acidic fertilizer, and ensure proper drainage.",
  ),
  DiseaseInfo(
    name: "Cherry (incl. Sour) Powdery Mildew",
    symptoms: "White, powdery growth on leaves, stems, or fruit.",
    cure: "Improve airflow by pruning and apply sulfur or neem oil-based fungicides.",
  ),
  DiseaseInfo(
    name: "Cherry (incl. Sour) Healthy",
    status: "No signs of infection or stress.",
    tips: "Provide full sun, adequate watering, and annual pruning to maintain vigor.",
  ),
  DiseaseInfo(
    name: "Corn (Maize) Cercospora / Gray Leaf Spot",
    symptoms: "Narrow, tan-colored elongated lesions on lower leaves.",
    cure: "Rotate crops, remove debris, and plant resistant corn hybrids.",
  ),
  DiseaseInfo(
    name: "Corn (Maize) Common Rust",
    symptoms: "Small reddish-brown pustules on both leaf surfaces.",
    cure: "Apply fungicide early and use rust-resistant varieties.",
  ),
  DiseaseInfo(
    name: "Corn (Maize) Northern Leaf Blight",
    symptoms: "Long, gray-green lesions shaped like cigars.",
    cure: "Use resistant hybrids and apply fungicides at early symptom onset.",
  ),
  DiseaseInfo(
    name: "Corn (Maize) Healthy",
    status: "Plants are healthy and vigorous.",
    tips: "Monitor for pests, maintain soil fertility, and provide sufficient nitrogen.",
  ),
  DiseaseInfo(
    name: "Grape Black Rot",
    symptoms: "Circular brown leaf spots; fruit shrivels and turns black.",
    cure: "Remove and destroy affected vines and apply protective fungicide regularly.",
  ),
  DiseaseInfo(
    name: "Grape Esca (Black Measles)",
    symptoms: "Leaf streaking between veins, black fruit spots, vine decline.",
    cure: "Remove infected plants, prevent over-irrigation, and reduce vine stress.",
  ),
  DiseaseInfo(
    name: "Grape Leaf Blight (Isariopsis Leaf Spot)",
    symptoms: "Irregular brown leaf spots with yellowing.",
    cure: "Remove affected leaves and apply copper-based fungicides.",
  ),
  DiseaseInfo(
    name: "Grape Healthy",
    status: "Vines are productive and disease-free.",
    tips: "Provide proper trellising, humidity control, and seasonal pruning.",
  ),
  DiseaseInfo(
    name: "Orange Huanglongbing (Citrus Greening)",
    symptoms: "Yellow shoots, uneven fruit, premature drop.",
    cure: "Remove infected trees and control psyllids using systemic insecticides.",
  ),
  DiseaseInfo(
    name: "Peach Bacterial Spot",
    symptoms: "Dark, angular leaf spots with yellow halos; fruit lesions.",
    cure: "Apply copper-based bactericides and remove infected plant material.",
  ),
  DiseaseInfo(
    name: "Peach Healthy",
    status: "Trees are healthy and productive.",
    tips: "Prune annually, maintain soil pH 6.0–6.5, and provide adequate irrigation.",
  ),
  DiseaseInfo(
    name: "Bell Pepper Bacterial Spot",
    symptoms: "Small, dark, water-soaked leaf spots; fruit lesions.",
    cure: "Use disease-free seed, rotate crops, and apply copper-based sprays.",
  ),
  DiseaseInfo(
    name: "Bell Pepper Healthy",
    status: "Plants are vigorous and disease-free.",
    tips: "Provide consistent moisture, avoid overhead watering, and maintain good air circulation.",
  ),
  DiseaseInfo(
    name: "Potato Early Blight",
    symptoms: "Dark brown spots with concentric rings on leaves; target-like appearance.",
    cure: "Remove infected leaves, improve air circulation, and apply fungicides.",
  ),
  DiseaseInfo(
    name: "Potato Late Blight",
    symptoms: "Dark, water-soaked lesions on leaves and stems; white fungal growth.",
    cure: "Remove infected plants immediately and apply copper-based fungicides preventively.",
  ),
  DiseaseInfo(
    name: "Potato Healthy",
    status: "Plants are healthy and growing well.",
    tips: "Hill soil around plants, maintain consistent moisture, and monitor for pests.",
  ),
  DiseaseInfo(
    name: "Raspberry Healthy",
    status: "Canes are healthy and productive.",
    tips: "Prune old canes after fruiting, maintain good air circulation, and control weeds.",
  ),
  DiseaseInfo(
    name: "Soybean Healthy",
    status: "Plants are healthy and vigorous.",
    tips: "Rotate crops, maintain proper soil pH, and monitor for pests regularly.",
  ),
  DiseaseInfo(
    name: "Squash Powdery Mildew",
    symptoms: "White, powdery patches on leaves and stems.",
    cure: "Improve air circulation, avoid overhead watering, and apply fungicides.",
  ),
  DiseaseInfo(
    name: "Strawberry Healthy",
    status: "Plants are healthy and producing well.",
    tips: "Remove runners, maintain proper spacing, and apply balanced fertilizer.",
  ),
  DiseaseInfo(
    name: "Tomato Bacterial Spot",
    symptoms: "Small, dark, angular leaf spots; fruit lesions with raised edges.",
    cure: "Use disease-free seed, avoid overhead watering, and apply copper-based sprays.",
  ),
  DiseaseInfo(
    name: "Tomato Early Blight",
    symptoms: "Dark brown spots with concentric rings; target-like appearance on leaves.",
    cure: "Remove infected leaves, improve air circulation, and apply fungicides.",
  ),
  DiseaseInfo(
    name: "Tomato Late Blight",
    symptoms: "Dark, water-soaked lesions on leaves and stems; white fungal growth in humidity.",
    cure: "Remove infected plants immediately and apply copper-based fungicides preventively.",
  ),
  DiseaseInfo(
    name: "Tomato Leaf Mold",
    symptoms: "Yellow spots on upper leaf surfaces; olive-green mold on undersides.",
    cure: "Improve air circulation, reduce humidity, and apply fungicides.",
  ),
  DiseaseInfo(
    name: "Tomato Septoria Leaf Spot",
    symptoms: "Small, circular gray spots with dark borders on leaves.",
    cure: "Remove infected leaves, avoid overhead watering, and apply fungicides.",
  ),
  DiseaseInfo(
    name: "Tomato Spider Mites (Two-spotted Spider Mite)",
    symptoms: "Fine webbing on leaves; stippled, yellowing foliage.",
    cure: "Apply insecticidal soap or neem oil; increase humidity to deter mites.",
  ),
  DiseaseInfo(
    name: "Tomato Target Spot",
    symptoms: "Dark brown spots with concentric rings; similar to early blight.",
    cure: "Remove infected leaves, improve air circulation, and apply fungicides.",
  ),
  DiseaseInfo(
    name: "Tomato Yellow Leaf Curl Virus",
    symptoms: "Yellow, curled leaves; stunted growth; reduced fruit production.",
    cure: "Remove infected plants, control whiteflies, and use resistant varieties.",
  ),
  DiseaseInfo(
    name: "Tomato Mosaic Virus",
    symptoms: "Mottled or mosaic yellow-green leaf patterns, stunted growth, malformed fruit.",
    cure: "Uproot and destroy infected plants. Disinfect tools regularly. Do not smoke near tomato plants, as the virus can spread from tobacco products.",
  ),
  DiseaseInfo(
    name: "Tomato Healthy",
    status: "No signs of disease or stress.",
    tips: "Support plants with stakes or cages. Fertilize every 2–3 weeks with balanced tomato fertilizer. Water deeply and consistently at the soil level to prevent leaf diseases.",
  ),
];

class AboutScreen extends StatefulWidget {
  const AboutScreen({super.key});

  @override
  State<AboutScreen> createState() => _AboutScreenState();
}

class _AboutScreenState extends State<AboutScreen> {
  String searchQuery = '';
  String? selectedClass;

  List<String> get classOptions {
    final Set<String> classes = {};
    for (final d in diseaseInfos) {
      final match = RegExp(r'^[A-Za-z]+').firstMatch(d.name);
      if (match != null) classes.add(match.group(0)!);
    }
    return classes.toList()..sort();
  }

  List<DiseaseInfo> get filteredDiseases {
    return diseaseInfos.where((d) {
      final matchesSearch = searchQuery.isEmpty ||
          d.name.toLowerCase().startsWith(searchQuery.toLowerCase());
      final matchesClass = selectedClass == null ||
          d.name.toLowerCase().startsWith(selectedClass!.toLowerCase());
      return matchesSearch && matchesClass;
    }).toList();
  }

  void showFilterDialog() async {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    final result = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: isDark ? AppTheme.glassmorphismDark.color : AppTheme.glassmorphismLight.color,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          decoration: BoxDecoration(
            color: isDark ? AppTheme.glassmorphismDark.color : AppTheme.glassmorphismLight.color,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: ListView(
            children: [
              ListTile(
                title: Text(
                  'All',
                  style: TextStyle(
                    color: isDark ? Colors.white : Colors.black87,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                onTap: () => Navigator.pop(context, null),
              ),
              ...classOptions.map((c) => ListTile(
                title: Text(
                  c,
                  style: TextStyle(
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
                onTap: () => Navigator.pop(context, c),
              )),
            ],
          ),
        );
      },
    );
    if (result != null || result == null) {
      setState(() {
        selectedClass = result;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final isWide = MediaQuery.of(context).size.width > 700;
    
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: isDark ? AppTheme.cyberGradient : AppTheme.neonGradient,
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Futuristic App Bar
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: isDark ? AppTheme.glassmorphismDark.color : AppTheme.glassmorphismLight.color,
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(20),
                    bottomRight: Radius.circular(20),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: AppTheme.neonGradient,
                      ),
                      child: const Icon(
                        Icons.eco_rounded,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'About Leaf Diseases',
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: isDark ? Colors.white : Colors.black87,
                            ),
                          ),
                          Text(
                            'Comprehensive Disease Database',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: isDark ? Colors.white.withOpacity(0.8) : Colors.black54,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ).animate().slideY(begin: -0.3, duration: 600.ms, curve: Curves.easeOutCubic),

              // Search and Filter Section
              Container(
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isDark ? AppTheme.glassmorphismDark.color : AppTheme.glassmorphismLight.color,
                  borderRadius: BorderRadius.circular(20),
                  border: isDark ? AppTheme.glassmorphismDark.border : AppTheme.glassmorphismLight.border,
                ),
                child: Row(
                  children: [
                    Expanded(
                      flex: 3,
                      child: TextField(
                        style: TextStyle(
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                        decoration: InputDecoration(
                          hintText: 'Search leaf disease...',
                          hintStyle: TextStyle(
                            color: isDark ? Colors.white.withOpacity(0.6) : Colors.black54,
                          ),
                          prefixIcon: Icon(
                            Icons.search_rounded,
                            color: isDark ? Colors.white.withOpacity(0.6) : Colors.black54,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: isDark ? Colors.white.withOpacity(0.2) : Colors.black.withOpacity(0.1),
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: isDark ? Colors.white.withOpacity(0.2) : Colors.black.withOpacity(0.1),
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: AppTheme.neonGradient.colors.first,
                              width: 2,
                            ),
                          ),
                          filled: true,
                          fillColor: isDark ? Colors.white.withOpacity(0.1) : Colors.white.withOpacity(0.8),
                        ),
                        onChanged: (value) => setState(() => searchQuery = value),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 1,
                      child: ElevatedButton.icon(
                        onPressed: showFilterDialog,
                        icon: const Icon(Icons.filter_list_rounded),
                        label: const Text('Filter'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.neonGradient.colors.first,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                    ),
                  ],
                ),
              ).animate().fadeIn(duration: 600.ms, delay: 200.ms).slideY(begin: 0.3),

              // Disease Cards
              Expanded(
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  child: GridView.builder(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: isWide ? 2 : 1,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      childAspectRatio: 1.2,
                    ),
                    itemCount: filteredDiseases.length,
                    itemBuilder: (context, idx) {
                      final disease = filteredDiseases[idx];
                      final isHealthy = (disease.status?.toLowerCase().contains('healthy') ?? false) || 
                                      (disease.tips != null && disease.symptoms == null && disease.cure == null);
                      
                      return Container(
                        decoration: BoxDecoration(
                          color: isDark ? AppTheme.glassmorphismDark.color : AppTheme.glassmorphismLight.color,
                          borderRadius: BorderRadius.circular(20),
                          border: isDark ? AppTheme.glassmorphismDark.border : AppTheme.glassmorphismLight.border,
                          boxShadow: [
                            BoxShadow(
                              color: isHealthy 
                                ? const Color(0xFF10B981).withOpacity(0.2)
                                : AppTheme.neonGradient.colors[2].withOpacity(0.2),
                              blurRadius: 15,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: SingleChildScrollView(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                                                                 gradient: isHealthy 
                                           ? const LinearGradient(colors: [Color(0xFF10B981), Color(0xFF10B981)])
                                           : AppTheme.neonGradient,
                                      ),
                                      child: Icon(
                                        isHealthy ? Icons.eco_rounded : Icons.warning_amber_rounded,
                                        color: Colors.white,
                                        size: 20,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Text(
                                        disease.name,
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: isDark ? Colors.white : Colors.black87,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                if (disease.symptoms != null)
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Symptoms:',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14,
                                          color: isDark ? Colors.white : Colors.black87,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        disease.symptoms!,
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: isDark ? Colors.white.withOpacity(0.9) : Colors.black87,
                                        ),
                                      ),
                                    ],
                                  ),
                                if (disease.cure != null) ...[
                                  const SizedBox(height: 12),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Cure:',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14,
                                          color: isDark ? Colors.white : Colors.black87,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        disease.cure!,
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: isDark ? Colors.white.withOpacity(0.9) : Colors.black87,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                                if (disease.status != null) ...[
                                  const SizedBox(height: 12),
                                  Text(
                                    "Status: ${disease.status!}",
                                    style: TextStyle(
                                      fontSize: 14,
                                                                           color: isHealthy 
                                       ? const Color(0xFF10B981)
                                       : AppTheme.neonGradient.colors[2],
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                                if (disease.tips != null) ...[
                                  const SizedBox(height: 12),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Tips:',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14,
                                          color: isDark ? Colors.white : Colors.black87,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        disease.tips!,
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: isDark ? Colors.white.withOpacity(0.9) : Colors.black87,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ),
                      ).animate().fadeIn(duration: 400.ms, delay: (idx * 50).ms).scale(begin: const Offset(0.9, 0.9));
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
} 
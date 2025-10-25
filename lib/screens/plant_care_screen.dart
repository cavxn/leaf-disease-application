import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../utils/app_theme.dart';
import '../widgets/feature_card.dart';
import '../providers/plant_care_provider.dart';
import '../models/plant.dart';

class PlantCareScreen extends StatefulWidget {
  const PlantCareScreen({Key? key}) : super(key: key);

  @override
  State<PlantCareScreen> createState() => _PlantCareScreenState();
}

class _PlantCareScreenState extends State<PlantCareScreen> with TickerProviderStateMixin {
  late TabController _tabController;
  int _selectedPlantIndex = 0;


  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return Consumer<PlantCareProvider>(
      builder: (context, plantCareProvider, child) {
        final plants = plantCareProvider.plants;
        
        // Initialize sample data if plants list is empty
        if (plants.isEmpty) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            plantCareProvider.initializeSampleData();
          });
          
          return Scaffold(
            body: Container(
              decoration: BoxDecoration(
                gradient: isDark ? AppTheme.cyberGradient : AppTheme.neonGradient,
              ),
              child: SafeArea(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(
                        color: Colors.green,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Loading plant care data...',
                        style: TextStyle(
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        }
        
        return Scaffold(
          body: Container(
            decoration: BoxDecoration(
              gradient: isDark ? AppTheme.cyberGradient : AppTheme.neonGradient,
            ),
            child: SafeArea(
              child: Column(
                children: [
                  _buildHeader(isDark),
                  _buildPlantSelector(plants, isDark),
                  _buildTabBar(isDark),
                  Expanded(
                    child: _buildPlantDetails(plants, isDark),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isDark ? AppTheme.glassmorphismDark.color : AppTheme.glassmorphismLight.color,
              borderRadius: BorderRadius.circular(15),
              border: isDark ? AppTheme.glassmorphismDark.border : AppTheme.glassmorphismLight.border,
            ),
            child: const Icon(
              Icons.eco_rounded,
              color: Colors.green,
              size: 28,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Plant Care Guide',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
                Text(
                  'Expert tips for healthy plants',
                  style: TextStyle(
                    fontSize: 14,
                    color: isDark ? Colors.white.withOpacity(0.7) : Colors.black54,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 600.ms).slideX(begin: -0.3);
  }

  Widget _buildPlantSelector(List<Plant> plants, bool isDark) {
    return Container(
      height: 80,
      margin: const EdgeInsets.symmetric(horizontal: 20),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: plants.length,
        itemBuilder: (context, index) {
          final plant = plants[index];
          final isSelected = _selectedPlantIndex == index;
          
          return GestureDetector(
            onTap: () {
              setState(() {
                _selectedPlantIndex = index;
              });
            },
            child: Container(
              margin: const EdgeInsets.only(right: 12),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                gradient: isSelected 
                  ? LinearGradient(
                      colors: [Colors.green.withOpacity(0.3), Colors.green.withOpacity(0.1)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    )
                  : null,
                color: isSelected 
                  ? null
                  : (isDark ? AppTheme.glassmorphismDark.color : AppTheme.glassmorphismLight.color),
                borderRadius: BorderRadius.circular(20),
                border: isSelected 
                  ? Border.all(color: Colors.green, width: 2)
                  : Border.all(
                      color: isDark ? Colors.white.withOpacity(0.1) : Colors.black.withOpacity(0.1),
                      width: 1,
                    ),
                boxShadow: isSelected ? [
                  BoxShadow(
                    color: Colors.green.withOpacity(0.3),
                    blurRadius: 8,
                    spreadRadius: 2,
                  ),
                ] : null,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    plant.image,
                    style: TextStyle(
                      fontSize: 28,
                      shadows: isSelected ? [
                        Shadow(
                          color: Colors.green.withOpacity(0.5),
                          blurRadius: 4,
                        ),
                      ] : null,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    plant.name,
                    style: TextStyle(
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                      color: isDark ? Colors.white : Colors.black87,
                      fontSize: 12,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ).animate().scale(duration: 200.ms).then().fadeIn(duration: 300.ms);
        },
      ),
    ).animate().fadeIn(duration: 800.ms).slideY(begin: 0.3);
  }

  Widget _buildTabBar(bool isDark) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.glassmorphismDark.color : AppTheme.glassmorphismLight.color,
        borderRadius: BorderRadius.circular(15),
        border: isDark ? AppTheme.glassmorphismDark.border : AppTheme.glassmorphismLight.border,
      ),
      child: TabBar(
        controller: _tabController,
        indicator: BoxDecoration(
          color: Colors.green.withOpacity(0.2),
          borderRadius: BorderRadius.circular(12),
        ),
        labelColor: Colors.green,
        unselectedLabelColor: isDark ? Colors.white.withOpacity(0.6) : Colors.black54,
        labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
        unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.normal, fontSize: 12),
        tabs: const [
          Tab(text: 'Info'),
          Tab(text: 'Watering'),
          Tab(text: 'Lighting'),
          Tab(text: 'Tips'),
        ],
      ),
    );
  }

  Widget _buildPlantDetails(List<Plant> plants, bool isDark) {
    final plant = plants[_selectedPlantIndex];
    
    return Container(
      margin: const EdgeInsets.all(20),
      child: TabBarView(
        controller: _tabController,
        children: [
          _buildCareInfo(plant, isDark),
          _buildWateringGuide(plant, isDark),
          _buildLightingGuide(plant, isDark),
          _buildTipsGuide(plant, isDark),
        ],
      ),
    );
  }

  Widget _buildCareInfo(Plant plant, bool isDark) {
    return SingleChildScrollView(
      child: Column(
        children: [
          _buildInfoCard(
            '🌱 Basic Information',
            [
              _buildInfoRow('Scientific Name', plant.scientificName),
              _buildInfoRow('Care Level', plant.careLevel),
              _buildInfoRow('Watering', plant.wateringFrequency),
              _buildInfoRow('Light', plant.lightRequirement),
            ],
            isDark,
          ),
          const SizedBox(height: 16),
          _buildInfoCard(
            '🌡️ Environment',
            [
              _buildInfoRow('Temperature', plant.temperature),
              _buildInfoRow('Humidity', plant.humidity),
              _buildInfoRow('Fertilizing', plant.fertilizing),
              _buildInfoRow('Repotting', plant.repotting),
            ],
            isDark,
          ),
          const SizedBox(height: 16),
          _buildFunFactsCard(plant, isDark),
          const SizedBox(height: 16),
          _buildSeasonalCareCard(plant, isDark),
        ],
      ),
    );
  }

  Widget _buildWateringGuide(Plant plant, bool isDark) {
    return SingleChildScrollView(
      child: Column(
        children: [
          _buildGuideCard(
            '💧 Watering Schedule',
            'Water every ${plant.wateringFrequency.toLowerCase()}',
            Icons.water_drop,
            Colors.blue,
            isDark,
          ),
          const SizedBox(height: 16),
          _buildGuideCard(
            '⚠️ Signs of Overwatering',
            'Yellow leaves, mushy stems, soil that stays wet',
            Icons.warning,
            Colors.orange,
            isDark,
          ),
          const SizedBox(height: 16),
          _buildGuideCard(
            '🌵 Signs of Underwatering',
            'Wilting, dry soil, brown leaf tips',
            Icons.dry_cleaning,
            Colors.red,
            isDark,
          ),
          const SizedBox(height: 16),
          _buildGuideCard(
            '💡 Pro Watering Tips',
            'Check soil moisture with your finger - if it\'s dry 1-2 inches down, it\'s time to water!',
            Icons.lightbulb,
            Colors.purple,
            isDark,
          ),
        ],
      ),
    );
  }

  Widget _buildLightingGuide(Plant plant, bool isDark) {
    return SingleChildScrollView(
      child: Column(
        children: [
          _buildGuideCard(
            '☀️ Light Requirements',
            plant.lightRequirement,
            Icons.wb_sunny,
            Colors.amber,
            isDark,
          ),
          const SizedBox(height: 16),
          _buildGuideCard(
            '📍 Best Placement',
            'Near windows with bright, indirect light',
            Icons.location_on,
            Colors.green,
            isDark,
          ),
          const SizedBox(height: 16),
          _buildGuideCard(
            '🔄 Light Rotation',
            'Rotate plant weekly for even growth',
            Icons.rotate_right,
            Colors.purple,
            isDark,
          ),
          const SizedBox(height: 16),
          _buildGuideCard(
            '🌅 Morning vs Evening Light',
            'Morning light is gentler and better for most plants than harsh afternoon sun',
            Icons.wb_twilight,
            Colors.indigo,
            isDark,
          ),
        ],
      ),
    );
  }

  Widget _buildTipsGuide(Plant plant, bool isDark) {
    return SingleChildScrollView(
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: isDark ? AppTheme.glassmorphismDark.color : AppTheme.glassmorphismLight.color,
              borderRadius: BorderRadius.circular(20),
              border: isDark ? AppTheme.glassmorphismDark.border : AppTheme.glassmorphismLight.border,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.lightbulb,
                        color: Colors.green,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Expert Tips',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                ...plant.tips.map((tip) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        margin: const EdgeInsets.only(top: 6),
                        width: 6,
                        height: 6,
                        decoration: const BoxDecoration(
                          color: Colors.green,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          tip,
                          style: TextStyle(
                            color: isDark ? Colors.white.withOpacity(0.8) : Colors.black54,
                          ),
                        ),
                      ),
                    ],
                  ),
                )),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard(String title, List<Widget> children, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.glassmorphismDark.color : AppTheme.glassmorphismLight.color,
        borderRadius: BorderRadius.circular(20),
        border: isDark ? AppTheme.glassmorphismDark.border : AppTheme.glassmorphismLight.border,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: isDark ? Colors.white.withOpacity(0.8) : Colors.black54,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGuideCard(String title, String description, IconData icon, Color color, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.glassmorphismDark.color : AppTheme.glassmorphismLight.color,
        borderRadius: BorderRadius.circular(20),
        border: isDark ? AppTheme.glassmorphismDark.border : AppTheme.glassmorphismLight.border,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  color: color,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            description,
            style: TextStyle(
              color: isDark ? Colors.white.withOpacity(0.8) : Colors.black54,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFunFactsCard(Plant plant, bool isDark) {
    final funFacts = _getFunFacts(plant.name);
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.purple.withOpacity(0.1), Colors.pink.withOpacity(0.1)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        color: isDark ? AppTheme.glassmorphismDark.color : AppTheme.glassmorphismLight.color,
        borderRadius: BorderRadius.circular(20),
        border: isDark ? AppTheme.glassmorphismDark.border : AppTheme.glassmorphismLight.border,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.purple.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.auto_awesome,
                  color: Colors.purple,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                '🌟 Fun Facts',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...funFacts.map((fact) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  margin: const EdgeInsets.only(top: 6),
                  width: 6,
                  height: 6,
                  decoration: const BoxDecoration(
                    color: Colors.purple,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    fact,
                    style: TextStyle(
                      color: isDark ? Colors.white.withOpacity(0.8) : Colors.black54,
                    ),
                  ),
                ),
              ],
            ),
          )),
        ],
      ),
    );
  }

  Widget _buildSeasonalCareCard(Plant plant, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.orange.withOpacity(0.1), Colors.yellow.withOpacity(0.1)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        color: isDark ? AppTheme.glassmorphismDark.color : AppTheme.glassmorphismLight.color,
        borderRadius: BorderRadius.circular(20),
        border: isDark ? AppTheme.glassmorphismDark.border : AppTheme.glassmorphismLight.border,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.calendar_today,
                  color: Colors.orange,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                '📅 Seasonal Care',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildSeasonalInfo('🌱 Spring', 'Time for repotting and increased watering', Colors.green, isDark),
          const SizedBox(height: 8),
          _buildSeasonalInfo('☀️ Summer', 'Monitor for pests and provide extra humidity', Colors.orange, isDark),
          const SizedBox(height: 8),
          _buildSeasonalInfo('🍂 Fall', 'Reduce watering and prepare for dormancy', Colors.brown, isDark),
          const SizedBox(height: 8),
          _buildSeasonalInfo('❄️ Winter', 'Minimal watering and protect from drafts', Colors.blue, isDark),
        ],
      ),
    );
  }

  Widget _buildSeasonalInfo(String season, String care, Color color, bool isDark) {
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: RichText(
            text: TextSpan(
              style: TextStyle(
                color: isDark ? Colors.white.withOpacity(0.8) : Colors.black54,
                fontSize: 14,
              ),
              children: [
                TextSpan(
                  text: '$season: ',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
                TextSpan(text: care),
              ],
            ),
          ),
        ),
      ],
    );
  }

  List<String> _getFunFacts(String plantName) {
    switch (plantName.toLowerCase()) {
      case 'apple':
        return [
          'There are over 7,500 apple varieties worldwide',
          'Apples can help keep you awake better than caffeine',
          'The science of apple growing is called pomology',
          'Apple trees can live for over 100 years',
        ];
      case 'blueberry':
        return [
          'Native to North America',
          'One of the few fruits native to the US',
          'High in antioxidants and vitamin C',
          'Can live for 50+ years',
        ];
      case 'cherry':
        return [
          'Cherry blossoms are Japan\'s national flower',
          'Cherry pits contain cyanide compounds',
          'Sweet cherries are for eating, sour for cooking',
          'Cherry trees can live for centuries',
        ];
      case 'orange':
        return [
          'Oranges are actually berries!',
          'Brazil produces 1/3 of the world\'s oranges',
          'Orange peels contain more vitamin C than the fruit',
          'Orange trees can live for 100+ years',
        ];
      case 'peach':
        return [
          'Peaches are members of the rose family',
          'Georgia is called the Peach State',
          'Peach trees are self-pollinating',
          'Peaches originated in China over 8,000 years ago',
        ];
      case 'raspberry':
        return [
          'Raspberries are not true berries',
          'Each raspberry is made of many tiny fruits',
          'Raspberry leaves can be used for tea',
          'Raspberries are high in fiber and vitamin C',
        ];
      case 'strawberry':
        return [
          'Strawberries are the only fruit with seeds on the outside',
          'Ancient Romans used strawberries for medicinal purposes',
          'Strawberries are members of the rose family',
          'One strawberry plant can produce 200+ berries',
        ];
      case 'corn (maize)':
        return [
          'Corn is a type of grass',
          'Each corn plant has both male and female flowers',
          'Corn is used in over 3,000 products',
          'Native Americans called it "maize"',
        ];
      case 'bell pepper':
        return [
          'Bell peppers are actually fruits, not vegetables',
          'Green peppers are just unripe red peppers',
          'Bell peppers have more vitamin C than oranges',
          'All bell peppers start green and change color',
        ];
      case 'potato':
        return [
          'Potatoes are 80% water',
          'The potato was first cultivated in Peru',
          'Potatoes are the world\'s fourth-largest food crop',
          'There are over 4,000 potato varieties',
        ];
      case 'soybean':
        return [
          'Soybeans are 50% protein',
          'Soybeans can fix nitrogen in soil',
          'Soybeans are used in over 1,000 products',
          'Soybeans are native to East Asia',
        ];
      case 'squash':
        return [
          'Squash are one of the "Three Sisters" crops',
          'Squash flowers are edible',
          'Squash can be stored for months',
          'Squash are native to the Americas',
        ];
      case 'tomato':
        return [
          'Tomatoes are actually fruits, not vegetables',
          'Tomatoes were once thought to be poisonous',
          'There are over 10,000 tomato varieties',
          'Tomatoes are 95% water',
        ];
      case 'grape':
        return [
          'Grapes are one of the oldest cultivated fruits',
          'Grape vines can live for over 100 years',
          'Grapes are 80% water',
          'Wine grapes are different from table grapes',
        ];
      default:
        return [
          'Every plant is unique and special!',
          'Plants can improve your mood',
          'They help purify the air',
          'Caring for plants reduces stress',
        ];
    }
  }
}


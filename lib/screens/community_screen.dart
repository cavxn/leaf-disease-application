import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../utils/app_theme.dart';

class CommunityScreen extends StatefulWidget {
  const CommunityScreen({super.key});

  @override
  State<CommunityScreen> createState() => _CommunityScreenState();
}

class _CommunityScreenState extends State<CommunityScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

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

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Community',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppTheme.neonGradient.colors.first,
          labelColor: isDark ? Colors.white : Colors.black87,
          unselectedLabelColor: isDark ? Colors.white.withOpacity(0.5) : Colors.black54,
          isScrollable: true,
          tabs: const [
            Tab(text: 'Questions'),
            Tab(text: 'Tips'),
            Tab(text: 'ID Requests'),
            Tab(text: 'Reviews'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _QuestionsTab(),
          _TipsTab(),
          _IdRequestsTab(),
          _ReviewsTab(),
        ],
      ),
    );
  }
}

class _QuestionsTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: AppTheme.neonGradient,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              children: [
                const Icon(Icons.help_outline_rounded, size: 48, color: Colors.white),
                const SizedBox(height: 16),
                Text(
                  'Post Questions',
                  style: theme.textTheme.titleLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Ask the community about plant diseases and treatments',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),
              ],
            ),
          ).animate().fadeIn().slideY(begin: -0.3),

          const SizedBox(height: 24),

          // Post Question Button
          ElevatedButton.icon(
            onPressed: () => _showPostQuestionDialog(context),
            icon: const Icon(Icons.add_circle_outline_rounded),
            label: const Text('Ask a Question'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.neonGradient.colors.first,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.3),

          const SizedBox(height: 24),

          // Recent Questions
          ...List.generate(3, (index) => _QuestionCard(index: index))
              .map((card) => card.animate().fadeIn(delay: (300 + (card.index * 100)).ms))
        ],
      ),
    );
  }

  void _showPostQuestionDialog(BuildContext context) {
    final controller = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Post a Question'),
        content: TextField(
          controller: controller,
          maxLines: 5,
          decoration: const InputDecoration(
            hintText: 'Ask your question here...',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Question posted successfully!')),
              );
            },
            child: const Text('Post'),
          ),
        ],
      ),
    );
  }
}

class _QuestionCard extends StatelessWidget {
  final int index;

  const _QuestionCard({required this.index});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
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
              CircleAvatar(
                backgroundColor: AppTheme.neonGradient.colors[index % AppTheme.neonGradient.colors.length],
                child: const Icon(Icons.person, color: Colors.white),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Plant Lover ${index + 1}',
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                  Text(
                    '2 hours ago',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: isDark ? Colors.white.withOpacity(0.6) : Colors.black54,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            _getQuestionText(index),
            style: theme.textTheme.bodyLarge?.copyWith(
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.comment_outlined),
                onPressed: () {},
              ),
              Text('${5 + index}'),
              const SizedBox(width: 20),
              IconButton(
                icon: const Icon(Icons.favorite_outline),
                onPressed: () {},
              ),
              Text('${10 + index}'),
              const Spacer(),
              Chip(
                label: Text(_getQuestionTag(index)),
                backgroundColor: AppTheme.neonGradient.colors[index % AppTheme.neonGradient.colors.length].withOpacity(0.2),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _getQuestionText(int index) {
    final questions = [
      'How do I treat black spots on my roses?',
      'What\'s the best fertilizer for tomato plants?',
      'Why are my leaves turning yellow?',
    ];
    return questions[index % questions.length];
  }

  String _getQuestionTag(int index) {
    final tags = ['Treatment', 'Care Tips', 'Diagnosis'];
    return tags[index % tags.length];
  }
}

class _TipsTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.green.shade400, Colors.green.shade600],
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              children: [
                const Icon(Icons.lightbulb_outline_rounded, size: 48, color: Colors.white),
                const SizedBox(height: 16),
                Text(
                  'Share Care Tips',
                  style: theme.textTheme.titleLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Share your plant care expertise with the community',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),
              ],
            ),
          ).animate().fadeIn().slideY(begin: -0.3),

          const SizedBox(height: 24),

          ElevatedButton.icon(
            onPressed: () => _showShareTipDialog(context),
            icon: const Icon(Icons.add_circle_outline_rounded),
            label: const Text('Share a Tip'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.3),

          const SizedBox(height: 24),

          ...List.generate(3, (index) => _TipCard(index: index))
              .map((card) => card.animate().fadeIn(delay: (300 + (card.index * 100)).ms)),
        ],
      ),
    );
  }

  void _showShareTipDialog(BuildContext context) {
    final controller = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Share a Care Tip'),
        content: TextField(
          controller: controller,
          maxLines: 5,
          decoration: const InputDecoration(
            hintText: 'Share your plant care tip...',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Tip shared successfully!')),
              );
            },
            child: const Text('Share'),
          ),
        ],
      ),
    );
  }
}

class _TipCard extends StatelessWidget {
  final int index;

  const _TipCard({required this.index});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final tips = [
      ('Water your plants in the morning', 'Morning watering helps prevent fungus and allows plants to absorb water throughout the day.'),
      ('Prune regularly', 'Regular pruning promotes healthy growth and prevents disease spread in your plants.'),
      ('Check soil before watering', 'Stick your finger 1 inch into the soil. If it\'s dry, water your plant.'),
    ];

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
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
                child: const Icon(Icons.lightbulb, color: Colors.green),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  tips[index % tips.length].$1,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            tips[index % tips.length].$2,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: isDark ? Colors.white.withOpacity(0.8) : Colors.black54,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Text(
                'by Plant Enthusiast ${index + 1}',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: isDark ? Colors.white.withOpacity(0.6) : Colors.black54,
                ),
              ),
              const Spacer(),
              Row(
                children: [
                  Icon(Icons.star, size: 16, color: Colors.amber),
                  Text(
                    '${4.0 + index * 0.5}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _IdRequestsTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.purple.shade400, Colors.purple.shade600],
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              children: [
                const Icon(Icons.search, size: 48, color: Colors.white),
                const SizedBox(height: 16),
                Text(
                  'Request Identification',
                  style: theme.textTheme.titleLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Get help identifying unknown plants or diseases',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),
              ],
            ),
          ).animate().fadeIn().slideY(begin: -0.3),

          const SizedBox(height: 24),

          ElevatedButton.icon(
            onPressed: () => _showIdRequestDialog(context),
            icon: const Icon(Icons.add_photo_alternate_outlined),
            label: const Text('Request ID'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.purple,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.3),

          const SizedBox(height: 24),

          ...List.generate(2, (index) => _IdRequestCard(index: index))
              .map((card) => card.animate().fadeIn(delay: (300 + (card.index * 100)).ms)),
        ],
      ),
    );
  }

  void _showIdRequestDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Request Identification'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.image_outlined, size: 64, color: Colors.purple),
            const SizedBox(height: 16),
            const Text('Upload a photo of the plant or leaf you want to identify'),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.pop(context);
                // TODO: Implement image picker
              },
              icon: const Icon(Icons.add_photo_alternate),
              label: const Text('Choose Photo'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }
}

class _IdRequestCard extends StatelessWidget {
  final int index;

  const _IdRequestCard({required this.index});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.glassmorphismDark.color : AppTheme.glassmorphismLight.color,
        borderRadius: BorderRadius.circular(20),
        border: isDark ? AppTheme.glassmorphismDark.border : AppTheme.glassmorphismLight.border,
      ),
      child: Row(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: Colors.purple.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.image, color: Colors.purple),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Unknown plant ${index + 1}',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Posted 5 hours ago',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: isDark ? Colors.white.withOpacity(0.6) : Colors.black54,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.comment_outlined, size: 16, color: Colors.purple),
                    Text(' ${3 + index} suggestions', style: theme.textTheme.bodySmall),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ReviewsTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.orange.shade400, Colors.orange.shade600],
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              children: [
                const Icon(Icons.star_outline_rounded, size: 48, color: Colors.white),
                const SizedBox(height: 16),
                Text(
                  'Rate Advice',
                  style: theme.textTheme.titleLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Help others by rating helpful advice',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),
              ],
            ),
          ).animate().fadeIn().slideY(begin: -0.3),

          const SizedBox(height: 24),

          ...List.generate(3, (index) => _ReviewCard(index: index))
              .map((card) => card.animate().fadeIn(delay: (200 + (card.index * 100)).ms)),
        ],
      ),
    );
  }
}

class _ReviewCard extends StatelessWidget {
  final int index;

  const _ReviewCard({required this.index});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
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
              CircleAvatar(
                backgroundColor: Colors.orange.withOpacity(0.2),
                child: const Icon(Icons.person, color: Colors.orange),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Expert ${index + 1}',
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                    ),
                    Row(
                      children: List.generate(
                        5,
                        (i) => Icon(
                          i < (4 + index % 2) ? Icons.star : Icons.star_border,
                          size: 16,
                          color: Colors.amber,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Chip(
                label: Text('Tip ${index + 1}'),
                backgroundColor: Colors.orange.withOpacity(0.2),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Very helpful advice! ${index + 1}st time trying this and it worked perfectly.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}

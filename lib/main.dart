import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';

void main() {
  runApp(const TinyTailsApp());
}

class TinyTailsApp extends StatelessWidget {
  const TinyTailsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Tiny Tails',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFFFF9F0),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF34785A),
          surface: const Color(0xFFFFF9F0),
        ),
        fontFamily: 'Roboto',
      ),
      home: const AnimalHomePage(),
    );
  }
}

class Animal {
  const Animal({
    required this.name,
    required this.emoji,
    required this.sound,
    required this.category,
    required this.color,
  });

  final String name;
  final String emoji;
  final String sound;
  final String category;
  final Color color;

  String get soundSentence => '$sound, says the $name.';
}

const animals = <Animal>[
  Animal(
    name: 'Cow',
    emoji: '🐮',
    sound: 'Moo',
    category: 'Farm',
    color: Color(0xFFEAF2FF),
  ),
  Animal(
    name: 'Dog',
    emoji: '🐶',
    sound: 'Woof',
    category: 'Pets',
    color: Color(0xFFFFEBD8),
  ),
  Animal(
    name: 'Cat',
    emoji: '🐱',
    sound: 'Meow',
    category: 'Pets',
    color: Color(0xFFFFE4EC),
  ),
  Animal(
    name: 'Lion',
    emoji: '🦁',
    sound: 'Roar',
    category: 'Wild',
    color: Color(0xFFFFF0C9),
  ),
  Animal(
    name: 'Duck',
    emoji: '🦆',
    sound: 'Quack',
    category: 'Birds',
    color: Color(0xFFE3F4E9),
  ),
  Animal(
    name: 'Sheep',
    emoji: '🐑',
    sound: 'Baa',
    category: 'Farm',
    color: Color(0xFFF0E8FF),
  ),
  Animal(
    name: 'Elephant',
    emoji: '🐘',
    sound: 'Toot',
    category: 'Wild',
    color: Color(0xFFE3F3F4),
  ),
  Animal(
    name: 'Owl',
    emoji: '🦉',
    sound: 'Hoot',
    category: 'Birds',
    color: Color(0xFFFFE9D8),
  ),
  Animal(
    name: 'Pig',
    emoji: '🐷',
    sound: 'Oink',
    category: 'Farm',
    color: Color(0xFFFFE4EC),
  ),
  Animal(
    name: 'Monkey',
    emoji: '🐵',
    sound: 'Ooh-ooh',
    category: 'Wild',
    color: Color(0xFFF3E8D6),
  ),
  Animal(
    name: 'Rooster',
    emoji: '🐓',
    sound: 'Cock-a-doodle-doo',
    category: 'Farm',
    color: Color(0xFFFFF0C9),
  ),
  Animal(
    name: 'Frog',
    emoji: '🐸',
    sound: 'Ribbit',
    category: 'Wild',
    color: Color(0xFFE3F4E9),
  ),
];

const categories = ['All', 'Farm', 'Wild', 'Pets', 'Birds'];
const ink = Color(0xFF263B32);
const mutedInk = Color(0xFF758078);
const leafGreen = Color(0xFF34785A);

class AnimalHomePage extends StatefulWidget {
  const AnimalHomePage({super.key});

  @override
  State<AnimalHomePage> createState() => _AnimalHomePageState();
}

class _AnimalHomePageState extends State<AnimalHomePage> {
  final FlutterTts _tts = FlutterTts();
  final Set<String> _favorites = {};
  String _selectedCategory = 'All';
  bool _showFavorites = false;

  List<Animal> get _visibleAnimals => animals.where((animal) {
        final matchesCategory =
            _selectedCategory == 'All' || animal.category == _selectedCategory;
        final matchesFavorite =
            !_showFavorites || _favorites.contains(animal.name);
        return matchesCategory && matchesFavorite;
      }).toList();

  Future<void> _speak(String words) async {
    try {
      await _tts.stop();
      await _tts.setLanguage('en-US');
      await _tts.setSpeechRate(0.42);
      await _tts.speak(words);
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not play the sound: $error')),
      );
    }
  }

  void _toggleFavorite(Animal animal) {
    setState(() {
      if (!_favorites.add(animal.name)) {
        _favorites.remove(animal.name);
      }
    });
  }

  void _openAnimal(Animal animal) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => _AnimalDetailSheet(
        animal: animal,
        isFavorite: _favorites.contains(animal.name),
        onFavorite: () => _toggleFavorite(animal),
        onSpeak: () => _speak(animal.soundSentence),
      ),
    );
  }

  void _openQuiz() {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => _AnimalQuizSheet(onSpeak: _speak),
    );
  }

  @override
  void dispose() {
    _tts.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final visibleAnimals = _visibleAnimals;

    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 14, 20, 30),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  _buildHeader(),
                  const SizedBox(height: 22),
                  _buildHeroCard(),
                  const SizedBox(height: 26),
                  _buildSectionTitle(),
                  const SizedBox(height: 14),
                  _buildCategoryFilters(),
                  const SizedBox(height: 19),
                  _buildAnimalGrid(visibleAnimals),
                  if (visibleAnimals.isEmpty) _buildEmptyState(),
                  const SizedBox(height: 24),
                  _buildQuizBanner(),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: const BoxDecoration(
            color: Color(0xFFFFE9B8),
            shape: BoxShape.circle,
          ),
          alignment: Alignment.center,
          child: const Text('🐻', style: TextStyle(fontSize: 28)),
        ),
        const SizedBox(width: 11),
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Tiny Tails',
                style: TextStyle(
                  color: ink,
                  fontSize: 21,
                  fontWeight: FontWeight.w800,
                  height: 1.1,
                ),
              ),
              SizedBox(height: 3),
              Text(
                'BIG sounds, little learners',
                style: TextStyle(
                  color: mutedInk,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
        IconButton.filledTonal(
          tooltip: _showFavorites ? 'Show all animals' : 'Show favorites',
          onPressed: () => setState(() => _showFavorites = !_showFavorites),
          style: IconButton.styleFrom(
            backgroundColor:
                _showFavorites ? const Color(0xFFFFE1E5) : Colors.white,
            foregroundColor:
                _showFavorites ? const Color(0xFFD94F68) : leafGreen,
            fixedSize: const Size(46, 46),
          ),
          icon: Icon(_showFavorites ? Icons.favorite : Icons.favorite_border),
        ),
      ],
    );
  }

  Widget _buildHeroCard() {
    return Container(
      height: 190,
      padding: const EdgeInsets.fromLTRB(22, 21, 12, 18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF34785A), Color(0xFF4D9870)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(26),
      ),
      child: Stack(
        children: [
          Positioned(
            right: -3,
            bottom: -7,
            child: Text(
              '🦊🐼',
              style: TextStyle(
                fontSize: 71,
                shadows: [
                  Shadow(
                    color: Colors.black.withOpacity(0.12),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            top: 0,
            right: 12,
            child: Icon(
              Icons.auto_awesome,
              size: 23,
              color: Colors.white.withOpacity(0.55),
            ),
          ),
          SizedBox(
            width: 210,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.17),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    'LET’S EXPLORE!',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      letterSpacing: 1.1,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                const SizedBox(height: 13),
                const Text(
                  'Who makes\nthat sound?',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 26,
                    height: 1.12,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 9),
                Text(
                  'Meet your new animal friends!',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.86),
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle() {
    return Row(
      children: [
        Expanded(
          child: Text(
            _showFavorites ? 'Your favorites' : 'Meet the animals',
            style: const TextStyle(
              color: ink,
              fontSize: 20,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        Text(
          '${_visibleAnimals.length} friends',
          style: const TextStyle(
            color: mutedInk,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryFilters() {
    return SizedBox(
      height: 38,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        separatorBuilder: (context, index) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final category = categories[index];
          final selected = _selectedCategory == category;
          return ChoiceChip(
            label: Text(category),
            selected: selected,
            showCheckmark: false,
            onSelected: (_) => setState(() => _selectedCategory = category),
            labelStyle: TextStyle(
              color: selected ? Colors.white : const Color(0xFF58635C),
              fontWeight: FontWeight.w700,
              fontSize: 12,
            ),
            backgroundColor: Colors.white,
            selectedColor: leafGreen,
            side: BorderSide(
              color: selected ? leafGreen : const Color(0xFFEEECE5),
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 7),
          );
        },
      ),
    );
  }

  Widget _buildAnimalGrid(List<Animal> visibleAnimals) {
    return GridView.builder(
      itemCount: visibleAnimals.length,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.93,
      ),
      itemBuilder: (context, index) {
        final animal = visibleAnimals[index];
        return _AnimalCard(
          animal: animal,
          isFavorite: _favorites.contains(animal.name),
          onTap: () => _openAnimal(animal),
          onSpeak: () => _speak(animal.soundSentence),
          onFavorite: () => _toggleFavorite(animal),
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 30),
      child: Column(
        children: [
          const Text('🐾', style: TextStyle(fontSize: 42)),
          const SizedBox(height: 8),
          Text(
            _showFavorites
                ? 'Tap a heart to save a favorite!'
                : 'No animals in this group yet.',
            style: const TextStyle(color: mutedInk, fontSize: 14),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildQuizBanner() {
    return Material(
      color: const Color(0xFFFFEFC8),
      borderRadius: BorderRadius.circular(22),
      child: InkWell(
        onTap: _openQuiz,
        borderRadius: BorderRadius.circular(22),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 17, vertical: 15),
          child: Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: const BoxDecoration(
                  color: Color(0xFFFFD978),
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: const Icon(
                  Icons.lightbulb_rounded,
                  color: Color(0xFF795B19),
                  size: 25,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Ready to play?',
                      style: TextStyle(
                        color: ink,
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    SizedBox(height: 3),
                    Text(
                      'Guess who makes the sound!',
                      style: TextStyle(color: mutedInk, fontSize: 11),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_rounded, color: ink, size: 21),
            ],
          ),
        ),
      ),
    );
  }
}

class _AnimalCard extends StatelessWidget {
  const _AnimalCard({
    required this.animal,
    required this.isFavorite,
    required this.onTap,
    required this.onSpeak,
    required this.onFavorite,
  });

  final Animal animal;
  final bool isFavorite;
  final VoidCallback onTap;
  final VoidCallback onSpeak;
  final VoidCallback onFavorite;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(22),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(22),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 11, 12, 11),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  InkWell(
                    onTap: onFavorite,
                    customBorder: const CircleBorder(),
                    child: Padding(
                      padding: const EdgeInsets.all(4),
                      child: Icon(
                        isFavorite ? Icons.favorite : Icons.favorite_border,
                        size: 18,
                        color: isFavorite
                            ? const Color(0xFFE76B7D)
                            : const Color(0xFFB7BEB8),
                      ),
                    ),
                  ),
                ],
              ),
              Expanded(
                child: Container(
                  width: double.infinity,
                  margin: const EdgeInsets.only(top: 1, bottom: 8),
                  decoration: BoxDecoration(
                    color: animal.color,
                    borderRadius: BorderRadius.circular(17),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    animal.emoji,
                    style: const TextStyle(fontSize: 57),
                  ),
                ),
              ),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          animal.name,
                          style: const TextStyle(
                            color: ink,
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '"${animal.sound}!"',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: mutedInk,
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 4),
                  SizedBox(
                    width: 34,
                    height: 34,
                    child: IconButton.filled(
                      onPressed: onSpeak,
                      tooltip: 'Hear the ${animal.name.toLowerCase()}',
                      padding: EdgeInsets.zero,
                      style: IconButton.styleFrom(
                        backgroundColor: const Color(0xFFE8F2EB),
                        foregroundColor: leafGreen,
                      ),
                      icon: const Icon(Icons.volume_up_rounded, size: 18),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AnimalDetailSheet extends StatefulWidget {
  const _AnimalDetailSheet({
    required this.animal,
    required this.isFavorite,
    required this.onFavorite,
    required this.onSpeak,
  });

  final Animal animal;
  final bool isFavorite;
  final VoidCallback onFavorite;
  final VoidCallback onSpeak;

  @override
  State<_AnimalDetailSheet> createState() => _AnimalDetailSheetState();
}

class _AnimalDetailSheetState extends State<_AnimalDetailSheet> {
  late bool _isFavorite;

  @override
  void initState() {
    super.initState();
    _isFavorite = widget.isFavorite;
  }

  @override
  Widget build(BuildContext context) {
    final animal = widget.animal;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(24, 13, 24, 30),
      decoration: const BoxDecoration(
        color: Color(0xFFFFF9F0),
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 38,
            height: 4,
            decoration: BoxDecoration(
              color: const Color(0xFFD8D8CF),
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(height: 24),
          Container(
            width: 150,
            height: 150,
            decoration: BoxDecoration(
              color: animal.color,
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Text(animal.emoji, style: const TextStyle(fontSize: 88)),
          ),
          const SizedBox(height: 16),
          Text(
            animal.name,
            style: const TextStyle(
              color: ink,
              fontSize: 29,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            'A ${animal.category.toLowerCase()} animal',
            style: const TextStyle(color: mutedInk, fontSize: 14),
          ),
          const SizedBox(height: 22),
          Text(
            '"${animal.sound}!"',
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: leafGreen,
              fontSize: 24,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 18),
          SizedBox(
            width: double.infinity,
            height: 54,
            child: FilledButton.icon(
              onPressed: widget.onSpeak,
              icon: const Icon(Icons.volume_up_rounded),
              label: Text('Hear the ${animal.name.toLowerCase()}'),
              style: FilledButton.styleFrom(
                backgroundColor: leafGreen,
                foregroundColor: Colors.white,
                textStyle: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
          TextButton.icon(
            onPressed: () {
              widget.onFavorite();
              setState(() => _isFavorite = !_isFavorite);
            },
            icon: Icon(
              _isFavorite ? Icons.favorite : Icons.favorite_border,
              color: const Color(0xFFE76B7D),
            ),
            label: Text(
              _isFavorite ? 'Saved to favorites' : 'Add to favorites',
            ),
            style: TextButton.styleFrom(foregroundColor: ink),
          ),
        ],
      ),
    );
  }
}

class _AnimalQuizSheet extends StatefulWidget {
  const _AnimalQuizSheet({required this.onSpeak});

  final Future<void> Function(String) onSpeak;

  @override
  State<_AnimalQuizSheet> createState() => _AnimalQuizSheetState();
}

class _AnimalQuizSheetState extends State<_AnimalQuizSheet> {
  final Random _random = Random();
  late Animal _answer;
  late List<Animal> _options;
  String? _chosenName;

  @override
  void initState() {
    super.initState();
    _newQuestion();
  }

  void _newQuestion() {
    _answer = animals[_random.nextInt(animals.length)];
    final wrongAnswers = animals.where((animal) => animal != _answer).toList()
      ..shuffle(_random);
    _options = [_answer, ...wrongAnswers.take(3)]..shuffle(_random);
    _chosenName = null;
  }

  @override
  Widget build(BuildContext context) {
    final answered = _chosenName != null;
    final isCorrect = _chosenName == _answer.name;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(22, 13, 22, 30),
      decoration: const BoxDecoration(
        color: Color(0xFFFFF9F0),
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 38,
            height: 4,
            decoration: BoxDecoration(
              color: const Color(0xFFD8D8CF),
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(height: 22),
          const Text('🎯', style: TextStyle(fontSize: 43)),
          const SizedBox(height: 8),
          const Text(
            'Who makes this sound?',
            style: TextStyle(
              color: ink,
              fontSize: 22,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '"${_answer.sound}!"',
            style: const TextStyle(
              color: leafGreen,
              fontSize: 25,
              fontWeight: FontWeight.w800,
            ),
          ),
          TextButton.icon(
            onPressed: () => widget.onSpeak(
              'Which animal says ${_answer.sound}?',
            ),
            icon: const Icon(Icons.volume_up_rounded, size: 19),
            label: const Text('Listen to the clue'),
            style: TextButton.styleFrom(foregroundColor: leafGreen),
          ),
          const SizedBox(height: 5),
          ..._options.map((animal) {
            final selected = _chosenName == animal.name;
            final correctOption = answered && animal == _answer;
            final background = !answered
                ? Colors.white
                : correctOption
                    ? const Color(0xFFE3F4E9)
                    : selected
                        ? const Color(0xFFFFE4E8)
                        : Colors.white;
            return Padding(
              padding: const EdgeInsets.only(bottom: 9),
              child: SizedBox(
                width: double.infinity,
                height: 53,
                child: OutlinedButton(
                  onPressed: answered
                      ? null
                      : () => setState(() => _chosenName = animal.name),
                  style: OutlinedButton.styleFrom(
                    backgroundColor: background,
                    foregroundColor: ink,
                    disabledForegroundColor: ink,
                    side: BorderSide(
                      color: correctOption
                          ? leafGreen
                          : selected
                              ? const Color(0xFFE76B7D)
                              : const Color(0xFFEAE8E0),
                      width: correctOption || selected ? 1.5 : 1,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  child: Text(
                    '${animal.emoji}  ${animal.name}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            );
          }),
          if (answered) ...[
            const SizedBox(height: 3),
            Text(
              isCorrect
                  ? 'You got it! Great listening! 🎉'
                  : 'Good try! It was the ${_answer.name}.',
              style: const TextStyle(
                color: leafGreen,
                fontWeight: FontWeight.w700,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 9),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: FilledButton(
                onPressed: () => setState(_newQuestion),
                style: FilledButton.styleFrom(
                  backgroundColor: leafGreen,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Play again'),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

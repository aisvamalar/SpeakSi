import 'dart:math';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'Spellcheck_screen.dart';

class GameScreen extends StatefulWidget {
  final int level;
  final Function(int) onLevelComplete;

  const GameScreen({
    super.key,
    required this.level,
    required this.onLevelComplete,
  });

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  bool _isWordCompleted = false;

  void _handleWordCompletion() {
    setState(() {
      _isWordCompleted = true;
    });

    // Navigate to Achievement Screen with a slight delay
    Future.delayed(const Duration(milliseconds: 500), () {
      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          transitionDuration: const Duration(milliseconds: 500),
          pageBuilder: (context, animation, secondaryAnimation) => AchievementScreen(
            level: widget.level,
            onContinue: () {
              widget.onLevelComplete(widget.level);
              // Navigate directly to the next level's GameScreen
              if (widget.level < 5) {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => GameScreen(
                      level: widget.level + 1,
                      onLevelComplete: widget.onLevelComplete,
                    ),
                  ),
                );
              } else {
                // If all levels complete, return to level selection
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const LvlScreen(initialPage: 0),
                  ),
                );
              }
            },
          ),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(
              opacity: animation,
              child: child,
            );
          },
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          PronunciationScreen(
            level: widget.level,
            onWordCompleted: _handleWordCompletion,
            onLevelComplete: widget.onLevelComplete,
          ),
        ],
      ),
    );
  }
}

class LvlScreen extends StatefulWidget {
  final int initialPage;

  const LvlScreen({super.key, required this.initialPage});

  @override
  State<LvlScreen> createState() => _LvlScreenState();
}

class _LvlScreenState extends State<LvlScreen> with SingleTickerProviderStateMixin {
  late PageController _pageController;
  double _page = 0;
  int _currentPage = 0;
  List<bool> unlockedLevels = [true, false, false, false, false];

  @override
  void initState() {
    super.initState();
    _pageController = PageController(
      viewportFraction: 0.8,
      initialPage: widget.initialPage,
    );
    _pageController.addListener(_onScroll);
  }

  void _onScroll() {
    setState(() {
      _page = _pageController.page ?? 0;
      _currentPage = _page.round();
    });
  }

  void _handleLevelComplete(int completedLevel) {
    setState(() {
      if (completedLevel < unlockedLevels.length - 1) {
        unlockedLevels[completedLevel] = true;
        unlockedLevels[completedLevel + 1] = true;

        // Auto-scroll to next level
        Future.delayed(const Duration(minutes: 5), () {
          _pageController.animateToPage(
            completedLevel + 1,
            duration: const Duration(minutes: 5),
            curve: Curves.easeInOut,
          );
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('images/img_13.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              const WordCloud(),
              PageView.builder(
                controller: _pageController,
                itemCount: 5,
                onPageChanged: (page) => setState(() => _currentPage = page),
                itemBuilder: (context, index) {
                  final difference = (index - _page);
                  final scale = 1 - (difference.abs() * 0.3).clamp(0.0, 0.4);

                  return Transform(
                    transform: Matrix4.identity()
                      ..setEntry(3, 2, 0.002)
                      ..rotateY(difference * 0.5)
                      ..scale(scale),
                    alignment: difference < 0
                        ? Alignment.centerRight
                        : Alignment.centerLeft,
                    child: GestureDetector(
                      onTap: () {
                        if (unlockedLevels[index]) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => GameScreen(
                                level: index + 1,
                                onLevelComplete: _handleLevelComplete,
                              ),
                            ),
                          );
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Complete Level ${index} first!'),
                              duration: const Duration(seconds: 2),
                            ),
                          );
                        }
                      },
                      child: LevelCard(
                        level: index + 1,
                        isLocked: !unlockedLevels[index],
                        isCurrentPage: index == _currentPage,
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class AchievementScreen extends StatefulWidget {
  final int level;
  final VoidCallback onContinue;

  const AchievementScreen({
    Key? key,
    required this.level,
    required this.onContinue,
  }) : super(key: key);

  @override
  State<AchievementScreen> createState() => _AchievementScreenState();
}

class _AchievementScreenState extends State<AchievementScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    );
    _scaleAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.elasticOut,
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black87,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ScaleTransition(
              scale: _scaleAnimation,
              child: Column(
                children: [
                  const Icon(
                    Icons.stars,
                    color: Colors.amber,
                    size: 100,
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Level ${widget.level} Complete!',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    widget.level < 5
                        ? 'Get ready for Level ${widget.level + 1}!'
                        : 'Congratulations! All levels complete!',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.8),
                      fontSize: 20,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurpleAccent,
                padding: const EdgeInsets.symmetric(
                  horizontal: 40,
                  vertical: 15,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              onPressed: widget.onContinue,
              child: Text(
                widget.level < 5 ? 'Next Level' : 'Finish',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class LevelCard extends StatelessWidget {
  final int level;
  final bool isLocked;
  final bool isCurrentPage;

  const LevelCard({
    super.key,
    required this.level,
    required this.isLocked,
    required this.isCurrentPage,
  });

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      margin: EdgeInsets.symmetric(
        vertical: isCurrentPage ? 20 : 40,
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          GradientBorderContainer(
            isLocked: isLocked,
            child: isLocked
                ? Shimmer.fromColors(
              baseColor: Colors.grey[800]!,
              highlightColor: Colors.grey[500]!,
              child: Container(
                width: size.width * 0.7,
                height: size.height * 0.4,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(18),
                  color: Colors.grey[800],
                ),
              ),
            )
                : Container(
              width: size.width * 0.7,
              height: size.height * 0.4,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(18),
                color: Colors.deepPurple,
              ),
            ),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'LEVEL $level',
                style: TextStyle(
                  color: Colors.white.withOpacity(isLocked ? 0.5 : 1.0),
                  fontSize: size.width * 0.08,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (isLocked)
                const Icon(
                  Icons.lock,
                  color: Colors.white54,
                  size: 50,
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class GradientBorderContainer extends StatelessWidget {
  final bool isLocked;
  final Widget child;

  const GradientBorderContainer({
    super.key,
    required this.isLocked,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: isLocked
            ? null
            : const LinearGradient(
          colors: [Colors.deepPurple, Colors.purple],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18),
      ),
      child: child,
    );
  }
}

class WordCloud extends StatelessWidget {
  const WordCloud({super.key});

  static const List<String> words = [];

  @override
  Widget build(BuildContext context) {
    final random = Random();
    final size = MediaQuery.of(context).size;

    return Stack(
      children: words.map((word) {
        return Positioned(
          left: random.nextDouble() * size.width,
          top: random.nextDouble() * size.height,
          child: Text(
            word,
            style: TextStyle(
              color: Colors.white.withOpacity(0.5),
              fontSize: size.width * 0.04,
              fontWeight: FontWeight.w300,
            ),
          ),
        );
      }).toList(),
    );
  }
}
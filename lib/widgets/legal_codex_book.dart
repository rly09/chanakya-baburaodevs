import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../utils/app_colors.dart';
import '../services/api_service.dart';

class LegalCodexBook extends StatefulWidget {
  const LegalCodexBook({super.key});

  @override
  State<LegalCodexBook> createState() => _LegalCodexBookState();
}

class _LegalCodexBookState extends State<LegalCodexBook>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late AnimationController _pageFlipController;
  late Animation<double> _bookOpenAnimation;

  final TextEditingController _searchController = TextEditingController();
  final ApiService _apiService = ApiService();
  bool _isSearching = false;

  Map<String, String>? _currentDisplayData;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900), 
    );
    _pageFlipController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150), // Super fast flipping
    );
    _bookOpenAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOutCubic,
      ),
    );
  }

  Future<void> _searchAct() async {
    FocusScope.of(context).unfocus();
    final query = _searchController.text.toUpperCase().trim();
    if (query.isEmpty) return;
    
    setState(() {
      _isSearching = true;
      _currentDisplayData = null;
    });
    
    // Crack the book open immediately to watch it search
    _animationController.forward();
    _pageFlipController.repeat();

    final result = await _apiService.fetchSpecificActDetails(query);
    
    // Add artificial minimum delay so they can appreciate the flipping animation
    await Future.delayed(const Duration(milliseconds: 800));

    if (mounted) {
      _pageFlipController.stop();
      _pageFlipController.reset();
      setState(() {
        _isSearching = false;
        if (result != null) {
          _currentDisplayData = result;
        } else {
          _currentDisplayData = {
            'title': 'Search Results: $query',
            'content': 'No established federal Act or authoritative data could be resolved for this query. Please confirm the terminology.'
          };
        }
      });
    }
  }

  void _closeBook() {
    _animationController.reverse();
    Future.delayed(const Duration(milliseconds: 900), () {
      if (mounted) {
        setState(() {
          _currentDisplayData = null;
          _searchController.clear();
        });
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    _pageFlipController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // The Search Bar
        Container(
          margin: const EdgeInsets.only(bottom: 24),
          decoration: BoxDecoration(
            color: AppColors.surface,
            border: Border.all(color: AppColors.border),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _searchController,
                  style: GoogleFonts.inter(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                  decoration: InputDecoration(
                    hintText: 'SEARCH VIDHI SHASTRA (e.g. IPC, CRPC...)',
                    hintStyle: GoogleFonts.inter(
                      color: AppColors.textMuted,
                      letterSpacing: 1.0,
                    ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  ),
                  onSubmitted: (_) => _searchAct(),
                ),
              ),
              InkWell(
                onTap: _isSearching ? null : _searchAct,
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: const BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.only(
                      topRight: Radius.circular(7),
                      bottomRight: Radius.circular(7),
                    ),
                  ),
                  child: _isSearching 
                    ? const SizedBox(
                        width: 24, 
                        height: 24, 
                        child: CircularProgressIndicator(color: AppColors.surface, strokeWidth: 2)
                      )
                    : const Icon(Icons.search, color: AppColors.surface),
                ),
              ),
            ],
          ),
        ),

        // The 3D Book Container
        SizedBox(
          height: 350, // Fixed height for the book
          child: AnimatedBuilder(
            animation: _bookOpenAnimation,
            builder: (context, child) {
              return Stack(
                children: [
                  // 1. The BACK COVER and INNER PAGES (Always visible underneath)
                  _buildInternalPages(),
                  
                  // 2. The FRONT COVER (Rotates in 3D Space)
                  // We hinge it on the center-left so it opens like a real book.
                  Transform(
                    alignment: Alignment.centerLeft,
                    transform: Matrix4.identity()
                      ..setEntry(3, 2, 0.001) // perspective distortion
                      ..rotateY(-math.pi * 0.9 * _bookOpenAnimation.value), 
                      // 0 is closed, pi is fully open. 0.9 opens it almost fully but keeps it slightly angled.
                    child: _buildFrontCover(),
                  ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }

  // Visual representing the inside content
  Widget _buildInternalPages() {
    return Stack(
      children: [
        // The Base Page Block
        Container(
          width: double.infinity,
          height: 350,
          margin: const EdgeInsets.only(left: 5), // Space for hinge
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: AppColors.surface,
            border: Border.all(color: AppColors.border, width: 2),
            borderRadius: const BorderRadius.only(
              topRight: Radius.circular(8),
              bottomRight: Radius.circular(8),
            ),
            // Layered page edges effect
            boxShadow: const [
              BoxShadow(color: AppColors.surface, offset: Offset(2, 0)),
              BoxShadow(color: AppColors.border, offset: Offset(3, 0)),
              BoxShadow(color: AppColors.surface, offset: Offset(4, 0)),
              BoxShadow(color: AppColors.border, offset: Offset(5, 0)),
              BoxShadow(color: AppColors.surface, offset: Offset(6, 0)),
              BoxShadow(color: AppColors.border, offset: Offset(7, 0)),
              BoxShadow(color: Colors.black26, blurRadius: 15, offset: Offset(15, 15)),
            ],
          ),
          child: _isSearching
            ? Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(height: 30),
                    Text(
                      "Scanning Master Statutes...",
                      style: GoogleFonts.newsreader(
                        color: AppColors.textMuted,
                        fontStyle: FontStyle.italic,
                        fontSize: 18,
                      ),
                    ),
                  ],
                ),
              )
            : _currentDisplayData == null
                ? const SizedBox()
                : SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                _currentDisplayData!['title']!,
                                style: GoogleFonts.newsreader(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primary,
                                ),
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.close, color: AppColors.primary),
                              onPressed: _closeBook,
                            ),
                          ],
                        ),
                        const Divider(color: AppColors.border),
                        const SizedBox(height: 16),
                        Text(
                          _currentDisplayData!['content']!,
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            height: 1.8,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 32),
                        const Center(
                          child: Text(
                            "◆ ◆ ◆",
                            style: TextStyle(color: AppColors.textMuted),
                          ),
                        )
                      ],
                    ),
                  ),
        ),
        
        // Fast Page Turning Animation (Only visible during search)
        if (_isSearching)
          Positioned(
            top: 0,
            bottom: 0,
            left: 5,
            right: 0, // Fill the right side
            child: AnimatedBuilder(
              animation: _pageFlipController,
              builder: (context, child) {
                return Transform(
                  alignment: Alignment.centerLeft,
                  transform: Matrix4.identity()
                    ..setEntry(3, 2, 0.001)
                    ..rotateY(-math.pi * (_pageFlipController.value)),
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      border: Border.all(color: AppColors.border.withOpacity(0.5), width: 1),
                      borderRadius: const BorderRadius.only(
                        topRight: Radius.circular(8),
                        bottomRight: Radius.circular(8),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 10,
                          offset: Offset(-5 * _pageFlipController.value, 0)
                        )
                      ]
                    ),
                    // Just put some fake blur lines on the turning page
                    child: Center(
                      child: Opacity(
                        opacity: 1 - _pageFlipController.value,
                        child: Container(
                          width: double.infinity,
                          margin: const EdgeInsets.symmetric(horizontal: 40, vertical: 60),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: List.generate(
                              5, 
                              (index) => Container(
                                height: 12,
                                margin: const EdgeInsets.only(bottom: 12),
                                color: AppColors.border.withOpacity(0.3),
                                width: index % 2 == 0 ? double.infinity : 150,
                              )
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
      ],
    );
  }

  // Visual representing the rigid front cover
  Widget _buildFrontCover() {
    return Container(
      width: double.infinity,
      height: 350,
      decoration: BoxDecoration(
        color: AppColors.primary, // Dark obsidian/slate cover
        border: Border.all(color: AppColors.primaryDark, width: 3),
        borderRadius: const BorderRadius.only(
          topRight: Radius.circular(6),
          bottomRight: Radius.circular(6),
        ),
        boxShadow: [
          // Thick book shadow when closed
          BoxShadow(
            color: Colors.black.withOpacity(0.5 * (1 - _bookOpenAnimation.value)),
            blurRadius: 20,
            offset: const Offset(15, 15),
          )
        ],
      ),
      child: Stack(
        children: [
          // Inner gold/silver embossed border
          Positioned(
            top: 10, bottom: 10, left: 35, right: 10,
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.border.withOpacity(0.2), width: 1.5),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
          
          // The Book Spine Line and hinge gradient
          Positioned(
            left: 0,
            top: 0,
            bottom: 0,
            width: 30,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.black.withOpacity(0.6),
                    Colors.black.withOpacity(0.1),
                    Colors.black.withOpacity(0.4),
                  ],
                ),
              ),
            ),
          ),
          
          // Cover Embellishments
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Ornate crest substitute
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.surface.withOpacity(0.3), width: 2),
                  ),
                  child: const Icon(Icons.book, color: AppColors.surface, size: 42),
                ),
                const SizedBox(height: 32),
                Text(
                  'VIDHI SHASTRA',
                  style: GoogleFonts.newsreader(
                    color: AppColors.surface,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 4.0,
                    shadows: [
                      const Shadow(color: Colors.black45, blurRadius: 4, offset: Offset(2, 2))
                    ]
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'V I D H I   S H A S T R A',
                  style: GoogleFonts.inter(
                    color: AppColors.surface.withOpacity(0.8),
                    fontSize: 10,
                    letterSpacing: 8.0,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'विधि शास्त्र',
                  style: GoogleFonts.inter(
                    color: AppColors.surface.withOpacity(0.45),
                    fontSize: 11,
                    letterSpacing: 2.0,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

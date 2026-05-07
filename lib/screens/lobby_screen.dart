import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class LobbyScreen extends StatefulWidget {
  final Function(String) onJoinGame;

  const LobbyScreen({super.key, required this.onJoinGame});

  @override
  State<LobbyScreen> createState() => _LobbyScreenState();
}

class _LobbyScreenState extends State<LobbyScreen> {
  final _playerNameController = TextEditingController(text: 'Player 1');
  bool _isLoading = false;

  @override
  void dispose() {
    _playerNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.indigo[900]!,
              Colors.purple[800]!,
              Colors.deepPurple[900]!,
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Game logo/title
                  _buildLogo(),
                  
                  const SizedBox(height: 48),
                  
                  // Character selection preview
                  _buildCharacterPreview(),
                  
                  const SizedBox(height: 32),
                  
                  // Player name input
                  _buildNameInput(),
                  
                  const SizedBox(height: 24),
                  
                  // Join button
                  _buildJoinButton(),
                  
                  const SizedBox(height: 32),
                  
                  // Features list
                  _buildFeaturesList(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLogo() {
    return Column(
      children: [
        // SVG Logo
        SizedBox(
          width: 200,
          height: 200,
          child: SvgPicture.string(
            '''
              <svg viewBox="0 0 200 200" xmlns="http://www.w3.org/2000/svg">
                <!-- Background circle -->
                <circle cx="100" cy="100" r="95" fill="#1A237E"/>
                <circle cx="100" cy="100" r="85" fill="#311B92"/>
                
                <!-- Star shape -->
                <path d="M100 20 L120 70 L175 70 L135 105 L150 160 L100 130 L50 160 L65 105 L25 70 L80 70 Z" 
                      fill="#FFD700" stroke="#FFA000" stroke-width="3"/>
                
                <!-- Controller icon -->
                <rect x="60" y="110" width="80" height="50" rx="10" fill="#4CAF50"/>
                <circle cx="80" cy="135" r="8" fill="#1B5E20"/>
                <circle cx="120" cy="135" r="8" fill="#1B5E20"/>
                <path d="M95 125 L105 125 M100 120 L100 130" stroke="white" stroke-width="3"/>
                
                <!-- Title text placeholder -->
                <text x="100" y="190" font-size="16" fill="white" text-anchor="middle" font-weight="bold">PIXEL FURY</text>
              </svg>
            ''',
            fit: BoxFit.contain,
          ),
        ),
        
        const SizedBox(height: 16),
        
        Text(
          'PIXEL FURY ARENA',
          style: TextStyle(
            fontSize: 36,
            fontWeight: FontWeight.bold,
            color: Colors.amber[400],
            letterSpacing: 2,
            shadows: [
              Shadow(
                color: Colors.black.withOpacity(0.5),
                blurRadius: 4,
                offset: const Offset(2, 2),
              ),
            ],
          ),
        ),
        
        const SizedBox(height: 8),
        
        Text(
          'Multiplayer Battle Arena',
          style: TextStyle(
            fontSize: 18,
            color: Colors.white.withOpacity(0.8),
            letterSpacing: 1,
          ),
        ),
      ],
    );
  }

  Widget _buildCharacterPreview() {
    return Column(
      children: [
        Text(
          'Choose Your Fighter',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white.withOpacity(0.9),
          ),
        ),
        
        const SizedBox(height: 16),
        
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildCharacterCard('Warrior', '#E53935', Icons.shield),
            const SizedBox(width: 16),
            _buildCharacterCard('Mage', '#1E88E5', Icons.auto_awesome),
            const SizedBox(width: 16),
            _buildCharacterCard('Archer', '#43A047', Icons.bolt),
          ],
        ),
      ],
    );
  }

  Widget _buildCharacterCard(String name, String color, IconData icon) {
    return Container(
      width: 80,
      height: 100,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.white.withOpacity(0.3),
          width: 2,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: Color(int.parse(color.substring(1), radix: 16)),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: Colors.white,
              size: 30,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            name,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNameInput() {
    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(maxWidth: 400),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Enter Your Name',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white.withOpacity(0.9),
            ),
          ),
          
          const SizedBox(height: 8),
          
          TextField(
            controller: _playerNameController,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
            ),
            decoration: InputDecoration(
              hintText: 'Player Name',
              hintStyle: TextStyle(
                color: Colors.white.withOpacity(0.5),
              ),
              filled: true,
              fillColor: Colors.white.withOpacity(0.1),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: Colors.white.withOpacity(0.3),
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: Colors.white.withOpacity(0.3),
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(
                  color: Colors.amber,
                  width: 2,
                ),
              ),
              prefixIcon: const Icon(
                Icons.person,
                color: Colors.white70,
              ),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildJoinButton() {
    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(maxWidth: 400),
      child: ElevatedButton(
        onPressed: _isLoading ? null : _handleJoinGame,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.amber,
          foregroundColor: Colors.black87,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 8,
          shadowColor: Colors.amber.withOpacity(0.5),
        ),
        child: _isLoading
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.black87),
                ),
              )
            : const Text(
                'JOIN BATTLE',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2,
                ),
              ),
      ),
    );
  }

  Widget _buildFeaturesList() {
    return Column(
      children: [
        Text(
          'Game Features',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white.withOpacity(0.9),
          ),
        ),
        
        const SizedBox(height: 16),
        
        Wrap(
          alignment: WrapAlignment.center,
          spacing: 16,
          runSpacing: 12,
          children: [
            _buildFeatureChip(Icons.people, 'Multiplayer'),
            _buildFeatureChip(Icons.sports_esports, 'Real-time Action'),
            _buildFeatureChip(Icons.leaderboard, 'Competitive'),
            _buildFeatureChip(Icons.palette, 'SVG Graphics'),
          ],
        ),
      ],
    );
  }

  Widget _buildFeatureChip(IconData icon, String label) {
    return Chip(
      avatar: Icon(
        icon,
        color: Colors.amber[700],
        size: 18,
      ),
      label: Text(
        label,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
      backgroundColor: Colors.white.withOpacity(0.1),
      side: BorderSide(
        color: Colors.white.withOpacity(0.3),
      ),
    );
  }

  void _handleJoinGame() {
    if (_playerNameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter your name'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    
    setState(() {
      _isLoading = true;
    });
    
    // Simulate connection delay
    Future.delayed(const Duration(seconds: 2), () {
      widget.onJoinGame(_playerNameController.text.trim());
    });
  }
}

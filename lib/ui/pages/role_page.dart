import 'package:flutter/material.dart';

class RoleSelectionScreen extends StatefulWidget {
  const RoleSelectionScreen({super.key});

  @override
  State<RoleSelectionScreen> createState() => _RoleSelectionScreenState();
}

class _RoleSelectionScreenState extends State<RoleSelectionScreen> {
  String? _selectedRole;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 36, 36, 36),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text("Select Role", style: TextStyle(color: Colors.white)),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Who are you?',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'Choose your role to continue.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: Color.fromARGB(255, 189, 189, 189),
                ),
              ),
              
              const Spacer(), 

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildRoleCard(
                    roleKey: 'professor',
                    label: 'Professore',
                    icon: Icons.school,
                  ),
                  
                  const SizedBox(width: 20), 

                  _buildRoleCard(
                    roleKey: 'student',
                    label: 'Studente',
                    icon: Icons.person,
                  ),
                ],
              ),

              const Spacer(),

              SizedBox(
                height: 55,
                child: ElevatedButton(
                  onPressed: _selectedRole == null
                      ? null 
                      : _saveAndContinue,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF46ad5a),
                    disabledBackgroundColor: Colors.grey[800], 
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Continue',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRoleCard({
    required String roleKey,
    required String label,
    required IconData icon,
  }) {
    final isSelected = _selectedRole == roleKey;

    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedRole = roleKey;
          });
        },
        child: AspectRatio(
          aspectRatio: 1, 
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            decoration: BoxDecoration(
              color: isSelected 
                  ? const Color(0xFF46ad5a).withValues(alpha: 0.2)
                  : Colors.white.withValues(alpha: 0.05), 
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isSelected ? const Color(0xFF46ad5a) : Colors.transparent,
                width: 3,
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  icon,
                  size: 50,
                  color: isSelected ? const Color(0xFF46ad5a) : Colors.white,
                ),
                const SizedBox(height: 16),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: isSelected ? Colors.white : Colors.grey[400],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _saveAndContinue() {
    print("Ruolo selezionato da salvare nel DB: $_selectedRole");

    if (_selectedRole == 'professor') {
    } else {
    }
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Benvenuto $_selectedRole!")),
    );
  }
}
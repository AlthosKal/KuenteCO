/*import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:kuenteco/dto/profile_detail_dto.dart';
import 'package:kuenteco/routes/Auth_repository.dart';
import 'package:kuenteco/widgets/Create_profile_widget.dart';
import 'package:kuenteco/widgets/Delete_profile_widget.dart';

class SelectProfileWidget extends StatefulWidget {
  final AuthRepository authRepository;
  final String? userEmail;
  final Function(AccountDetailDTO)? onProfileSelected;
  final VoidCallback? onCreateProfile;
  final Function(AccountDetailDTO)? onDeleteProfile;

  const SelectProfileWidget({
    Key? key,
    required this.authRepository,
    this.userEmail,
    this.onProfileSelected,
    this.onCreateProfile,
    this.onDeleteProfile,
  }) : super(key: key);

  @override
  State<SelectProfileWidget> createState() => _SelectProfileWidgetState();
}

class _SelectProfileWidgetState extends State<SelectProfileWidget> {
  List<AccountDetailDTO> _accounts = [];
  bool _isLoading = true;
  String _errorMessage = '';
  String? _authToken;

  @override
  void initState() {
    super.initState();
    _loadProfiles();
  }

  Future<void> _loadProfiles() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      _authToken = prefs.getString('authToken');

      if (_authToken == null) {
        throw Exception('No authentication token found');
      }

      final response = await widget.authRepository.getAllAccounts();
      if (response.containsKey('accounts')) {
        setState(() {
          _accounts = (response['accounts'] as List)
              .map((json) => AccountDetailDTO.fromJson(json))
              .toList();
          _isLoading = false;
        });
      } else {
        throw Exception(response['message'] ?? 'Failed to load profiles');
      }
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  void _handleCreateProfile() {
    if (widget.onCreateProfile != null) {
      widget.onCreateProfile!();
      return;
    }

    showDialog(
      context: context,
      builder: (context) => CreateProfileWidget(
        authRepository: widget.authRepository,
        onProfileCreated: _loadProfiles,
      ),
    );
  }

  void _handleDeleteProfile(AccountDetailDTO profile) {
    if (widget.onDeleteProfile != null) {
      widget.onDeleteProfile!(profile);
      return;
    }

    showDialog(
      context: context,
      builder: (context) => DeleteProfileWidget(
        accountId: profile.id,
        authRepository: widget.authRepository,
        onDeleteConfirmed: _loadProfiles,
      ),
    );
  }

  void _handleSelectProfile(AccountDetailDTO profile) {
    if (widget.onProfileSelected != null) {
      widget.onProfileSelected!(profile);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildHeader(),
        const SizedBox(height: 16),
        _buildProfileGrid(),
      ],
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        const Icon(Icons.people_alt, size: 28),
        const SizedBox(width: 12),
        Text(
          'Selecciona un perfil',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const Spacer(),
        IconButton(
          icon: const Icon(Icons.add),
          onPressed: _handleCreateProfile,
          tooltip: 'Crear nuevo perfil',
        ),
      ],
    );
  }

  Widget _buildProfileGrid() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage.isNotEmpty) {
      return Text(
        _errorMessage,
        style: TextStyle(color: Theme.of(context).colorScheme.error),
      );
    }

    if (_accounts.isEmpty) {
      return const Text('No hay perfiles disponibles');
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.2,
      ),
      itemCount: _accounts.length,
      itemBuilder: (context, index) => _ProfileCard(
        profile: _accounts[index],
        onSelect: _handleSelectProfile,
        onDelete: _handleDeleteProfile,
      ),
    );
  }
}

class _ProfileCard extends StatelessWidget {
  final AccountDetailDTO profile;
  final Function(AccountDetailDTO) onSelect;
  final Function(AccountDetailDTO) onDelete;

  const _ProfileCard({
    required this.profile,
    required this.onSelect,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: () => onSelect(profile),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Stack(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    child: Text(profile.name[0].toUpperCase()),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    profile.name,
                    style: Theme.of(context).textTheme.titleMedium,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
              Positioned(
                top: 0,
                right: 0,
                child: IconButton(
                  icon: const Icon(Icons.delete_outline, size: 18),
                  onPressed: () => onDelete(profile),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}*/
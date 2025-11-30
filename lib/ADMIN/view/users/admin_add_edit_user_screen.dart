import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../utils/constants.dart';
import '../../controller/admin_user_controller.dart';

class AdminAddEditUserScreen extends StatefulWidget {
  final String? userId; // null for add, userId for edit

  const AdminAddEditUserScreen({super.key, this.userId});

  @override
  State<AdminAddEditUserScreen> createState() => _AdminAddEditUserScreenState();
}

class _AdminAddEditUserScreenState extends State<AdminAddEditUserScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _departmentController = TextEditingController();
  final _employeeIdController = TextEditingController();
  final _locationController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  UserRole _selectedRole = UserRole.RAN_ENGINEER;
  bool _isActive = true;
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void initState() {
    super.initState();
    if (widget.userId != null) {
      _loadUserData();
    }
  }

  void _loadUserData() {
    final controller = context.read<AdminUserController>();
    final user = controller.users.firstWhere((u) => u.uid == widget.userId);

    _nameController.text = user.name;
    _emailController.text = user.email;
    _phoneController.text = user.phone;
    _departmentController.text = user.department;
    _employeeIdController.text = user.employeeId;
    _locationController.text = user.location;
    _selectedRole = user.role;
    _isActive = user.isActive;
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.userId != null;

    return Scaffold(
      backgroundColor: const Color(0xFF0a0e1a),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0d1117),
        title: Text(
          isEdit ? 'Edit User' : 'Add New User',
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: const Color(0xFF0d1117),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFF21262d)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'User Information',
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 24),
                _buildTextField('Full Name', _nameController, Icons.person),
                const SizedBox(height: 16),
                _buildTextField(
                  'Email',
                  _emailController,
                  Icons.email,
                  enabled: !isEdit,
                ),
                const SizedBox(height: 16),
                if (!isEdit)
                  Column(
                    children: [
                      _buildTextField(
                        'Password',
                        _passwordController,
                        Icons.lock,
                        obscureText: _obscurePassword,
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword
                                ? Icons.visibility_off
                                : Icons.visibility,
                            color: Colors.white60,
                          ),
                          onPressed: () => setState(
                            () => _obscurePassword = !_obscurePassword,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildTextField(
                        'Confirm Password',
                        _confirmPasswordController,
                        Icons.lock_outline,
                        obscureText: _obscureConfirmPassword,
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscureConfirmPassword
                                ? Icons.visibility_off
                                : Icons.visibility,
                            color: Colors.white60,
                          ),
                          onPressed: () => setState(
                            () => _obscureConfirmPassword =
                                !_obscureConfirmPassword,
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please confirm your password';
                          }
                          if (value != _passwordController.text) {
                            return 'Passwords do not match';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
                _buildTextField('Phone', _phoneController, Icons.phone),
                const SizedBox(height: 16),
                _buildRoleDropdown(),
                const SizedBox(height: 16),
                if (isEdit) ...[
                  _buildTextField(
                    'Employee ID',
                    _employeeIdController,
                    Icons.badge,
                    enabled: false,
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    'Department',
                    _departmentController,
                    Icons.business,
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    'Location',
                    _locationController,
                    Icons.location_on,
                  ),
                  const SizedBox(height: 16),
                ],
                _buildStatusToggle(),
                const SizedBox(height: 32),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 32,
                          vertical: 16,
                        ),
                        side: const BorderSide(color: Color(0xFF21262d)),
                      ),
                      child: Text(
                        'Cancel',
                        style: GoogleFonts.poppins(color: Colors.white),
                      ),
                    ),
                    const SizedBox(width: 16),
                    ElevatedButton(
                      onPressed: _isLoading ? null : _saveUser,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF3b82f6),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 32,
                          vertical: 16,
                        ),
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : Text(
                              isEdit ? 'Update User' : 'Create User',
                              style: GoogleFonts.poppins(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(
    String label,
    TextEditingController controller,
    IconData icon, {
    bool obscureText = false,
    bool enabled = true,
    Widget? suffixIcon,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 14,
            color: Colors.white70,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          obscureText: obscureText,
          enabled: enabled,
          style: GoogleFonts.poppins(color: Colors.white),
          decoration: InputDecoration(
            prefixIcon: Icon(icon, color: Colors.white60),
            suffixIcon: suffixIcon,
            filled: true,
            fillColor: const Color(0xFF161b22),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF21262d)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF21262d)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF3b82f6), width: 2),
            ),
            disabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF21262d)),
            ),
          ),
          validator:
              validator ??
              (value) {
                if (value == null || value.isEmpty) {
                  return 'This field is required';
                }
                if (label == 'Email' && !value.contains('@')) {
                  return 'Please enter a valid email';
                }
                if (label == 'Password' && value.length < 6) {
                  return 'Password must be at least 6 characters';
                }
                return null;
              },
        ),
      ],
    );
  }

  Widget _buildRoleDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Role',
          style: GoogleFonts.poppins(
            fontSize: 14,
            color: Colors.white70,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: const Color(0xFF161b22),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFF21262d)),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<UserRole>(
              value: _selectedRole,
              isExpanded: true,
              dropdownColor: const Color(0xFF161b22),
              style: GoogleFonts.poppins(color: Colors.white),
              onChanged: (UserRole? newValue) {
                if (newValue != null) {
                  setState(() => _selectedRole = newValue);
                }
              },
              items: UserRole.values.map((role) {
                return DropdownMenuItem(
                  value: role,
                  child: Text(role.displayName),
                );
              }).toList(),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatusToggle() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Account Status',
          style: GoogleFonts.poppins(
            fontSize: 14,
            color: Colors.white70,
            fontWeight: FontWeight.w500,
          ),
        ),
        Row(
          children: [
            Text(
              _isActive ? 'Active' : 'Inactive',
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: _isActive
                    ? const Color(0xFF10b981)
                    : const Color(0xFFef4444),
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(width: 12),
            Switch(
              value: _isActive,
              onChanged: (value) => setState(() => _isActive = value),
              activeColor: const Color(0xFF10b981),
            ),
          ],
        ),
      ],
    );
  }

  Future<void> _saveUser() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final controller = context.read<AdminUserController>();

      if (widget.userId == null) {
        // Create new user
        final success = await controller.createUser(
          email: _emailController.text.trim(),
          password: _passwordController.text,
          name: _nameController.text.trim(),
          role: _selectedRole,
          phone: _phoneController.text.trim(),
          department: '', // Auto-generated by system
          location: 'India', // Default location
        );

        if (!success) {
          throw Exception('Failed to create user');
        }
      } else {
        // Update existing user
        final success = await controller.updateUser(
          uid: widget.userId!,
          name: _nameController.text.trim(),
          phone: _phoneController.text.trim(),
          department: _departmentController.text.trim(),
          location: _locationController.text.trim(),
          role: _selectedRole,
        );

        if (!success) {
          throw Exception('Failed to update user');
        }
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.userId == null
                  ? 'User created successfully'
                  : 'User updated successfully',
              style: GoogleFonts.poppins(),
            ),
            backgroundColor: const Color(0xFF10b981),
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e', style: GoogleFonts.poppins()),
            backgroundColor: const Color(0xFFef4444),
          ),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _departmentController.dispose();
    _employeeIdController.dispose();
    _locationController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }
}

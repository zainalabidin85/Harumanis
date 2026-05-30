import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/api_service.dart';
import '../theme.dart';

class UsersScreen extends StatefulWidget {
  const UsersScreen({super.key});
  @override
  State<UsersScreen> createState() => _UsersScreenState();
}

class _UsersScreenState extends State<UsersScreen> {
  List<dynamic> _users = [];
  bool _loading = true;
  String? _error;
  String? _roleFilter;      // null = all
  bool?   _suspendedFilter; // null = all

  @override
  void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    setState(() { _loading = true; _error = null; });
    try {
      _users = await ApiService.getUsers(role: _roleFilter, isSuspended: _suspendedFilter);
    } on DioException catch (e) {
      _error = 'Failed (error ${e.response?.statusCode}).';
    } catch (e) {
      _error = 'Error: $e';
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _showActions(Map<String, dynamic> user) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => _UserSheet(user: user, onDone: _load),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      _FilterBar(
        roleFilter: _roleFilter,
        suspendedFilter: _suspendedFilter,
        onRoleChanged: (v) { setState(() => _roleFilter = v); _load(); },
        onSuspendedChanged: (v) { setState(() => _suspendedFilter = v); _load(); },
      ),
      Expanded(
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : _error != null
                ? Center(child: Text(_error!, style: GoogleFonts.poppins(color: kRed)))
                : _users.isEmpty
                    ? Center(child: Text('No users found.', style: GoogleFonts.poppins(color: kText3)))
                    : RefreshIndicator(
                        onRefresh: _load,
                        child: ListView.separated(
                          padding: const EdgeInsets.all(16),
                          itemCount: _users.length,
                          separatorBuilder: (_, __) => const SizedBox(height: 8),
                          itemBuilder: (_, i) => _UserTile(user: _users[i], onTap: () => _showActions(_users[i])),
                        ),
                      ),
      ),
    ]);
  }
}

class _FilterBar extends StatelessWidget {
  final String? roleFilter;
  final bool? suspendedFilter;
  final ValueChanged<String?> onRoleChanged;
  final ValueChanged<bool?> onSuspendedChanged;
  const _FilterBar({required this.roleFilter, required this.suspendedFilter,
      required this.onRoleChanged, required this.onSuspendedChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(children: [
          _Chip('All',     null,       roleFilter, onRoleChanged),
          const SizedBox(width: 8),
          _Chip('Farmers', 'farmer',   roleFilter, onRoleChanged),
          const SizedBox(width: 8),
          _Chip('Buyers',  'buyer',    roleFilter, onRoleChanged),
          const SizedBox(width: 8),
          _Chip('Admins',  'admin',    roleFilter, onRoleChanged),
          const SizedBox(width: 16),
          FilterChip(
            label: const Text('Suspended only'),
            selected: suspendedFilter == true,
            onSelected: (v) => onSuspendedChanged(v ? true : null),
            selectedColor: kRed.withValues(alpha: 0.12),
            labelStyle: GoogleFonts.poppins(fontSize: 12,
                color: suspendedFilter == true ? kRed : kText2),
          ),
        ]),
      ),
    );
  }

  Widget _Chip(String label, String? value, String? current, ValueChanged<String?> onChanged) {
    final selected = current == value;
    return FilterChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) => onChanged(value),
      selectedColor: kIndigo100,
      labelStyle: GoogleFonts.poppins(fontSize: 12, color: selected ? kIndigo700 : kText2),
    );
  }
}

class _UserTile extends StatelessWidget {
  final Map<String, dynamic> user;
  final VoidCallback onTap;
  const _UserTile({required this.user, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final role = user['role'] as String;
    final suspended = user['is_suspended'] as bool? ?? false;
    final verified = user['is_verified'] as bool? ?? false;
    final roleColor = role == 'admin' ? kIndigo700 : role == 'farmer' ? kGreen : kOrange;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: kCard, borderRadius: BorderRadius.circular(14), boxShadow: kCardShadow,
          border: suspended ? Border.all(color: kRed.withValues(alpha: 0.3)) : null,
        ),
        child: Row(children: [
          CircleAvatar(
            radius: 20, backgroundColor: roleColor.withValues(alpha: 0.12),
            child: Text((user['name'] as String).substring(0, 1).toUpperCase(),
                style: GoogleFonts.poppins(fontWeight: FontWeight.w600, color: roleColor)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Expanded(child: Text(user['name'] as String,
                    style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 14, color: kText1))),
                if (verified) Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(color: kGreen.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(6)),
                  child: Row(mainAxisSize: MainAxisSize.min, children: [
                    Icon(Icons.verified_rounded, size: 10, color: kGreen),
                    const SizedBox(width: 3),
                    Text('Verified', style: GoogleFonts.poppins(fontSize: 10, color: kGreen, fontWeight: FontWeight.w600)),
                  ]),
                ),
                if (suspended) ...[
                  const SizedBox(width: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(color: kRed.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(6)),
                    child: Text('Suspended', style: GoogleFonts.poppins(fontSize: 10, color: kRed, fontWeight: FontWeight.w600)),
                  ),
                ],
              ]),
              Text(user['email'] as String, style: GoogleFonts.poppins(fontSize: 12, color: kText3)),
              const SizedBox(height: 4),
              _RoleBadge(role, roleColor),
            ]),
          ),
          const Icon(Icons.chevron_right_rounded, color: kText3),
        ]),
      ),
    );
  }
}

class _RoleBadge extends StatelessWidget {
  final String role;
  final Color color;
  const _RoleBadge(this.role, this.color);
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
    decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(6)),
    child: Text(role.toUpperCase(), style: GoogleFonts.poppins(fontSize: 10, fontWeight: FontWeight.w600, color: color)),
  );
}

class _UserSheet extends StatefulWidget {
  final Map<String, dynamic> user;
  final VoidCallback onDone;
  const _UserSheet({required this.user, required this.onDone});
  @override
  State<_UserSheet> createState() => _UserSheetState();
}

class _UserSheetState extends State<_UserSheet> {
  bool _loading = false;
  String? _error;

  Future<void> _update({String? role, bool? isSuspended, bool? isVerified}) async {
    setState(() { _loading = true; _error = null; });
    try {
      await ApiService.updateUser(widget.user['id'] as int, role: role, isSuspended: isSuspended, isVerified: isVerified);
      if (mounted) { Navigator.pop(context); widget.onDone(); }
    } on DioException catch (e) {
      final detail = e.response?.data is Map ? e.response!.data['detail'] : null;
      setState(() { _error = detail ?? 'Failed (error ${e.response?.statusCode}).'; _loading = false; });
    } catch (e) {
      setState(() { _error = 'Error: $e'; _loading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = widget.user;
    final suspended = user['is_suspended'] as bool? ?? false;
    final verified = user['is_verified'] as bool? ?? false;
    final role = user['role'] as String;

    return Padding(
      padding: EdgeInsets.fromLTRB(20, 20, 20, MediaQuery.of(context).viewInsets.bottom + 24),
      child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Text(user['name'] as String,
              style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600, color: kText1)),
          const Spacer(),
          IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(context)),
        ]),
        Text(user['email'] as String, style: GoogleFonts.poppins(fontSize: 13, color: kText3)),
        const SizedBox(height: 8),
        _infoRow('Role', role),
        if (user['phone'] != null) _infoRow('Phone', user['phone'] as String),
        if (user['bank_name'] != null) _infoRow('Bank', '${user['bank_name']}  ${user['bank_account_number'] ?? ''}'),
        if (_error != null) ...[
          const SizedBox(height: 10),
          Text(_error!, style: GoogleFonts.poppins(fontSize: 13, color: kRed)),
        ],
        const SizedBox(height: 16),
        const Divider(),
        const SizedBox(height: 12),
        Text('Actions', style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w600, color: kText3)),
        const SizedBox(height: 12),
        if (_loading)
          const Center(child: CircularProgressIndicator())
        else
          Wrap(spacing: 10, runSpacing: 10, children: [
            if (role == 'farmer') ...[
              if (verified)
                _ActionButton('Remove Verified', kText2, Icons.verified_outlined, () => _update(isVerified: false))
              else
                _ActionButton('Mark Verified', kGreen, Icons.verified_rounded, () => _update(isVerified: true)),
            ],
            if (suspended)
              _ActionButton('Unsuspend', kGreen, Icons.check_circle_outline, () => _update(isSuspended: false))
            else if (role != 'admin')
              _ActionButton('Suspend', kRed, Icons.block_rounded, () => _update(isSuspended: true)),
            if (role == 'farmer')
              _ActionButton('Make Buyer', kOrange, Icons.shopping_bag_outlined, () => _update(role: 'buyer')),
            if (role == 'buyer')
              _ActionButton('Make Farmer', kGreen, Icons.agriculture_outlined, () => _update(role: 'farmer')),
          ]),
      ]),
    );
  }

  Widget _infoRow(String label, String value) => Padding(
    padding: const EdgeInsets.only(bottom: 4),
    child: Row(children: [
      Text('$label: ', style: GoogleFonts.poppins(fontSize: 13, color: kText3)),
      Text(value, style: GoogleFonts.poppins(fontSize: 13, color: kText1)),
    ]),
  );
}

class _ActionButton extends StatelessWidget {
  final String label;
  final Color color;
  final IconData icon;
  final VoidCallback onTap;
  const _ActionButton(this.label, this.color, this.icon, this.onTap);

  @override
  Widget build(BuildContext context) => OutlinedButton.icon(
    onPressed: onTap,
    icon: Icon(icon, size: 16, color: color),
    label: Text(label, style: GoogleFonts.poppins(fontSize: 13, color: color)),
    style: OutlinedButton.styleFrom(side: BorderSide(color: color.withValues(alpha: 0.5))),
  );
}

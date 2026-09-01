import 'package:flutter/material.dart';

import '../../core/utils/date_format.dart';
import '../../models/restaurant.dart';
import '../../models/review.dart';
import '../../services/auth_service.dart';
import '../../services/database_service.dart';
import '../../widgets/rating_stars.dart';

class AddReviewScreen extends StatefulWidget {
  const AddReviewScreen({super.key, required this.restaurant});

  final Restaurant restaurant;

  @override
  State<AddReviewScreen> createState() => _AddReviewScreenState();
}

class _AddReviewScreenState extends State<AddReviewScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _databaseService = DatabaseService();

  int _rating = 0;
  DateTime _visitDate = DateTime.now();
  bool _isSaving = false;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickVisitDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _visitDate,
      firstDate: DateTime(now.year - 2),
      lastDate: now,
    );

    if (picked != null) {
      setState(() => _visitDate = picked);
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    if (_rating == 0) {
      _showMessage('Please choose a rating.', isError: true);
      return;
    }

    setState(() => _isSaving = true);

    try {
      final user = AuthService().currentUser!;
      final now = DateTime.now();

      await _databaseService.addReview(
        Review(
          id: '',
          userId: user.uid,
          userName: user.displayName ?? 'LocalBite user',
          restaurantId: widget.restaurant.id,
          restaurantName: widget.restaurant.name,
          rating: _rating,
          title: _titleController.text.trim(),
          description: _descriptionController.text.trim(),
          visitDate: _visitDate,
          createdAt: now,
          updatedAt: now,
        ),
      );

      if (!mounted) return;
      _showMessage('Review added.');
      Navigator.pop(context);
    } catch (error) {
      _showMessage(
        'Could not save your review. Please try again.',
        isError: true,
      );
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  void _showMessage(String message, {bool isError = false}) {
    if (!mounted) return;
    final colors = Theme.of(context).colorScheme;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: TextStyle(color: isError ? colors.onError : null),
        ),
        backgroundColor: isError ? colors.error : null,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Add Review')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.restaurant.name,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 24),
                Text('Your Rating', style: theme.textTheme.titleSmall),
                const SizedBox(height: 8),
                RatingSelector(
                  rating: _rating,
                  onChanged: (value) => setState(() => _rating = value),
                ),
                const SizedBox(height: 24),
                Text('Review Title', style: theme.textTheme.titleSmall),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _titleController,
                  textInputAction: TextInputAction.next,
                  decoration: const InputDecoration(
                    hintText: 'Great experience!',
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter a title';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),
                Text('Your Review', style: theme.textTheme.titleSmall),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _descriptionController,
                  maxLines: 5,
                  decoration: const InputDecoration(
                    hintText: 'Tell others about your visit...',
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please write your review';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),
                Text('Visit Date', style: theme.textTheme.titleSmall),
                const SizedBox(height: 8),
                InkWell(
                  onTap: _pickVisitDate,
                  child: InputDecorator(
                    decoration: const InputDecoration(
                      prefixIcon: Icon(Icons.calendar_today_outlined),
                      suffixIcon: Icon(Icons.arrow_drop_down),
                    ),
                    child: Text(
                      formatDate(_visitDate),
                      style: theme.textTheme.bodyLarge,
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                SizedBox(
                  height: 52,
                  child: FilledButton(
                    onPressed: _isSaving ? null : _submit,
                    child: _isSaving
                        ? const SizedBox(
                            height: 22,
                            width: 22,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('SUBMIT REVIEW'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';

import '../../core/utils/date_format.dart';
import '../../models/review.dart';
import '../../services/auth_service.dart';
import '../../services/database_service.dart';
import '../../widgets/rating_stars.dart';

class ReviewFormScreen extends StatefulWidget {
  const ReviewFormScreen({
    super.key,
    required this.restaurantId,
    required this.restaurantName,
    this.existingReview,
  });

  final String restaurantId;
  final String restaurantName;

  /// When this is null the form creates a new review, otherwise it edits
  /// the review that was passed in.
  final Review? existingReview;

  @override
  State<ReviewFormScreen> createState() => _ReviewFormScreenState();
}

class _ReviewFormScreenState extends State<ReviewFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _databaseService = DatabaseService();

  int _rating = 0;
  DateTime _visitDate = DateTime.now();
  bool _isSaving = false;

  bool get _isEditing => widget.existingReview != null;

  @override
  void initState() {
    super.initState();

    final review = widget.existingReview;
    if (review != null) {
      _rating = review.rating;
      _visitDate = review.visitDate;
      _titleController.text = review.title;
      _descriptionController.text = review.description;
    }
  }

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

      final review = Review(
        id: widget.existingReview?.id ?? '',
        userId: user.uid,
        userName: user.displayName ?? 'LocalBite user',
        restaurantId: widget.restaurantId,
        restaurantName: widget.restaurantName,
        rating: _rating,
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        visitDate: _visitDate,
        createdAt: widget.existingReview?.createdAt ?? now,
        updatedAt: now,
      );

      if (_isEditing) {
        await _databaseService.updateReview(review);
      } else {
        await _databaseService.addReview(review);
      }

      if (!mounted) return;
      _showMessage(_isEditing ? 'Review updated.' : 'Review added.');
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
      appBar: AppBar(title: Text(_isEditing ? 'Edit Review' : 'Add Review')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.restaurantName,
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
                        : Text(_isEditing ? 'UPDATE REVIEW' : 'SUBMIT REVIEW'),
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

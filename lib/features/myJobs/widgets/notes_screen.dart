import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:repair_cms/core/app_exports.dart';
import 'package:repair_cms/features/myJobs/models/single_job_model.dart';
import 'package:solar_icons/solar_icons.dart';
import 'package:flutter/material.dart';

// --- MODAL BOTTOM SHEET PACKAGE ---
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';

// --- FIGMA STYLES ---
final Color figmaYellow = const Color(0xFFF0D48C);
final Color figmaBlue = const Color(0xFF007AFF); // Standard blue
// ---------------------

class NotesScreen extends StatefulWidget {
  const NotesScreen({super.key, required this.job});
  final SingleJobModel job;

  @override
  State<NotesScreen> createState() => _NotesScreenState();
}

class _NotesScreenState extends State<NotesScreen> {
  // List to hold notes locally for state management
  List<InternalNote> _internalNotes = [];

  @override
  void initState() {
    super.initState();
    _loadNotes();
  }

  void _loadNotes() {
    // Load notes from the job data
    setState(() {
      _internalNotes = widget.job.data!.defect!.isNotEmpty
          ? widget.job.data!.defect!.first.internalNote ?? <InternalNote>[]
          : <InternalNote>[];
    });
  }

  // --- UPDATED: Use showCupertinoModalBottomSheet with proper configuration ---
  Future<dynamic> _showNoteBottomSheet(BuildContext context, SingleJobModel job, InternalNote? note) {
    return showCupertinoModalBottomSheet(
      context: context,
      backgroundColor: figmaYellow,
      expand: true, // This makes it stack-like and full screen
      enableDrag: true,
      bounce: true,
      useRootNavigator: true,
      builder: (context) => _AddEditNoteSheetContent(
        job: job,
        note: note,
        onNoteSaved: () {
          _loadNotes();
        },
      ),
    );
  }

  // --- Uses the new bottom sheet helper ---
  void _navigateToAddNote(BuildContext context, SingleJobModel job) async {
    final result = await _showNoteBottomSheet(context, job, null);

    if (result == true) {
      _showSuccessDialog(context);
      _loadNotes(); // Refresh the list
    }
  }

  // --- Uses the new bottom sheet helper ---
  void _navigateToEditNote(BuildContext context, SingleJobModel job, InternalNote note) async {
    final result = await _showNoteBottomSheet(context, job, note);

    if (result == true) {
      _showSuccessDialog(context, message: 'Note updated successfully');
      _loadNotes(); // Refresh the list
    }
  }

  // Delete note function
  void _deleteNote(InternalNote note) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Note'),
        content: const Text('Are you sure you want to delete this note?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              // TODO: Implement actual API call to delete note
              print('Deleting note: ${note.id}');

              // Remove from local list
              setState(() {
                _internalNotes.removeWhere((n) => n.id == note.id);
              });

              Navigator.pop(context);
              _showSuccessDialog(context, message: 'Note deleted successfully');
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  // Show the custom success dialog from Figma (Unchanged)
  void _showSuccessDialog(BuildContext context, {String message = 'New note successfully added'}) {
    Dialog? dialog;
    dialog = Dialog(
      alignment: Alignment.topCenter,
      // Position at the top
      insetPadding: EdgeInsets.only(top: 50.h, left: 16.w, right: 16.w),
      // Padding from screen edges
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14.r)),
      child: Padding(
        padding: EdgeInsets.all(16.r),
        child: Column(
          mainAxisSize: MainAxisSize.min, // Crucial to keep dialog small
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.check_circle, color: figmaBlue, size: 24.r),
                SizedBox(width: 12.w),
                Text(
                  message,
                  style: GoogleFonts.roboto(fontSize: 16.sp, fontWeight: FontWeight.w600),
                ),
              ],
            ),
            SizedBox(height: 8.h),
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text('Dismiss', style: TextStyle(color: figmaBlue)),
              ),
            ),
          ],
        ),
      ),
    );

    showDialog(
      context: context,
      builder: (context) {
        // Auto-dismiss after 3 seconds
        Future.delayed(const Duration(seconds: 3), () {
          if (Navigator.of(context).canPop()) {
            Navigator.of(context).pop();
          }
        });
        return dialog!;
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: AppColors.scaffoldBackgroundColor,
        elevation: 0,
        // Back button
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: Colors.black87, size: 20.r),
          onPressed: () => Navigator.of(context).pop(),
        ),
        // Title
        title: Text(
          'Notes',
          style: GoogleFonts.roboto(fontSize: 20.sp, fontWeight: FontWeight.w600, color: Colors.black87),
        ),
        centerTitle: true,
        // Add button
        actions: [
          GestureDetector(
            onTap: () => _navigateToAddNote(context, widget.job),
            child: CircleAvatar(
              radius: 16.r,
              foregroundColor: Colors.white,
              backgroundColor: figmaBlue,
              child: Icon(Icons.add, color: Colors.white, size: 30.r),
            ),
          ),
          SizedBox(width: 8.w),
        ],
      ),
      body: Container(
        margin: EdgeInsets.all(8.h),
        decoration: BoxDecoration(
          color: figmaYellow,
          borderRadius: BorderRadius.vertical(top: Radius.circular(16.r), bottom: Radius.circular(16.r)),
        ),
        child: _buildNotesList(),
      ),
    );
  }

  // Updated notes list widget
  Widget _buildNotesList() {
    return RefreshIndicator(
      onRefresh: () async {
        _loadNotes();
      },
      backgroundColor: figmaYellow,
      color: figmaBlue,
      child: ListView(
        padding: EdgeInsets.all(16.r),
        children: [
          if (_internalNotes.isNotEmpty) ..._internalNotes.map((note) => _buildNoteItem(note)),
          if (_internalNotes.isEmpty)
            _buildNoteItem(
              // Pass dummy data for the empty state
              InternalNote(
                text: 'Add the first note for this job',
                userName: 'System',
                createdAt: widget.job.data!.dueDate,
                userId: widget.job.data!.userId,
                id: widget.job.data!.sId,
              ),
              isEmptyState: true,
            ),
        ],
      ),
    );
  }

  // Updated note item widget to match Figma
  Widget _buildNoteItem(InternalNote note, {bool isEmptyState = false}) {
    final String content = note.text!;
    final String author = note.userName!;
    final String time = _formatTimestamp(note.createdAt.toString());

    return Padding(
      padding: EdgeInsets.only(bottom: 24.h), // Spacing between notes
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // The note text
          Text(
            isEmptyState ? 'No notes yet' : content,
            style: GoogleFonts.roboto(
              fontSize: 14.sp,
              color: Colors.black87,
              height: 1.4,
              // Make title bold if it's the empty state
              fontWeight: isEmptyState ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
          SizedBox(height: 8.h),
          // Date and Author
          Text(
            isEmptyState ? content : "$time, $author",
            style: GoogleFonts.roboto(fontSize: 12.sp, color: Colors.grey.shade600),
          ),
          SizedBox(height: 8.h),
          // Show Edit/Delete only if it's NOT the empty state
          if (!isEmptyState)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Edit Button
                InkWell(
                  onTap: () => _navigateToEditNote(context, widget.job, note),
                  child: Row(
                    children: [
                      Icon(FontAwesomeIcons.solidPenToSquare, color: figmaBlue, size: 16.r),
                      SizedBox(width: 2.w),
                      Text(
                        'Edit',
                        style: GoogleFonts.roboto(color: figmaBlue, fontSize: 14.sp, fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 16.w),
                // Delete Button
                InkWell(
                  onTap: () => _deleteNote(note),
                  child: Row(
                    children: [
                      Icon(Icons.delete, color: Colors.red, size: 16.r),
                      SizedBox(width: 2.w),
                      Text(
                        'delete',
                        style: GoogleFonts.roboto(color: Colors.red, fontSize: 14.sp, fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          Container(height: 2, width: double.infinity, color: Colors.grey.shade300),
        ],
      ),
    );
  }
}

// -----------------------------------------------------------------
// --- Sheet content widget (Updated with proper keyboard handling) ---
// -----------------------------------------------------------------
class _AddEditNoteSheetContent extends StatefulWidget {
  const _AddEditNoteSheetContent({required this.job, this.note, required this.onNoteSaved});
  final SingleJobModel job;
  final InternalNote? note; // If note is null, it's a new note
  final VoidCallback onNoteSaved;

  @override
  State<_AddEditNoteSheetContent> createState() => _AddEditNoteSheetContentState();
}

class _AddEditNoteSheetContentState extends State<_AddEditNoteSheetContent> {
  late TextEditingController _controller;
  final FocusNode _focusNode = FocusNode();
  bool get isEditing => widget.note != null;

  @override
  void initState() {
    super.initState();
    // Initialize controller with existing text if editing
    _controller = TextEditingController(text: widget.note?.text ?? '');
    // Auto-focus and show keyboard
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _saveNote() {
    final noteText = _controller.text.trim();
    if (noteText.isEmpty) {
      // Don't save empty notes
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Note cannot be empty'), backgroundColor: Colors.red));
      return;
    }

    // --- TODO: API CALL ---
    print('Saving note for job ${widget.job.data!.sId}: $noteText');

    // Call the callback to notify parent
    widget.onNoteSaved();

    // Pop the screen and return 'true' to signal success
    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: figmaYellow,
      child: SafeArea(
        top: false,
        child: Container(
          height: MediaQuery.of(context).size.height * 0.9,
          padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
          child: Column(
            children: [
              // --- Sheet Handle ---
              Padding(
                padding: EdgeInsets.symmetric(vertical: 8.h),
                child: Container(
                  width: 40.w,
                  height: 5.h,
                  decoration: BoxDecoration(color: Colors.grey.shade400, borderRadius: BorderRadius.circular(2.5.r)),
                ),
              ),

              // --- Custom "App Bar" using Stack for centering ---
              Padding(
                padding: EdgeInsets.fromLTRB(16.r, 8.r, 16.r, 16.r),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Centered Title
                    Text(
                      isEditing ? 'Edit note' : 'Add a note',
                      style: GoogleFonts.roboto(fontSize: 20.sp, fontWeight: FontWeight.w600, color: Colors.black87),
                    ),
                    // Close Button
                    Align(
                      alignment: Alignment.centerLeft,
                      child: IconButton(
                        icon: Icon(Icons.close, color: Colors.black87, size: 20.r),
                        style: IconButton.styleFrom(
                          backgroundColor: Colors.grey.shade300,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
                          padding: EdgeInsets.all(8.r),
                        ),
                        onPressed: () => Navigator.pop(context), // Just pop, no success
                      ),
                    ),
                  ],
                ),
              ),

              // --- Text Field Area ---
              Expanded(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.r),
                  child: TextField(
                    controller: _controller,
                    focusNode: _focusNode,
                    maxLines: null, // Allows multiline
                    expands: true, // Expands to fill space
                    style: GoogleFonts.roboto(fontSize: 16.sp, height: 1.5),
                    decoration: InputDecoration(
                      hintText: 'write a note...',
                      border: InputBorder.none, // No line
                      hintStyle: GoogleFonts.roboto(fontSize: 16.sp, color: Colors.grey.shade600),
                    ),
                  ),
                ),
              ),

              // --- Save Button (stuck to keyboard) ---
              Padding(
                padding: EdgeInsets.only(bottom: 16.h, left: 16.w, right: 16.w, top: 16.h),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: figmaBlue,
                      padding: EdgeInsets.symmetric(vertical: 16.h),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                    ),
                    onPressed: _saveNote,
                    child: Text(
                      'Save',
                      style: GoogleFonts.roboto(fontSize: 16.sp, fontWeight: FontWeight.w600, color: Colors.white),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// --- HELPER FUNCTIONS (Unchanged) ---

String _formatTimestamp(String timestamp) {
  try {
    // Handle different timestamp formats
    int timestampValue;

    // Check if it's a numeric string (milliseconds since epoch)
    if (RegExp(r'^\d+$').hasMatch(timestamp)) {
      timestampValue = int.parse(timestamp);
    }
    // Check if it's an ISO string format
    else if (timestamp.contains('T')) {
      final date = DateTime.parse(timestamp);
      return '${date.day}. ${_getMonthName(date.month)} ${date.year} - ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
    }
    // If it's already in a readable format, return as is
    else {
      return timestamp;
    }

    final date = DateTime.fromMillisecondsSinceEpoch(timestampValue);
    return '${date.day}. ${_getMonthName(date.month)} ${date.year} - ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  } catch (e) {
    debugPrint('Error formatting timestamp: $e');
    return 'Invalid date';
  }
}

String _getMonthName(int month) {
  const monthNames = [
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December',
  ];
  return monthNames[month - 1];
}

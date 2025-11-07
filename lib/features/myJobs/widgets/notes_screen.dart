// ignore_for_file: use_build_context_synchronously

import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get_storage/get_storage.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:repair_cms/core/app_exports.dart';
import 'package:repair_cms/core/helpers/snakbar_demo.dart';
import 'package:repair_cms/features/myJobs/cubits/job_cubit.dart';
import 'package:repair_cms/features/myJobs/models/single_job_model.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';

// --- FIGMA STYLES ---
final Color figmaYellow = const Color(0xFFF0D48C);
final Color figmaBlue = const Color(0xFF007AFF);
// ---------------------

class NotesScreen extends StatefulWidget {
  const NotesScreen({super.key, required this.job});
  final SingleJobModel job;

  @override
  State<NotesScreen> createState() => _NotesScreenState();
}

class _NotesScreenState extends State<NotesScreen> {
  List<InternalNote> _internalNotes = [];
  bool _isMounted = false;

  @override
  void initState() {
    super.initState();
    _isMounted = true;
    _loadNotes();
  }

  @override
  void dispose() {
    _isMounted = false;
    super.dispose();
  }

  void _loadNotes() {
    if (!_isMounted) return;

    setState(() {
      _internalNotes = widget.job.data!.defect!.isNotEmpty
          ? widget.job.data!.defect!.first.internalNote ?? <InternalNote>[]
          : <InternalNote>[];
    });
  }

  Future<dynamic> _showNoteBottomSheet(BuildContext context, SingleJobModel job, InternalNote? note) {
    return showCupertinoModalBottomSheet(
      context: context,
      backgroundColor: figmaYellow,
      expand: true,
      enableDrag: true,
      bounce: true,
      useRootNavigator: true,
      builder: (context) => BlocProvider.value(
        value: BlocProvider.of<JobCubit>(context),
        child: _AddEditNoteSheetContent(
          job: job,
          note: note,
          onNoteSaved: () {
            if (_isMounted) {
              _loadNotes();
            }
          },
        ),
      ),
    );
  }

  void _navigateToAddNote(BuildContext context, SingleJobModel job) async {
    final result = await _showNoteBottomSheet(context, job, null);
    if (result == true && _isMounted) {
      _showSuccessDialog(context);
    }
  }

  void _navigateToEditNote(BuildContext context, SingleJobModel job, InternalNote note) async {
    final result = await _showNoteBottomSheet(context, job, note);
    if (result == true && _isMounted) {
      _showSuccessDialog(context, message: 'Note updated successfully');
    }
  }

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
              _performDeleteNote(note);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _performDeleteNote(InternalNote note) {
    final jobCubit = context.read<JobCubit>();
    final storage = GetStorage();
    final userId = storage.read('userId');
    final userName = storage.read('fullName');

    if (userId == null || userName == null) {
      _showSnackBar('User information not found', isError: true);
      return;
    }

    jobCubit.deleteJobNote(jobId: widget.job.data?.sId ?? '', noteId: note.id ?? '');
    Navigator.pop(context);
  }

  void _showSnackBar(String message, {bool isError = false}) {
    if (!_isMounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _showSuccessDialog(BuildContext context, {String message = 'New note successfully added'}) {
    if (!_isMounted) return;

    Dialog? dialog;
    dialog = Dialog(
      alignment: Alignment.topCenter,
      insetPadding: EdgeInsets.only(top: 50.h, left: 16.w, right: 16.w),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14.r)),
      child: Padding(
        padding: EdgeInsets.all(16.r),
        child: Column(
          mainAxisSize: MainAxisSize.min,
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
                onPressed: () {
                  if (_isMounted && Navigator.of(context).canPop()) {
                    Navigator.of(context).pop();
                  }
                },
                child: Text('Dismiss', style: TextStyle(color: figmaBlue)),
              ),
            ),
          ],
        ),
      ),
    );

    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) {
        Future.delayed(const Duration(seconds: 3), () {
          if (_isMounted && Navigator.of(context).canPop()) {
            Navigator.of(context).pop();
          }
        });
        return dialog!;
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<JobCubit, JobStates>(
      listener: (context, state) {
        if (!_isMounted) return;

        if (state is JobNoteUpdateSuccess) {
          _loadNotes();
          _showSnackBar('Operation completed successfully');
        } else if (state is JobActionError) {
          _showSnackBar(state.message, isError: true);
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.scaffoldBackgroundColor,
        appBar: AppBar(
          backgroundColor: AppColors.scaffoldBackgroundColor,
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios, color: Colors.black87, size: 20.r),
            onPressed: () => Navigator.of(context).pop(),
          ),
          title: Text(
            'Notes',
            style: GoogleFonts.roboto(fontSize: 20.sp, fontWeight: FontWeight.w600, color: Colors.black87),
          ),
          centerTitle: true,
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
      ),
    );
  }

  Widget _buildNotesList() {
    return RefreshIndicator(
      onRefresh: () async {
        if (_isMounted) {
          _loadNotes();
        }
      },
      backgroundColor: figmaYellow,
      color: figmaBlue,
      child: ListView(
        padding: EdgeInsets.all(16.r),
        children: [
          if (_internalNotes.isNotEmpty) ..._internalNotes.map((note) => _buildNoteItem(note)),
          if (_internalNotes.isEmpty)
            _buildNoteItem(
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

  Widget _buildNoteItem(InternalNote note, {bool isEmptyState = false}) {
    final String content = note.text!;
    final String author = note.userName!;
    final String time = _formatTimestamp(note.createdAt.toString());

    return Padding(
      padding: EdgeInsets.only(bottom: 24.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            isEmptyState ? 'No notes yet' : content,
            style: GoogleFonts.roboto(
              fontSize: 14.sp,
              color: Colors.black87,
              height: 1.4,
              fontWeight: isEmptyState ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            isEmptyState ? content : "$time, $author",
            style: GoogleFonts.roboto(fontSize: 12.sp, color: Colors.grey.shade600),
          ),
          SizedBox(height: 8.h),
          if (!isEmptyState)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
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

class _AddEditNoteSheetContent extends StatefulWidget {
  const _AddEditNoteSheetContent({required this.job, this.note, required this.onNoteSaved});
  final SingleJobModel job;
  final InternalNote? note;
  final VoidCallback onNoteSaved;

  @override
  State<_AddEditNoteSheetContent> createState() => _AddEditNoteSheetContentState();
}

class _AddEditNoteSheetContentState extends State<_AddEditNoteSheetContent> {
  late TextEditingController _controller;
  final FocusNode _focusNode = FocusNode();
  bool get isEditing => widget.note != null;
  bool _isLoading = false;
  bool _isMounted = false;

  @override
  void initState() {
    super.initState();
    _isMounted = true;
    _controller = TextEditingController(text: widget.note?.text ?? '');
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_isMounted) {
        _focusNode.requestFocus();
      }
    });
  }

  @override
  void dispose() {
    _isMounted = false;
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _saveNote() {
    final noteText = _controller.text.trim();
    if (noteText.isEmpty) {
      _showSnackBar('Note cannot be empty', isError: true);
      return;
    }

    if (!_isMounted) return;

    setState(() {
      _isLoading = true;
    });

    final jobCubit = context.read<JobCubit>();
    final storage = GetStorage();
    final userId = storage.read('userId');
    final userName = storage.read('fullName');

    if (userId == null || userName == null) {
      _showSnackBar('User information not found', isError: true);
      if (_isMounted) {
        setState(() {
          _isLoading = false;
        });
      }
      return;
    }

    Future<void> saveAction;

    if (isEditing) {
      saveAction = jobCubit.updateJobNote(
        jobId: widget.job.data?.sId ?? '',
        noteId: widget.note?.id ?? '',
        noteText: noteText,
        userId: userId,
        userName: userName,
      );
    } else {
      saveAction = jobCubit.addJobNote(
        jobId: widget.job.data?.sId ?? '',
        noteText: noteText,
        userId: userId,
        userName: userName,
      );
    }

    saveAction
        .then((_) {
          if (_isMounted) {
            setState(() {
              _isLoading = false;
            });
            widget.onNoteSaved();
            Navigator.pop(context, true);
          }
        })
        .catchError((error) {
          if (_isMounted) {
            setState(() {
              _isLoading = false;
            });
            _showSnackBar('Failed to save note: $error', isError: true);
          }
        });
  }

  void _showSnackBar(String message, {bool isError = false}) {
    if (!_isMounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
        duration: const Duration(seconds: 3),
      ),
    );
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
              Padding(
                padding: EdgeInsets.symmetric(vertical: 8.h),
                child: Container(
                  width: 40.w,
                  height: 5.h,
                  decoration: BoxDecoration(color: Colors.grey.shade400, borderRadius: BorderRadius.circular(2.5.r)),
                ),
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(16.r, 8.r, 16.r, 16.r),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Text(
                      isEditing ? 'Edit note' : 'Add a note',
                      style: GoogleFonts.roboto(fontSize: 20.sp, fontWeight: FontWeight.w600, color: Colors.black87),
                    ),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: IconButton(
                        icon: Icon(Icons.close, color: Colors.black87, size: 20.r),
                        style: IconButton.styleFrom(
                          backgroundColor: Colors.grey.shade300,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
                          padding: EdgeInsets.all(8.r),
                        ),
                        onPressed: _isLoading ? null : () => Navigator.pop(context),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: AbsorbPointer(
                  absorbing: _isLoading,
                  child: Opacity(
                    opacity: _isLoading ? 0.6 : 1.0,
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16.r),
                      child: TextField(
                        controller: _controller,
                        focusNode: _focusNode,
                        maxLines: null,
                        expands: true,
                        style: GoogleFonts.roboto(fontSize: 16.sp, height: 1.5),
                        decoration: InputDecoration(
                          hintText: 'write a note...',
                          border: InputBorder.none,
                          hintStyle: GoogleFonts.roboto(fontSize: 16.sp, color: Colors.grey.shade600),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(bottom: 16.h, left: 16.w, right: 16.w, top: 16.h),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _isLoading ? Colors.grey : figmaBlue,
                      padding: EdgeInsets.symmetric(vertical: 16.h),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                    ),
                    onPressed: _isLoading ? null : _saveNote,
                    child: _isLoading
                        ? SizedBox(
                            width: 20.w,
                            height: 20.h,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                          )
                        : Text(
                            'Save',
                            style: GoogleFonts.roboto(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
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

// Helper functions
String _formatTimestamp(String timestamp) {
  try {
    int timestampValue;

    if (RegExp(r'^\d+$').hasMatch(timestamp)) {
      timestampValue = int.parse(timestamp);
    } else if (timestamp.contains('T')) {
      final date = DateTime.parse(timestamp);
      return '${date.day}. ${_getMonthName(date.month)} ${date.year} - ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
    } else {
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

import 'package:flutter/cupertino.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:repair_cms/core/app_exports.dart';
import 'package:repair_cms/features/myJobs/models/job_list_response.dart';

class NotesScreen extends StatefulWidget {
  const NotesScreen({super.key, required this.job});
  final Job job;

  @override
  State<NotesScreen> createState() => _NotesScreenState();
}

class _NotesScreenState extends State<NotesScreen> {
  @override
  Widget build(BuildContext context) {
    return _buildNotesScreen(widget.job, context: context);
  }
}

// Updated notes screen with real internal notes
Widget _buildNotesScreen(Job job, {BuildContext? context}) {
  final internalNotes = job.defect.isNotEmpty ? job.defect.first.internalNote : [];

  return Column(
    children: [
      Container(
        color: Colors.white,
        padding: EdgeInsets.all(16.r),
        width: double.infinity,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Job Notes',
              style: GoogleFonts.roboto(fontSize: 20.sp, fontWeight: FontWeight.w600, color: Colors.black87),
            ),
            IconButton(
              onPressed: () {
                _showAddNoteDialog(context!);
              },
              icon: const Icon(Icons.add, color: Colors.blue),
            ),
          ],
        ),
      ),

      Expanded(
        child: ListView(
          padding: EdgeInsets.all(16.r),
          children: [
            if (internalNotes.isNotEmpty)
              ...internalNotes.map(
                (note) => _buildNoteItem('Internal Note', note.text, note.userName, _formatTimestamp(note.createdAt)),
              ),

            if (internalNotes.isEmpty)
              _buildNoteItem('No notes yet', 'Add the first note for this job', 'System', job.formattedDate),
          ],
        ),
      ),
    ],
  );
}

void _showAddNoteDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Add Note'),
      content: TextField(maxLines: 5, decoration: const InputDecoration(hintText: 'Enter your note...')),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
        TextButton(
          onPressed: () {
            // Add note logic here
            Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Note added successfully')));
          },
          child: const Text('Add Note'),
        ),
      ],
    ),
  );
}

Widget _buildNoteItem(String title, String content, String author, String time) {
  return Container(
    padding: EdgeInsets.all(16.r),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12.r),
      boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 8, offset: const Offset(0, 2))],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: GoogleFonts.roboto(fontSize: 16.sp, fontWeight: FontWeight.w600, color: Colors.black87),
            ),
            Icon(Icons.more_vert, color: Colors.grey.shade400),
          ],
        ),
        SizedBox(height: 8.h),
        Text(
          content,
          style: GoogleFonts.roboto(fontSize: 14.sp, color: Colors.black87, height: 1.4),
        ),
        SizedBox(height: 12.h),
        Row(
          children: [
            Icon(Icons.person, size: 16, color: Colors.grey.shade500),
            SizedBox(width: 4.w),
            Text(
              author,
              style: GoogleFonts.roboto(fontSize: 12.sp, color: Colors.grey.shade600, fontWeight: FontWeight.w500),
            ),
            SizedBox(width: 16.w),
            Icon(Icons.access_time, size: 16, color: Colors.grey.shade500),
            SizedBox(width: 4.w),
            Text(
              time,
              style: GoogleFonts.roboto(fontSize: 12.sp, color: Colors.grey.shade600),
            ),
          ],
        ),
      ],
    ),
  );
}

String _formatTimestamp(int timestamp) {
  final date = DateTime.fromMillisecondsSinceEpoch(timestamp);
  return '${date.day}. ${_getMonthName(date.month)} ${date.year} - ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
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

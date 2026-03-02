// ignore_for_file: use_build_context_synchronously, curly_braces_in_flow_control_structures

import 'dart:io' as io;

import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get_storage/get_storage.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:repair_cms/core/app_exports.dart';
import 'package:repair_cms/core/helpers/snakbar_demo.dart';
import 'package:repair_cms/core/helpers/storage.dart';
import 'package:repair_cms/features/jobBooking/screens/job_device_label_screen.dart';
import 'package:repair_cms/features/jobBooking/screens/job_thermal_receipt_preview_screen.dart';
import 'package:repair_cms/features/messeges/chat_conversation_screen.dart';
import 'package:repair_cms/features/myJobs/cubits/job_cubit.dart';
import 'package:repair_cms/features/myJobs/models/assign_user_list_model.dart';
import 'package:repair_cms/features/myJobs/models/single_job_model.dart';
import 'package:repair_cms/features/myJobs/screens/receipt_screen.dart';
import 'package:repair_cms/features/myJobs/widgets/files_screen.dart';
import 'package:repair_cms/features/myJobs/widgets/status_screen.dart';
import 'package:solar_icons/solar_icons.dart';
import 'package:repair_cms/features/jobBooking/models/create_job_request.dart'
    as job_booking;

// ─────────────────────────────────────────────
// Colors
// ─────────────────────────────────────────────


// ─────────────────────────────────────────────
// JobDetailsScreen – outer shell (loads job & orchestrates state)
// ─────────────────────────────────────────────
class JobDetailsScreen extends StatefulWidget {
  final String jobId;
  const JobDetailsScreen({super.key, required this.jobId});

  @override
  State<JobDetailsScreen> createState() => _JobDetailsScreenState();
}

class _JobDetailsScreenState extends State<JobDetailsScreen> {
  SingleJobModel? _currentJob;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<JobCubit>().getJobById(widget.jobId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<JobCubit, JobStates>(
      listener: (context, state) {
        if (state is JobError) {
          SnackbarDemo(
            message: 'Error: ${state.message}',
          ).showCustomSnackbar(context);
        }
        if (state is JobDetailSuccess) {
          setState(() => _currentJob = state.job);
        }
        for (final s in [state]) {
          SingleJobModel? updated;
          if (s is JobStatusUpdated) {
            updated = s.job;
          } else if (s is JobPrioritySuccess)
            updated = s.job;
          else if (s is JobStatusUpdateSuccess)
            updated = s.job;
          else if (s is JobNoteUpdateSuccess)
            updated = s.job;
          else if (s is JobFileUploadSuccess)
            updated = s.job;
          else if (s is JobFileDeleteSuccess)
            updated = s.job;
          if (updated != null) setState(() => _currentJob = updated);
        }
      },
      child: PopScope(
        canPop: true,
        onPopInvokedWithResult: (didPop, _) =>
            context.read<JobCubit>().getJobs(),
        child: Scaffold(
          backgroundColor: AppColors.kBg,
          body: BlocBuilder<JobCubit, JobStates>(
            builder: (context, state) {
              if (_currentJob != null)
                return _UnifiedJobDetails(job: _currentJob!);
              if (state is JobLoading)
                return const Center(child: CircularProgressIndicator());
              if (state is JobDetailSuccess) {
                _currentJob = state.job;
                return _UnifiedJobDetails(job: state.job);
              }
              if (state is JobError)
                return Center(child: Text('Error: ${state.message}'));
              return const Center(child: CircularProgressIndicator());
            },
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// _UnifiedJobDetails – the actual single-page scrollable screen
// ─────────────────────────────────────────────
class _UnifiedJobDetails extends StatefulWidget {
  final SingleJobModel job;
  const _UnifiedJobDetails({required this.job});

  @override
  State<_UnifiedJobDetails> createState() => _UnifiedJobDetailsState();
}

class _UnifiedJobDetailsState extends State<_UnifiedJobDetails> {
  // ── job complete / device returned state ──
  bool _isJobComplete = false;
  bool _isDeviceReturned = false;

  // ── more menu overlay ──
  bool _menuVisible = false;

  // ── assignee ──
  List<User> _availableUsers = [];
  bool _isLoadingUsers = false;
  String? _selectedUserId;
  String _selectedAssigneeName = 'Select assignee';
  String _selectedPriority = 'Neutral';
  String _selectedDueDate = 'Select due date';

  // ── notes ──
  List<InternalNote> _internalNotes = [];

  // ── files ──
  final ImagePicker _imagePicker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _init();
    context.read<JobCubit>().getAssignUserList();
    context.read<JobCubit>().getStatusSettings();
  }

  void _init() {
    final d = widget.job.data!;
    _isJobComplete = d.isJobCompleted == true;
    _isDeviceReturned = d.isDeviceReturned == true;

    if (d.dueDate != null && d.dueDate!.isNotEmpty) {
      try {
        final dt = DateTime.parse(d.dueDate!);
        _selectedDueDate = '${dt.day}. ${_monthName(dt.month)} ${dt.year}';
      } catch (_) {}
    }
    if (d.jobPriority != null && d.jobPriority!.isNotEmpty) {
      _selectedPriority = _cap(d.jobPriority!);
    }
    _internalNotes = d.defect?.isNotEmpty == true
        ? d.defect!.first.internalNote ?? []
        : [];
  }

  @override
  void didUpdateWidget(_UnifiedJobDetails old) {
    super.didUpdateWidget(old);
    if (old.job.data?.sId != widget.job.data?.sId ||
        old.job.data?.isJobCompleted != widget.job.data?.isJobCompleted ||
        old.job.data?.isDeviceReturned != widget.job.data?.isDeviceReturned) {
      _init();
    }
  }

  // ─── helpers ──────────────────────────────

  String _cap(String s) => s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);
  String _monthName(int m) => const [
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
  ][m - 1];

  String _defectType() {
    final d = widget.job.data!;
    if (d.defect?.isNotEmpty == true &&
        d.defect!.first.defect?.isNotEmpty == true) {
      return d.defect!.first.defect!.first.value ?? 'Not specified';
    }
    return 'Not specified';
  }

  String _problemDesc() {
    final d = widget.job.data!;
    if (d.defect?.isNotEmpty == true)
      return d.defect!.first.description ?? 'No description';
    return 'No description';
  }

  String _latestStatusTitle() {
    final statuses = widget.job.data?.jobStatus ?? [];
    if (statuses.isEmpty) return 'No status';
    statuses.sort(
      (a, b) => (b.createAtStatus ?? 0).compareTo(a.createAtStatus ?? 0),
    );
    return _formatStatusTitle(statuses.first.title ?? '');
  }

  String _latestStatusDate() {
    final statuses = widget.job.data?.jobStatus ?? [];
    if (statuses.isEmpty) return '';
    statuses.sort(
      (a, b) => (b.createAtStatus ?? 0).compareTo(a.createAtStatus ?? 0),
    );
    final ts = statuses.first.createAtStatus;
    if (ts == null) return '';
    final dt = DateTime.fromMillisecondsSinceEpoch(ts);
    return '${dt.day.toString().padLeft(2, '0')}.${dt.month.toString().padLeft(2, '0')}.${dt.year}';
  }

  String _formatStatusTitle(String t) => t
      .split('_')
      .map(
        (w) =>
            w.isEmpty ? w : w[0].toUpperCase() + w.substring(1).toLowerCase(),
      )
      .join(' ');

  String _priorityLabel() => _selectedPriority;
  Color _priorityColor() {
    switch (_selectedPriority.toLowerCase()) {
      case 'urgent':
        return Colors.red;
      case 'high':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  String _contactName() {
    final d = widget.job.data!;
    if (d.customerDetails != null) {
      return '${d.customerDetails!.firstName ?? ''} ${d.customerDetails!.lastName ?? ''}'
          .trim();
    }
    if (d.contact?.isNotEmpty == true) {
      return '${d.contact!.first.firstName ?? ''} ${d.contact!.first.lastName ?? ''}'
          .trim();
    }
    return 'Unknown Contact';
  }

  User? _findUser(String id) {
    try {
      return _availableUsers.firstWhere((u) => u.id == id);
    } catch (_) {
      return null;
    }
  }

  String _initials(String name) {
    final parts = name.split(' ');
    if (parts.length >= 2) return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    return name.isNotEmpty ? name[0].toUpperCase() : 'U';
  }

  // ─── "..." overlay menu ─────────────────────

  void _toggleMoreMenu() => setState(() => _menuVisible = !_menuVisible);
  void _closeMoreMenu() => setState(() => _menuVisible = false);

  Widget _buildMoreMenuOverlay() {
    return Positioned(
      top: 8.h,
      right: 16.w,
      child: Material(
        color: Colors.transparent,
        child: Container(
          width: 220.w,
          padding: EdgeInsets.all(10.r),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20.r),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.12),
                blurRadius: 24,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _menuButton(
                label: _isJobComplete
                    ? 'Set Job Incomplete'
                    : 'Set Job Complete',
                onTap: () {
                  _closeMoreMenu();
                  _isJobComplete
                      ? _showIncompleteConfirmation()
                      : _showCompleteBottomSheet();
                },
              ),
              SizedBox(height: 8.h),
              _menuButton(
                label: _isDeviceReturned ? 'Device Returned' : 'Return Device',
                onTap: () {
                  _closeMoreMenu();
                  _isDeviceReturned
                      ? _setDeviceNotReturned()
                      : _showReturnDeviceConfirmation();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _menuButton({required String label, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(vertical: 14.h, horizontal: 16.w),
        decoration: BoxDecoration(
          color: const Color(0xFFEEEFF4),
          borderRadius: BorderRadius.circular(14.r),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: GoogleFonts.roboto(
            fontSize: 16.sp,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF1E2D4D),
          ),
        ),
      ),
    );
  }

  void _showCompleteBottomSheet() {
    final notesCtrl = TextEditingController();
    bool sendEmail = true;
    showCupertinoModalPopup<void>(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (ctx, ss) => CupertinoActionSheet(
          title: Text(
            'Set Job Complete',
            style: TextStyle(fontSize: 17.sp, fontWeight: FontWeight.w600),
          ),
          message: Column(
            children: [
              SizedBox(height: 12.h),
              Container(
                padding: EdgeInsets.all(8.r),
                decoration: BoxDecoration(
                  color: CupertinoColors.systemGrey6,
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: CupertinoTextField(
                  controller: notesCtrl,
                  placeholder: 'Add notes...',
                  maxLines: 3,
                  style: TextStyle(fontSize: 15.sp),
                  padding: EdgeInsets.all(10.r),
                ),
              ),
              SizedBox(height: 12.h),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                decoration: BoxDecoration(
                  color: CupertinoColors.systemGrey6,
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(CupertinoIcons.mail, size: 18.sp, color: AppColors.kBlue),
                        SizedBox(width: 8.w),
                        Text(
                          'Send email to customer',
                          style: TextStyle(fontSize: 15.sp),
                        ),
                      ],
                    ),
                    CupertinoSwitch(
                      value: sendEmail,
                      onChanged: (v) => ss(() => sendEmail = v),
                    ),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            CupertinoActionSheetAction(
              isDefaultAction: true,
              onPressed: () {
                Navigator.pop(ctx);
                context.read<JobCubit>().setJobAsComplete(
                  jobId: widget.job.data!.sId!,
                  userId: storage.read('userId'),
                  userName: storage.read('fullName'),
                  email: storage.read('email'),
                  notes: notesCtrl.text,
                  sendNotification: sendEmail,
                  currentJob: widget.job,
                );
              },
              child: Text(
                'Confirm Complete',
                style: TextStyle(fontSize: 17.sp),
              ),
            ),
          ],
          cancelButton: CupertinoActionSheetAction(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Cancel', style: TextStyle(fontSize: 17.sp)),
          ),
        ),
      ),
    );
  }

  void _showIncompleteConfirmation() {
    showCupertinoDialog<void>(
      context: context,
      builder: (_) => CupertinoAlertDialog(
        title: Text(
          'Set Job as Incomplete?',
          style: TextStyle(fontSize: 17.sp, fontWeight: FontWeight.w600),
        ),
        content: Padding(
          padding: EdgeInsets.only(top: 8.h),
          child: Text(
            'This will change status to "In Progress".',
            style: TextStyle(fontSize: 13.sp),
          ),
        ),
        actions: [
          CupertinoDialogAction(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          CupertinoDialogAction(
            isDefaultAction: true,
            onPressed: () {
              Navigator.pop(context);
              context.read<JobCubit>().setJobAsIncomplete(
                jobId: widget.job.data!.sId!,
                userId: storage.read('userId'),
                userName: storage.read('fullName'),
                email: storage.read('email'),
                notes: 'Device is in progress',
                sendNotification: true,
                currentJob: widget.job,
              );
            },
            child: Text(
              'Mark Incomplete',
              style: TextStyle(
                fontSize: 17.sp,
                color: CupertinoColors.systemOrange,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showReturnDeviceConfirmation() {
    showCupertinoDialog<void>(
      context: context,
      builder: (_) => CupertinoAlertDialog(
        title: Text(
          'Mark Device as Returned?',
          style: TextStyle(fontSize: 17.sp, fontWeight: FontWeight.w600),
        ),
        content: Padding(
          padding: EdgeInsets.only(top: 8.h),
          child: Text(
            'This will archive the job and move it to trash.',
            style: TextStyle(fontSize: 13.sp),
          ),
        ),
        actions: [
          CupertinoDialogAction(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          CupertinoDialogAction(
            isDefaultAction: true,
            onPressed: () {
              Navigator.pop(context);
              context.read<JobCubit>().setDeviceAsReturned(
                jobId: widget.job.data!.sId!,
                userId: storage.read('userId'),
                userName: storage.read('fullName'),
                email: storage.read('email'),
                notes: 'move to trash',
                sendNotification: true,
              );
            },
            child: Text(
              'Mark Returned',
              style: TextStyle(
                fontSize: 17.sp,
                color: CupertinoColors.systemGreen,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _setDeviceNotReturned() {
    context.read<JobCubit>().setDeviceAsNotReturned(
      jobId: widget.job.data!.sId!,
      userId: storage.read('userId'),
      userName: storage.read('fullName'),
      email: storage.read('email'),
      notes: 'Device is in progress',
      sendNotification: true,
    );
  }

  // ─── notes bottom sheet ──────────────────

  Future<void> _openNoteSheet([InternalNote? note]) async {
    await showCupertinoModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      expand: true,
      enableDrag: true,
      bounce: true,
      useRootNavigator: true,
      topRadius: Radius.circular(12.r),
      barrierColor: Colors.black.withValues(alpha: 0.4),
      builder: (ctx) => BlocProvider.value(
        value: BlocProvider.of<JobCubit>(context),
        child: _NoteSheet(
          job: widget.job,
          note: note,
          onSaved: () {
            final j = (context.read<JobCubit>().state is JobNoteUpdateSuccess)
                ? (context.read<JobCubit>().state as JobNoteUpdateSuccess).job
                : widget.job;
            setState(() {
              _internalNotes = j.data?.defect?.isNotEmpty == true
                  ? j.data!.defect!.first.internalNote ?? []
                  : [];
            });
          },
        ),
      ),
    );
  }

  void _deleteNote(InternalNote note) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete Note'),
        content: const Text('Are you sure you want to delete this note?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              context.read<JobCubit>().deleteJobNote(
                jobId: widget.job.data?.sId ?? '',
                noteId: note.id ?? '',
              );
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  // ─── file upload ─────────────────────────

  void _showUploadSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => Padding(
        padding: EdgeInsets.symmetric(vertical: 24.h, horizontal: 16.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Select upload method',
              style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w600),
            ),
            SizedBox(height: 32.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _uploadOption(Icons.camera_alt_outlined, 'Camera', () {
                  Navigator.pop(context);
                  _pickCamera();
                }),
                _uploadOption(Icons.image_outlined, 'Gallery', () {
                  Navigator.pop(context);
                  _pickGallery();
                }),
                _uploadOption(Icons.folder_outlined, 'Document', () {
                  Navigator.pop(context);
                  _pickDocument();
                }),
              ],
            ),
            SizedBox(height: 16.h),
          ],
        ),
      ),
    );
  }

  Widget _uploadOption(IconData icon, String label, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 64.w,
            height: 64.h,
            decoration: BoxDecoration(
              color: const Color(0xFFF5F5F5),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Icon(icon, size: 32.sp, color: Colors.black87),
          ),
          SizedBox(height: 8.h),
          Text(
            label,
            style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  Future<void> _pickCamera() async {
    final f = await _imagePicker.pickImage(
      source: ImageSource.camera,
      imageQuality: 85,
    );
    if (f != null) _upload(f.path, f.name);
  }

  Future<void> _pickGallery() async {
    final f = await _imagePicker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );
    if (f != null) _upload(f.path, f.name);
  }

  Future<void> _pickDocument() async {
    final r = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: [
        'doc',
        'docx',
        'xls',
        'xlsx',
        'jpg',
        'jpeg',
        'png',
        'mp4',
        'pdf',
      ],
    );
    if (r != null && r.files.single.path != null)
      _upload(r.files.single.path!, r.files.single.name);
  }

  Future<void> _upload(String path, String name) async {
    final size = await io.File(path).length();
    context.read<JobCubit>().uploadJobFile(
      jobId: widget.job.data?.sId ?? '',
      jobNo: widget.job.data!.jobNo!,
      filePath: path,
      fileName: name,
      fileSize: size,
    );
  }

  void _deleteFile(String filePath) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete File'),
        content: const Text('Are you sure?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              context.read<JobCubit>().deleteJobFile(
                jobId: widget.job.data?.sId ?? '',
                filePath: filePath,
              );
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  // ─── receipt navigation ──────────────────

  job_booking.CreateJobResponse _toResponse() {
    final job = widget.job;
    return job_booking.CreateJobResponse(
      success: job.success ?? true,
      data: job_booking.JobData(
        sId: job.data?.sId,
        jobType: job.data?.jobType,
        model: job.data?.model,
        deviceId: job.data?.deviceId,
        jobContactId: job.data?.jobContactId,
        defectId: job.data?.defectId,
        physicalLocation: job.data?.physicalLocation,
        emailConfirmation: job.data?.emailConfirmation,
        signatureFilePath: job.data?.signatureFilePath,
        printOption: job.data?.printOption,
        printDeviceLabel: job.data?.printDeviceLabel,
        jobNo: job.data?.jobNo,
        jobTrackingNumber: job.data?.jobTrackingNumber,
        salutationHTMLmarkup: job.data?.salutationHTMLmarkup,
        termsAndConditionsHTMLmarkup: job.data?.termsAndConditionsHTMLmarkup,
        userId: job.data?.userId,
        createdAt: job.data?.createdAt,
        updatedAt: job.data?.updatedAt,
        jobStatus: job.data?.jobStatus
            ?.map(
              (js) => job_booking.JobStatus(
                title: js.title ?? '',
                userId: js.userId ?? '',
                colorCode: js.colorCode ?? '',
                userName: js.userName ?? '',
                createAtStatus: js.createAtStatus ?? 0,
                notifications: js.notifications ?? false,
                notes: js.notes ?? '',
              ),
            )
            .toList(),
        contact: job.data?.contact
            ?.map(
              (c) => job_booking.ContactData(
                sId: c.sId,
                type: c.type,
                salutation: c.salutation,
                firstName: c.firstName,
                lastName: c.lastName,
                telephone: c.telephone,
                email: c.email,
                createdAt: c.createdAt,
                updatedAt: c.updatedAt,
              ),
            )
            .toList(),
        defect: job.data?.defect
            ?.map(
              (d) => job_booking.DefectData(
                sId: d.sId,
                defect: d.defect
                    ?.map(
                      (i) => job_booking.DefectItem(
                        value: i.value ?? '',
                        id: i.id ?? '',
                      ),
                    )
                    .toList(),
                description: d.description,
                createdAt: d.createdAt,
                updatedAt: d.updatedAt,
              ),
            )
            .toList(),
        device: job.data?.device
            ?.map(
              (d) => job_booking.DeviceData(
                sId: d.sId,
                brand: d.brand,
                model: d.model,
                imei: d.serialNo,
                condition: d.condition
                    ?.map(
                      (c) => job_booking.ConditionItem(
                        value: c.value ?? '',
                        id: c.id ?? '',
                      ),
                    )
                    .toList(),
                createdAt: d.createdAt,
                updatedAt: d.updatedAt,
              ),
            )
            .toList(),
        receiptFooter: job.data?.receiptFooter == null
            ? null
            : job_booking.ReceiptFooter(
                companyLogo: job.data!.receiptFooter!.companyLogo ?? '',
                companyLogoURL: job.data!.receiptFooter!.companyLogoURL ?? '',
                address: job_booking.CompanyAddress(
                  companyName:
                      job.data!.receiptFooter!.address?.companyName ?? '',
                  street: job.data!.receiptFooter!.address?.street ?? '',
                  num: job.data!.receiptFooter!.address?.num ?? '',
                  zip: job.data!.receiptFooter!.address?.zip ?? '',
                  city: job.data!.receiptFooter!.address?.city ?? '',
                  country: job.data!.receiptFooter!.address?.country ?? '',
                ),
                contact: job_booking.CompanyContact(
                  ceo: job.data!.receiptFooter!.contact?.ceo ?? '',
                  telephone: job.data!.receiptFooter!.contact?.telephone ?? '',
                  email: job.data!.receiptFooter!.contact?.email ?? '',
                  website: job.data!.receiptFooter!.contact?.website ?? '',
                ),
                bank: job_booking.BankDetails(
                  bankName: job.data!.receiptFooter!.bank?.bankName ?? '',
                  iban: job.data!.receiptFooter!.bank?.iban ?? '',
                  bic: job.data!.receiptFooter!.bank?.bic ?? '',
                ),
              ),
        customerDetails: job.data?.customerDetails == null
            ? null
            : job_booking.CustomerDetails(
                customerId: job.data!.customerDetails!.customerId ?? '',
                type: job.data!.customerDetails!.type ?? 'Personal',
                type2: job.data!.customerDetails!.type2 ?? 'personal',
                organization: job.data!.customerDetails!.organization ?? '',
                customerNo: job.data!.customerDetails!.customerNo ?? '',
                email: job.data!.customerDetails!.email ?? '',
                telephone: job.data!.customerDetails!.telephone ?? '',
                telephonePrefix:
                    job.data!.customerDetails!.telephonePrefix ?? '',
                salutation: job.data!.customerDetails!.salutation ?? '',
                firstName: job.data!.customerDetails!.firstName ?? '',
                lastName: job.data!.customerDetails!.lastName ?? '',
                position: job.data!.customerDetails!.position ?? '',
                vatNo: job.data!.customerDetails!.vatNo ?? '',
                reverseCharge:
                    job.data!.customerDetails!.reverseCharge ?? false,
                shippingAddress: job_booking.CustomerAddress(
                  street: '',
                  no: '',
                  zip: '',
                  city: '',
                  state: '',
                  country: '',
                ),
                billingAddress: job_booking.CustomerAddress(
                  street: '',
                  no: '',
                  zip: '',
                  city: '',
                  state: '',
                  country: '',
                ),
              ),
      ),
    );
  }

  // ─── BlocListener wrapper + build ────────

  @override
  Widget build(BuildContext context) {
    return BlocListener<JobCubit, JobStates>(
      listener: (context, state) {
        if (state is AssignUserListSuccess) {
          setState(() {
            _availableUsers = state.users;
            _isLoadingUsers = false;
          });
          _setCurrentAssignee();
        }
        if (state is AssignUserListError)
          setState(() => _isLoadingUsers = false);
        if (state is JobNoteUpdateSuccess) {
          setState(() {
            _internalNotes = state.job.data?.defect?.isNotEmpty == true
                ? state.job.data!.defect!.first.internalNote ?? []
                : [];
          });
          // SnackbarDemo(message: 'Note saved').showCustomSnackbar(context);
        }
      },
      child: _buildScaffold(),
    );
  }

  void _setCurrentAssignee() {
    final assignUser = widget.job.data?.assignUser;
    if (assignUser == null || (assignUser).isEmpty) return;
    final first = assignUser.first;
    String id;
    String name;
    if (first is Map) {
      id = first['_id']?.toString() ?? '';
      name = first['fullName'] ?? first['email'] ?? 'Unknown';
    } else {
      id = first.toString();
      final u = _findUser(id);
      name = u?.fullName ?? u?.email ?? 'Unknown';
    }
    if (id.isNotEmpty)
      setState(() {
        _selectedUserId = id;
        _selectedAssigneeName = name;
      });
  }

  Widget _buildScaffold() {
    final job = widget.job;
    final jobNo = job.data?.jobNo ?? '';

    return BlocListener<JobCubit, JobStates>(
      listener: (context, state) {
        if (state is JobStatusUpdateSuccess || state is JobStatusUpdated) {
          SnackbarDemo(
            message: 'Job status updated successfully',
          ).showCustomSnackbar(context);
        } else if (state is JobNoteUpdateSuccess) {
          SnackbarDemo(
            message: 'Note updated successfully',
          ).showCustomSnackbar(context);
        } else if (state is JobFileUploadSuccess) {
          SnackbarDemo(
            message: 'File uploaded successfully',
          ).showCustomSnackbar(context);
        } else if (state is JobFileDeleteSuccess) {
          SnackbarDemo(
            message: 'File deleted successfully',
          ).showCustomSnackbar(context);
        } else if (state is JobPrioritySuccess) {
          SnackbarDemo(
            message: 'Priority updated successfully',
          ).showCustomSnackbar(context);
        } else if (state is JobError) {
          SnackbarDemo(message: state.message).showCustomSnackbar(context);
        } else if (state is JobActionError) {
          SnackbarDemo(message: state.message).showCustomSnackbar(context);
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.kBg,
        appBar: CupertinoNavigationBar(
          backgroundColor: AppColors.kBg,
          leading: CupertinoButton(
            padding: EdgeInsets.zero,
            onPressed: () => Navigator.of(context).pop(),
            child: Container(
              width: 36.w,
              height: 36.h,
              decoration: BoxDecoration(
                color: const Color.fromARGB(255, 251, 251, 251),
                shape: BoxShape.circle,
              ),
              child: Icon(
                CupertinoIcons.back,
                color: const Color(0xFF3A4A67),
                size: 20.r,
              ),
            ),
          ),
          middle: Text(
            'JOB-ID $jobNo',
            style: TextStyle(
              fontSize: 17.sp,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF1E2D4D),
            ),
          ),
          trailing: CupertinoButton(
            padding: EdgeInsets.zero,
            onPressed: _toggleMoreMenu,
            child: Container(
              width: 36.w,
              height: 36.h,
              decoration: BoxDecoration(
                color: const Color.fromARGB(255, 251, 251, 251),
                shape: BoxShape.circle,
              ),
              child: Icon(
                CupertinoIcons.ellipsis,
                color: const Color(0xFF3A4A67),
                size: 20.r,
              ),
            ),
          ),
        ),
        body: BlocBuilder<JobCubit, JobStates>(
          builder: (context, state) {
            // Get latest files from state
            List<File>? files = job.data?.files;
            if (state is JobFileUploadSuccess) files = state.job.data?.files;
            if (state is JobFileDeleteSuccess) files = state.job.data?.files;

            final isLoading =
                state is JobLoading ||
                state is JobActionLoading ||
                state is JobFileUploading;

            return Stack(
              children: [
                SingleChildScrollView(
                  padding: EdgeInsets.symmetric(vertical: 16.h),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ── 1. Contact & Communication ──────────
                      _sectionCard(
                        child: Column(
                          children: [
                            _infoRow(
                              label: 'Contact',
                              value: _contactName(),
                              bold: true,
                            ),
                            Divider(height: 1, color: Colors.grey.shade200),
                            _arrowRow(
                              leading: Stack(
                                clipBehavior: Clip.none,
                                children: [
                                  Icon(
                                    SolarIconsOutline.dialog2,
                                    color: Colors.black87,
                                    size: 24.sp,
                                  ),
                                  Positioned(
                                    top: -2,
                                    right: -2,
                                    child: Container(
                                      width: 10.w,
                                      height: 10.h,
                                      decoration: const BoxDecoration(
                                        color: Colors.red,
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              label: 'Communication',
                              onTap: () {
                                final c = job.data?.customerDetails;
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => ChatConversationScreen(
                                      conversationId: job.data!.sId!,
                                      recipientEmail: c?.email,
                                      recipientName:
                                          '${c?.firstName ?? ''} ${c?.lastName ?? ''}'
                                              .trim()
                                              .isNotEmpty
                                          ? '${c?.firstName ?? ''} ${c?.lastName ?? ''}'
                                                .trim()
                                          : 'Customer',
                                    ),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ),

                      // ── 2. Job Status ───────────────────────
                      _sectionLabel('JOB STATUS'),
                      _sectionCard(
                        child: Column(
                          children: [
                            _arrowRow(
                              label:
                                  '${_latestStatusTitle()}\n${_latestStatusDate()}',
                              prefixLabel: 'Status',
                              boldValue: true,
                              onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => StatusScreen(jobId: job),
                                ),
                              ),
                            ),
                            Divider(height: 1, color: Colors.grey.shade200),
                            _priorityRow(),
                            Divider(height: 1, color: Colors.grey.shade200),
                            _dueDateRow(),
                            Divider(height: 1, color: Colors.grey.shade200),
                            _assigneeRow(),
                          ],
                        ),
                      ),

                      // ── 3. Job Details ──────────────────────
                      _sectionLabel('JOB DETAILS'),
                      _sectionCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _plainRow(
                              'Physical Location',
                              job.data?.physicalLocation ?? 'Not specified',
                            ),
                            Divider(height: 1, color: Colors.grey.shade200),
                            _plainRow('Defect Type', _defectType()),
                            Divider(height: 1, color: Colors.grey.shade200),
                            _plainRowMulti(
                              'Problem description',
                              _problemDesc(),
                            ),
                          ],
                        ),
                      ),

                      // ── 4. Receipts ─────────────────────────
                      _sectionLabel('RECEIPTS'),
                      _sectionCard(
                        child: Column(
                          children: [
                            _receiptRow(
                              SolarIconsOutline.tagHorizontal,
                              'Job Label',
                              true,
                              () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => JobDeviceLabelScreen(
                                      jobResponse: _toResponse(),
                                      printOption: 'Device Label',
                                      jobNo: job.data?.jobNo,
                                    ),
                                  ),
                                );
                              },
                            ),
                            Divider(height: 1, color: Colors.grey.shade200),
                            _receiptRow(
                              SolarIconsOutline.documentText,
                              'Job receipt',
                              true,
                              () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => ReceiptScreen(job: job),
                                  ),
                                );
                              },
                            ),
                            Divider(height: 1, color: Colors.grey.shade200),
                            _receiptRow(
                              SolarIconsOutline.documentText,
                              'Quote',
                              true,
                              () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        JobThermalReceiptPreviewScreen(
                                          jobResponse: _toResponse(),
                                          printOption: 'Thermal Receipt',
                                        ),
                                  ),
                                );
                              },
                            ),
                            Divider(height: 1, color: Colors.grey.shade200),
                            _receiptRow(
                              SolarIconsOutline.documentText,
                              'Invoice',
                              true,
                              () => debugPrint('Invoice tapped'),
                            ),
                            Divider(height: 1, color: Colors.grey.shade200),
                            _receiptRow(
                              Icons.description_outlined,
                              'Service Report',
                              false,
                              () {},
                            ),
                          ],
                        ),
                      ),

                      // ── 5. Files & Photos ───────────────────
                      _sectionLabel('FILES & PHOTOS'),
                      _sectionCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                CupertinoButton(
                                  padding: EdgeInsets.zero,
                                  onPressed: _showUploadSheet,
                                  child: Text(
                                    'Upload',
                                    style: TextStyle(
                                      color: AppColors.kBlue,
                                      fontSize: 15.sp,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            if (files == null || files.isEmpty)
                              Center(
                                child: Padding(
                                  padding: EdgeInsets.symmetric(vertical: 16.h),
                                  child: Text(
                                    'No files uploaded yet',
                                    style: TextStyle(
                                      color: Colors.grey.shade500,
                                      fontSize: 14.sp,
                                    ),
                                  ),
                                ),
                              )
                            else
                              GridView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                padding: EdgeInsets.only(top: 8.h),
                                gridDelegate:
                                    const SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: 2,
                                      crossAxisSpacing: 12,
                                      mainAxisSpacing: 12,
                                      childAspectRatio: 0.85,
                                    ),
                                itemCount: files.length,
                                itemBuilder: (_, i) => _fileCard(files![i]),
                              ),
                          ],
                        ),
                      ),

                      // ── 6. Notes ────────────────────────────
                      _sectionLabel('NOTES'),
                      _sectionCard(
                        child: BlocBuilder<JobCubit, JobStates>(
                          builder: (_, __) => Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  CupertinoButton(
                                    padding: EdgeInsets.zero,
                                    onPressed: () => _openNoteSheet(),
                                    child: Text(
                                      'Add note',
                                      style: TextStyle(
                                        color: AppColors.kBlue,
                                        fontSize: 15.sp,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              if (_internalNotes.isEmpty)
                                Padding(
                                  padding: EdgeInsets.symmetric(vertical: 12.h),
                                  child: Text(
                                    'No notes yet',
                                    style: TextStyle(
                                      color: Colors.grey.shade500,
                                      fontSize: 14.sp,
                                    ),
                                  ),
                                )
                              else
                                ..._internalNotes.map((n) => _noteItem(n)),
                            ],
                          ),
                        ),
                      ),

                      SizedBox(height: 40.h),
                    ],
                  ),
                ),
                if (isLoading) _loadingOverlay(),

                if (_menuVisible) ...[
                  GestureDetector(
                    onTap: _closeMoreMenu,
                    behavior: HitTestBehavior.translucent,
                    child: Container(
                      width: double.infinity,
                      height: double.infinity,
                      color: Colors.transparent,
                    ),
                  ),
                  _buildMoreMenuOverlay(),
                ],
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _loadingOverlay() {
    return Container(
      width: double.infinity,
      height: double.infinity,
      color: Colors.black.withValues(alpha: 0.15),
      child: Center(
        child: Container(
          padding: EdgeInsets.all(24.r),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16.r),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 10,
                spreadRadius: 2,
              ),
            ],
          ),
          child: CupertinoActivityIndicator(radius: 16.r),
        ),
      ),
    );
  }

  // ─── UI helpers ──────────────────────────

  Widget _sectionLabel(String text) => Padding(
    padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 6.h),
    child: Text(
      text,
      style: GoogleFonts.roboto(
        fontSize: 13.sp,
        fontWeight: FontWeight.w500,
        color: Colors.grey.shade500,
        letterSpacing: 0.5,
      ),
    ),
  );

  Widget _sectionCard({required Widget child}) => Container(
    margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 0),
    decoration: BoxDecoration(
      color: AppColors.kCardBg,
      borderRadius: BorderRadius.circular(12.r),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.05),
          blurRadius: 8,
          offset: const Offset(0, 2),
        ),
      ],
    ),
    child: Padding(padding: EdgeInsets.all(16.r), child: child),
  );

  Widget _infoRow({
    required String label,
    required String value,
    bool bold = false,
  }) => Padding(
    padding: EdgeInsets.symmetric(vertical: 12.h),
    child: Row(
      children: [
        Text(
          label,
          style: GoogleFonts.roboto(
            fontSize: 15.sp,
            color: Colors.grey.shade500,
          ),
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: GoogleFonts.roboto(
              fontSize: 15.sp,
              fontWeight: bold ? FontWeight.w600 : FontWeight.w400,
              color: Colors.black87,
            ),
          ),
        ),
      ],
    ),
  );

  Widget _arrowRow({
    Widget? leading,
    String? prefixLabel,
    required String label,
    bool boldValue = false,
    required VoidCallback onTap,
  }) => InkWell(
    onTap: onTap,
    child: Padding(
      padding: EdgeInsets.symmetric(vertical: 14.h),
      child: Row(
        children: [
          if (leading != null) ...[leading, SizedBox(width: 12.w)],
          if (prefixLabel != null) ...[
            Text(
              prefixLabel,
              style: GoogleFonts.roboto(
                fontSize: 15.sp,
                color: Colors.grey.shade500,
              ),
            ),
            SizedBox(width: 12.w),
          ],
          Expanded(
            child: Text(
              label,
              textAlign: prefixLabel != null ? TextAlign.right : TextAlign.left,
              style: GoogleFonts.roboto(
                fontSize: 15.sp,
                fontWeight: boldValue ? FontWeight.w600 : FontWeight.w400,
                color: Colors.black87,
              ),
            ),
          ),
          SizedBox(width: 8.w),
          Icon(
            Icons.arrow_forward_ios,
            size: 14.sp,
            color: Colors.grey.shade400,
          ),
        ],
      ),
    ),
  );

  Widget _plainRow(String label, String value) => Padding(
    padding: EdgeInsets.symmetric(vertical: 12.h),
    child: Row(
      children: [
        Text(
          label,
          style: GoogleFonts.roboto(
            fontSize: 15.sp,
            color: Colors.grey.shade500,
          ),
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: GoogleFonts.roboto(
              fontSize: 15.sp,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
          ),
        ),
      ],
    ),
  );

  Widget _plainRowMulti(String label, String value) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Padding(
        padding: EdgeInsets.only(top: 12.h, bottom: 4.h),
        child: Text(
          label,
          style: GoogleFonts.roboto(
            fontSize: 15.sp,
            color: Colors.grey.shade500,
          ),
        ),
      ),
      Text(
        value,
        style: GoogleFonts.roboto(
          fontSize: 15.sp,
          color: Colors.black87,
          height: 1.5,
        ),
      ),
      SizedBox(height: 12.h),
    ],
  );

  Widget _priorityRow() => Padding(
    padding: EdgeInsets.symmetric(vertical: 14.h),
    child: Row(
      children: [
        Text(
          'Priority',
          style: GoogleFonts.roboto(
            fontSize: 15.sp,
            color: Colors.grey.shade500,
          ),
        ),
        const Spacer(),
        Icon(Icons.flag, color: _priorityColor(), size: 16.sp),
        SizedBox(width: 4.w),
        Text(
          _priorityLabel(),
          style: GoogleFonts.roboto(
            fontSize: 15.sp,
            fontWeight: FontWeight.w600,
            color: _priorityColor(),
          ),
        ),
      ],
    ),
  );

  Widget _dueDateRow() => Padding(
    padding: EdgeInsets.symmetric(vertical: 14.h),
    child: Row(
      children: [
        Text(
          'Due date',
          style: GoogleFonts.roboto(
            fontSize: 15.sp,
            color: Colors.grey.shade500,
          ),
        ),
        const Spacer(),
        Text(
          _selectedDueDate,
          style: GoogleFonts.roboto(
            fontSize: 15.sp,
            fontWeight: FontWeight.w500,
            color: AppColors.kBlue,
          ),
        ),
      ],
    ),
  );

  Widget _assigneeRow() {
    final initials = _selectedUserId != null
        ? _initials(_selectedAssigneeName)
        : 'U';
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 10.h),
      child: Row(
        children: [
          Text(
            'Assignee',
            style: GoogleFonts.roboto(
              fontSize: 15.sp,
              color: Colors.grey.shade500,
            ),
          ),
          const Spacer(),
          if (_isLoadingUsers)
            SizedBox(
              width: 18.w,
              height: 18.h,
              child: const CircularProgressIndicator(strokeWidth: 2),
            )
          else ...[
            CircleAvatar(
              radius: 14.r,
              backgroundColor: Colors.green,
              child: Text(
                initials,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 11.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            SizedBox(width: 8.w),
            Text(
              _selectedAssigneeName,
              style: GoogleFonts.roboto(
                fontSize: 15.sp,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _receiptRow(
    IconData icon,
    String title,
    bool enabled,
    VoidCallback onTap,
  ) => InkWell(
    onTap: enabled ? onTap : null,
    child: Padding(
      padding: EdgeInsets.symmetric(vertical: 14.h),
      child: Row(
        children: [
          Container(
            width: 28.w,
            height: 28.h,
            decoration: BoxDecoration(
              color: enabled
                  ? AppColors.kBlue.withValues(alpha: 0.1)
                  : Colors.grey.shade200,
              borderRadius: BorderRadius.circular(6.r),
            ),
            child: Icon(
              icon,
              color: enabled ? AppColors.kBlue : Colors.grey,
              size: 18.sp,
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Text(
              title,
              style: GoogleFonts.roboto(
                fontSize: 15.sp,
                color: enabled ? Colors.black87 : Colors.grey.shade400,
              ),
            ),
          ),
          Icon(
            Icons.arrow_forward_ios,
            size: 14.sp,
            color: enabled ? Colors.grey.shade400 : Colors.grey.shade300,
          ),
        ],
      ),
    ),
  );

  Widget _fileCard(File file) {
    final name = file.fileName ?? 'Unknown';
    final ext = name.split('.').last.toLowerCase();
    final isImage =
        ['jpg', 'jpeg', 'png', 'gif'].contains(ext) &&
        (file.imageUrl?.isNotEmpty == true);
    return GestureDetector(
      onTap: () {
        if (isImage) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => FullscreenImageViewer(imageUrl: file.imageUrl!),
            ),
          );
        }
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: const Color(0xFFE5E5EA)),
        ),
        child: Column(
          children: [
            Expanded(
              child: Stack(
                children: [
                  Container(
                    width: double.infinity,
                    decoration: const BoxDecoration(
                      color: Color(0xFFF5F5F5),
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(12),
                      ),
                    ),
                    child: isImage
                        ? ClipRRect(
                            borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(12),
                            ),
                            child: Image.network(
                              file.imageUrl!,
                              fit: BoxFit.contain,
                              errorBuilder: (_, _, _) => const Icon(
                                Icons.broken_image,
                                size: 40,
                                color: Colors.grey,
                              ),
                            ),
                          )
                        : Center(
                            child: Icon(
                              Icons.insert_drive_file,
                              size: 48.sp,
                              color: Colors.grey.shade400,
                            ),
                          ),
                  ),
                  Positioned(
                    top: 6,
                    right: 6,
                    child: GestureDetector(
                      onTap: () => _deleteFile(file.file ?? ''),
                      child: Container(
                        width: 28.w,
                        height: 28.h,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(6.r),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.1),
                              blurRadius: 4,
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.delete_outline,
                          size: 16,
                          color: Color(0xFFFF3B30),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.all(8.r),
              child: Text(
                name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w500),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _noteItem(InternalNote note) {
    final time = _fmtNoteTime(note.createdAt?.toString() ?? '');
    return Padding(
      padding: EdgeInsets.only(bottom: 16.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 14.r,
                backgroundColor: const Color(0xFFF0D48C),
                child: Text(
                  _initials(note.userName ?? 'U'),
                  style: TextStyle(
                    fontSize: 11.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ),
              SizedBox(width: 8.w),
              Text(
                note.userName ?? 'Unknown',
                style: GoogleFonts.roboto(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          SizedBox(height: 8.h),
          Text(
            note.text ?? '',
            style: GoogleFonts.roboto(
              fontSize: 14.sp,
              color: Colors.black87,
              height: 1.4,
            ),
          ),
          SizedBox(height: 6.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                time,
                style: GoogleFonts.roboto(
                  fontSize: 12.sp,
                  color: Colors.grey.shade500,
                ),
              ),
              Row(
                children: [
                  InkWell(
                    onTap: () => _openNoteSheet(note),
                    child: Row(
                      children: [
                        Icon(
                          FontAwesomeIcons.solidPenToSquare,
                          size: 14.r,
                          color: AppColors.kBlue,
                        ),
                        SizedBox(width: 4.w),
                        Text(
                          'Edit',
                          style: GoogleFonts.roboto(
                            color: AppColors.kBlue,
                            fontSize: 13.sp,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: 16.w),
                  InkWell(
                    onTap: () => _deleteNote(note),
                    child: Row(
                      children: [
                        Icon(Icons.delete, size: 14.r, color: Colors.red),
                        SizedBox(width: 4.w),
                        Text(
                          'Delete',
                          style: GoogleFonts.roboto(
                            color: Colors.red,
                            fontSize: 13.sp,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: 8.h),
          Divider(height: 1, color: Colors.grey.shade200),
        ],
      ),
    );
  }

  String _fmtNoteTime(String raw) {
    try {
      if (raw.contains('T')) {
        final dt = DateTime.parse(raw);
        return '${dt.day.toString().padLeft(2, '0')}.${dt.month.toString().padLeft(2, '0')}.${dt.year} | ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
      }
      final ts = int.tryParse(raw);
      if (ts != null) {
        final dt = DateTime.fromMillisecondsSinceEpoch(ts);
        return '${dt.day.toString().padLeft(2, '0')}.${dt.month.toString().padLeft(2, '0')}.${dt.year} | ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
      }
    } catch (_) {}
    return raw;
  }
}

// ─────────────────────────────────────────────
// _NoteSheet – inline note add/edit bottom sheet
// ─────────────────────────────────────────────
class _NoteSheet extends StatefulWidget {
  final SingleJobModel job;
  final InternalNote? note;
  final VoidCallback onSaved;
  const _NoteSheet({required this.job, this.note, required this.onSaved});

  @override
  State<_NoteSheet> createState() => _NoteSheetState();
}

class _NoteSheetState extends State<_NoteSheet> {
  late TextEditingController _ctrl;
  final _focus = FocusNode();
  bool _loading = false;
  bool get _isEditing => widget.note != null;

  @override
  void initState() {
    super.initState();
    _ctrl = TextEditingController(text: widget.note?.text ?? '');
    WidgetsBinding.instance.addPostFrameCallback((_) => _focus.requestFocus());
  }

  @override
  void dispose() {
    _ctrl.dispose();
    _focus.dispose();
    super.dispose();
  }

  void _save() {
    final text = _ctrl.text.trim();
    if (text.isEmpty) {
      SnackbarDemo(message: 'Note cannot be empty').showCustomSnackbar(context);
      return;
    }
    setState(() => _loading = true);
    final s = GetStorage();
    final uid = s.read('userId');
    final uname = s.read('fullName');
    if (uid == null || uname == null) {
      setState(() => _loading = false);
      return;
    }
    final cubit = context.read<JobCubit>();
    final jid = widget.job.data?.sId ?? '';
    final fut = _isEditing
        ? cubit.updateJobNote(
            jobId: jid,
            noteId: widget.note?.id ?? '',
            noteText: text,
            userId: uid,
            userName: uname,
          )
        : cubit.addJobNote(
            jobId: jid,
            noteText: text,
            userId: uid,
            userName: uname,
          );
    fut
        .then((_) {
          setState(() => _loading = false);
          widget.onSaved();
          Navigator.pop(context, true);
        })
        .catchError((e) {
          setState(() => _loading = false);
          SnackbarDemo(message: 'Failed: $e').showCustomSnackbar(context);
        });
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFFF0D48C),
      child: SafeArea(
        top: false,
        child: Container(
          height: MediaQuery.of(context).size.height * 0.9,
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Column(
            children: [
              Padding(
                padding: EdgeInsets.symmetric(vertical: 8.h),
                child: Container(
                  width: 40.w,
                  height: 5.h,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade400,
                    borderRadius: BorderRadius.circular(2.5.r),
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(16.r, 8.r, 16.r, 16.r),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Text(
                      _isEditing ? 'Edit note' : 'Add a note',
                      style: GoogleFonts.roboto(
                        fontSize: 20.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: IconButton(
                        icon: Icon(
                          Icons.close,
                          size: 20.r,
                          color: Colors.black87,
                        ),
                        style: IconButton.styleFrom(
                          backgroundColor: Colors.grey.shade300,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.r),
                          ),
                          padding: EdgeInsets.all(8.r),
                        ),
                        onPressed: _loading
                            ? null
                            : () => Navigator.pop(context),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: AbsorbPointer(
                  absorbing: _loading,
                  child: Opacity(
                    opacity: _loading ? 0.6 : 1.0,
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16.r),
                      child: TextField(
                        controller: _ctrl,
                        focusNode: _focus,
                        maxLines: null,
                        expands: true,
                        style: GoogleFonts.roboto(fontSize: 16.sp, height: 1.5),
                        decoration: InputDecoration(
                          hintText: 'Write a note...',
                          border: InputBorder.none,
                          hintStyle: GoogleFonts.roboto(
                            fontSize: 16.sp,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 16.h),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _loading ? null : _save,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _loading ? Colors.grey : AppColors.kBlue,
                      padding: EdgeInsets.symmetric(vertical: 16.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                    ),
                    child: _loading
                        ? SizedBox(
                            width: 20.w,
                            height: 20.h,
                            child: const CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
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

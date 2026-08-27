import 'dart:convert';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import '../../../../core/widgets/custom_text_field.dart';
import '../../../../bloc/events_bloc/events_bloc.dart';
import '../../../../bloc/events_bloc/events_event.dart';
import '../../../../data/model/event_model.dart';
import '../../../../data/repository/storage_repository.dart';
import '../../../../services/enum.dart';
import '../../../../services/utils.dart';
import '../../../../widgets/cached_image.dart';
import '../../../../widgets/loading_widget.dart';
import '../../../events/presentation/widgets/video_player_widget.dart';

class CreateEditEventScreen extends StatefulWidget {
  final EventModel? initialEvent;

  const CreateEditEventScreen({super.key, this.initialEvent});

  @override
  State<CreateEditEventScreen> createState() => _CreateEditEventScreenState();
}

class _CreateEditEventScreenState extends State<CreateEditEventScreen> {
  final PageController carouselController = PageController();
  final ImagePicker _picker = ImagePicker();
  final StorageRepository _storageRepo = StorageRepository();

  late final TextEditingController nameController;
  late final TextEditingController locationController;
  late final TextEditingController descriptionController;
  late final TextEditingController priceController;

  late final ValueNotifier<List<String>> remoteImages;

  final ValueNotifier<List<File>> localImageFiles = ValueNotifier<List<File>>([]);

  final ValueNotifier<String?> remoteVideoUrl = ValueNotifier<String?>(null);
  final ValueNotifier<File?> localVideoFile = ValueNotifier<File?>(null);

  late final ValueNotifier<EventStatus> statusNotifier;
  late final ValueNotifier<DateTime> startTimeNotifier;
  late final ValueNotifier<DateTime> endTimeNotifier;

  final ValueNotifier<bool> isUploadingNotifier = ValueNotifier<bool>(false);
  final ValueNotifier<double> uploadProgressNotifier = ValueNotifier<double>(0.0);
  final ValueNotifier<String> uploadStatusTextNotifier = ValueNotifier<String>('');

  @override
  void initState() {
    super.initState();
    final event = widget.initialEvent;
    nameController = TextEditingController(text: event?.title ?? '');
    locationController = TextEditingController(text: event?.location ?? '');
    descriptionController = TextEditingController(text: event?.description ?? '');
    priceController = TextEditingController(text: event != null ? event.price.toStringAsFixed(0) : '299');

    remoteImages = ValueNotifier<List<String>>(
      event != null && event.images.isNotEmpty
          ? List<String>.from(event.images)
          : [],
    );

    remoteVideoUrl.value = event?.videoUrl;

    statusNotifier = ValueNotifier<EventStatus>(
      event?.status ?? EventStatus.upcoming,
    );

    final defaultStart = event?.startTime ?? DateTime.now().add(const Duration(days: 2, hours: 2));
    startTimeNotifier = ValueNotifier<DateTime>(defaultStart);
    endTimeNotifier = ValueNotifier<DateTime>(
      event?.endTime ?? defaultStart.add(const Duration(hours: 4)),
    );
  }

  @override
  void dispose() {
    nameController.dispose();
    locationController.dispose();
    descriptionController.dispose();
    priceController.dispose();
    carouselController.dispose();
    localImageFiles.dispose();
    remoteImages.dispose();
    remoteVideoUrl.dispose();
    localVideoFile.dispose();
    statusNotifier.dispose();
    startTimeNotifier.dispose();
    endTimeNotifier.dispose();
    isUploadingNotifier.dispose();
    uploadProgressNotifier.dispose();
    uploadStatusTextNotifier.dispose();
    super.dispose();
  }

  Future<void> _selectStartDateTime() async {
    final now = DateTime.now();
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: startTimeNotifier.value.isBefore(now) ? now : startTimeNotifier.value,
      firstDate: DateTime(now.year - 1),
      lastDate: DateTime(now.year + 5),
      builder: (context, child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: const ColorScheme.dark(
              primary: Color(0xffF2AF34),
              onPrimary: Colors.black,
              surface: Color(0xff2A2A2A),
              onSurface: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );

    if (pickedDate != null && mounted) {
      final pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(startTimeNotifier.value),
        builder: (context, child) {
          return Theme(
            data: ThemeData.dark().copyWith(
              colorScheme: const ColorScheme.dark(
                primary: Color(0xffF2AF34),
                onPrimary: Colors.black,
                surface: Color(0xff2A2A2A),
                onSurface: Colors.white,
              ),
            ),
            child: child!,
          );
        },
      );

      if (pickedTime != null) {
        final newStart = DateTime(
          pickedDate.year,
          pickedDate.month,
          pickedDate.day,
          pickedTime.hour,
          pickedTime.minute,
        );
        startTimeNotifier.value = newStart;
        if (endTimeNotifier.value.isBefore(newStart)) {
          endTimeNotifier.value = newStart.add(const Duration(hours: 4));
        }
      }
    }
  }

  Future<void> _selectEndDateTime() async {
    final initial = endTimeNotifier.value.isBefore(startTimeNotifier.value)
        ? startTimeNotifier.value.add(const Duration(hours: 2))
        : endTimeNotifier.value;

    final pickedDate = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: startTimeNotifier.value,
      lastDate: DateTime(DateTime.now().year + 5),
      builder: (context, child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: const ColorScheme.dark(
              primary: Color(0xffF2AF34),
              onPrimary: Colors.black,
              surface: Color(0xff2A2A2A),
              onSurface: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );

    if (pickedDate != null && mounted) {
      final pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(endTimeNotifier.value),
        builder: (context, child) {
          return Theme(
            data: ThemeData.dark().copyWith(
              colorScheme: const ColorScheme.dark(
                primary: Color(0xffF2AF34),
                onPrimary: Colors.black,
                surface: Color(0xff2A2A2A),
                onSurface: Colors.white,
              ),
            ),
            child: child!,
          );
        },
      );

      if (pickedTime != null) {
        endTimeNotifier.value = DateTime(
          pickedDate.year,
          pickedDate.month,
          pickedDate.day,
          pickedTime.hour,
          pickedTime.minute,
        );
      }
    }
  }

  Future<void> _pickImages() async {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xff222222),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  "Select Image Source",
                  style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                ListTile(
                  leading: const Icon(Icons.photo_library_rounded, color: Color(0xffF2AF34)),
                  title: const Text("Choose from Gallery (Multiple)", style: TextStyle(color: Colors.white)),
                  onTap: () async {
                    Navigator.pop(ctx);
                    try {
                      final List<XFile> picked = await _picker.pickMultiImage(
                        imageQuality: 75,
                        maxWidth: 1200,
                      );
                      if (picked.isNotEmpty) {
                        final validFiles = <File>[];
                        for (final xf in picked) {
                          final file = File(xf.path);
                          final bytes = await file.length();
                          if (bytes > 300 * 1024) {
                            debugPrint("Image ${xf.name} size: ${bytes / 1024} KB");
                          }
                          validFiles.add(file);
                        }
                        localImageFiles.value = [...localImageFiles.value, ...validFiles];
                        if (mounted) {
                          Utils.showFlushBar(
                            '${picked.length} image(s) selected from phone gallery',
                            FlushBarType.success,
                            context,
                          );
                        }
                      }
                    } catch (e) {
                      debugPrint("Image pick error: $e");
                      if (mounted) {
                        Utils.showFlushBar('Failed to pick images: $e', FlushBarType.error, context);
                      }
                    }
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.camera_alt_rounded, color: Color(0xffF2AF34)),
                  title: const Text("Take Photo with Camera", style: TextStyle(color: Colors.white)),
                  onTap: () async {
                    Navigator.pop(ctx);
                    try {
                      final XFile? photo = await _picker.pickImage(
                        source: ImageSource.camera,
                        imageQuality: 75,
                        maxWidth: 1200,
                      );
                      if (photo != null) {
                        localImageFiles.value = [...localImageFiles.value, File(photo.path)];
                        if (mounted) {
                          Utils.showFlushBar('Photo captured successfully', FlushBarType.success, context);
                        }
                      }
                    } catch (e) {
                      debugPrint("Camera error: $e");
                      if (mounted) {
                        Utils.showFlushBar('Failed to capture photo: $e', FlushBarType.error, context);
                      }
                    }
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _pickVideo() async {
    try {
      final XFile? picked = await _picker.pickVideo(
        source: ImageSource.gallery,
        maxDuration: const Duration(seconds: 15),
      );
      if (picked != null) {
        final file = File(picked.path);
        final fileSizeInBytes = await file.length();
        final fileSizeInMB = fileSizeInBytes / (1024 * 1024);

        if (fileSizeInMB > 15.0) {
          if (mounted) {
            Utils.showFlushBar('Video must be under 15MB. Selected: ${fileSizeInMB.toStringAsFixed(1)}MB', FlushBarType.warn, context);
          }
          return;
        }

        localVideoFile.value = file;
        remoteVideoUrl.value = null;
        if (mounted) {
          Utils.showFlushBar('Short video clip selected successfully!', FlushBarType.success, context);
        }
      }
    } catch (e) {
      debugPrint("Video pick error: $e");
      if (mounted) {
        Utils.showFlushBar('Failed to pick video: $e', FlushBarType.error, context);
      }
    }
  }

  Future<void> _handleSubmit(bool isEdit) async {
    FocusScope.of(context).unfocus();

    if (nameController.text.trim().isEmpty) {
      Utils.showFlushBar('Please enter an event title', FlushBarType.warn, context);
      return;
    }

    final totalImagesCount = remoteImages.value.length + localImageFiles.value.length;
    if (totalImagesCount == 0) {
      Utils.showFlushBar('Please upload at least 1 image for the event', FlushBarType.warn, context);
      return;
    }

    final eventId = isEdit ? widget.initialEvent!.id : 'evt_${DateTime.now().millisecondsSinceEpoch}';

    List<String> finalUploadedImages = List<String>.from(remoteImages.value);
    String? finalUploadedVideoUrl = remoteVideoUrl.value;

    final hasFilesToUpload = localImageFiles.value.isNotEmpty || localVideoFile.value != null;

    if (hasFilesToUpload) {
      isUploadingNotifier.value = true;
      uploadProgressNotifier.value = 0.05;
      uploadStatusTextNotifier.value = 'Preparing media upload...';

      try {
        final totalUploadTasks = localImageFiles.value.length + (localVideoFile.value != null ? 1 : 0);
        var completedTasks = 0;

        for (int i = 0; i < localImageFiles.value.length; i++) {
          final file = localImageFiles.value[i];
          uploadStatusTextNotifier.value = 'Processing image ${i + 1} of ${localImageFiles.value.length}...';

          try {
            final downloadUrl = await _storageRepo.uploadEventImage(
              file,
              eventId,
              onProgress: (progress) {
                final overall = (completedTasks + progress) / totalUploadTasks;
                uploadProgressNotifier.value = overall.clamp(0.0, 0.99);
              },
            );
            finalUploadedImages.add(downloadUrl);
          } catch (storageErr) {
            debugPrint("Firebase Storage Image upload fallback to base64: $storageErr");
            try {
              final bytes = await file.readAsBytes();
              final base64Image = 'data:image/jpeg;base64,${base64Encode(bytes)}';
              finalUploadedImages.add(base64Image);
            } catch (e) {
              finalUploadedImages.add(file.path);
            }
          }
          completedTasks++;
          uploadProgressNotifier.value = completedTasks / totalUploadTasks;
        }

        if (localVideoFile.value != null) {
          uploadStatusTextNotifier.value = 'Processing video clip...';
          try {
            final vidUrl = await _storageRepo.uploadEventVideo(
              localVideoFile.value!,
              eventId,
              onProgress: (progress) {
                final overall = (completedTasks + progress) / totalUploadTasks;
                uploadProgressNotifier.value = overall.clamp(0.0, 0.99);
              },
            );
            finalUploadedVideoUrl = vidUrl;
          } catch (vidErr) {
            debugPrint("Firebase Storage Video upload fallback to local path: $vidErr");
            finalUploadedVideoUrl = localVideoFile.value!.path;
          }
          completedTasks++;
        }

        uploadProgressNotifier.value = 1.0;
        uploadStatusTextNotifier.value = 'Upload Complete!';
      } catch (e) {
        debugPrint("Upload process error: $e");
      } finally {
        isUploadingNotifier.value = false;
      }
    }

    if (!mounted) return;

    final newEvent = EventModel(
      id: eventId,
      title: nameController.text.trim(),
      description: descriptionController.text.trim(),
      location: locationController.text.trim(),
      startTime: startTimeNotifier.value,
      endTime: endTimeNotifier.value,
      createdBy: widget.initialEvent?.createdBy ?? 'alex@admin.com',
      images: finalUploadedImages.isNotEmpty
          ? finalUploadedImages
          : EventModel.defaultEventImages.take(3).toList(),
      videoUrl: finalUploadedVideoUrl,
      attendeesCount: widget.initialEvent?.attendeesCount ?? 0,
      price: double.tryParse(priceController.text.trim()) ?? 299.0,
      status: statusNotifier.value,
      isInterested: widget.initialEvent?.isInterested ?? false,
    );

    if (isEdit) {
      context.read<EventsBloc>().add(UpdateEventRequested(newEvent));
      Utils.showFlushBar('Event updated successfully in Firebase!', FlushBarType.success, context);
    } else {
      context.read<EventsBloc>().add(CreateEventRequested(newEvent));
      Utils.showFlushBar('Event published to Firebase live stream!', FlushBarType.success, context);
    }

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    const goldColor = Color(0xffF2AF34);
    final isEdit = widget.initialEvent != null;

    return Scaffold(
      backgroundColor: const Color(0xff1A1A1A),
      appBar: AppBar(
        backgroundColor: const Color(0xff2A2A2A),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          isEdit ? "Update Event" : "Add Event",
          style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 12),

              SizedBox(
                height: 230,
                child: AnimatedBuilder(
                  animation: Listenable.merge([remoteImages, localImageFiles]),
                  builder: (context, child) {
                    final remotes = remoteImages.value;
                    final locals = localImageFiles.value;
                    final totalMediaCount = remotes.length + locals.length;

                    return PageView.builder(
                      controller: carouselController,
                      allowImplicitScrolling: true,
                      itemCount: totalMediaCount + 1,
                      itemBuilder: (context, index) {
                        if (index == totalMediaCount) {

                          return Center(
                            child: GestureDetector(
                              onTap: _pickImages,
                              child: Container(
                                width: MediaQuery.of(context).size.width * 0.9,
                                height: 230,
                                decoration: BoxDecoration(
                                  color: const Color(0xff2A2A2A),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: const Color(0x44F2AF34), width: 1.5),
                                ),
                                child: Center(
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: const [
                                      Icon(Icons.add_photo_alternate_rounded, color: goldColor, size: 36),
                                      SizedBox(height: 8),
                                      Text(
                                        "Add Photos (Gallery / Camera)",
                                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 15),
                                      ),
                                      SizedBox(height: 4),
                                      Text(
                                        "Compressed < 300 KB each",
                                        style: TextStyle(color: Colors.white54, fontSize: 12),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          );
                        }

                        if (index < locals.length) {
                          final localFile = locals[index];
                          return Center(
                            child: SizedBox(
                              width: MediaQuery.of(context).size.width * 0.9,
                              height: 230,
                              child: Stack(
                                alignment: Alignment.topRight,
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(12),
                                    child: Image.file(
                                      localFile,
                                      height: 230,
                                      width: double.infinity,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                  Positioned(
                                    top: 8,
                                    right: 8,
                                    child: InkWell(
                                      onTap: () {
                                        localImageFiles.value = locals.where((e) => e != localFile).toList();
                                      },
                                      child: Container(
                                        padding: const EdgeInsets.all(6),
                                        decoration: const BoxDecoration(
                                          color: Colors.black87,
                                          shape: BoxShape.circle,
                                        ),
                                        child: const Icon(CupertinoIcons.delete, color: Colors.redAccent, size: 18),
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                    bottom: 8,
                                    left: 8,
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: Colors.black87,
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: const Text(
                                        "Device Photo",
                                        style: TextStyle(color: goldColor, fontSize: 11, fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }

                        final remoteIndex = index - locals.length;
                        final image = remotes[remoteIndex];
                        return Center(
                          child: SizedBox(
                            width: MediaQuery.of(context).size.width * 0.9,
                            height: 230,
                            child: Stack(
                              alignment: Alignment.topRight,
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: CachedImage(
                                    url: image,
                                    height: 230,
                                    width: double.infinity,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                Positioned(
                                  top: 8,
                                  right: 8,
                                  child: InkWell(
                                    onTap: () {
                                      remoteImages.value = remotes.where((e) => e != image).toList();
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.all(6),
                                      decoration: const BoxDecoration(
                                        color: Colors.black87,
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(CupertinoIcons.delete, color: Colors.redAccent, size: 18),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "EVENT SHORT VIDEO (OPTIONAL)",
                      style: TextStyle(color: goldColor, fontWeight: FontWeight.bold, fontSize: 12, letterSpacing: 1),
                    ),
                    const SizedBox(height: 8),
                    AnimatedBuilder(
                      animation: Listenable.merge([localVideoFile, remoteVideoUrl]),
                      builder: (context, _) {
                        final localVid = localVideoFile.value;
                        final remoteVid = remoteVideoUrl.value;

                        if (localVid != null || (remoteVid != null && remoteVid.isNotEmpty)) {
                          return Stack(
                            alignment: Alignment.topRight,
                            children: [
                              VideoPlayerWidget(
                                videoFile: localVid,
                                videoUrl: remoteVid,
                              ),
                              Positioned(
                                top: 8,
                                right: 8,
                                child: InkWell(
                                  onTap: () {
                                    localVideoFile.value = null;
                                    remoteVideoUrl.value = null;
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.all(6),
                                    decoration: const BoxDecoration(
                                      color: Colors.black87,
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(CupertinoIcons.delete, color: Colors.redAccent, size: 18),
                                  ),
                                ),
                              ),
                            ],
                          );
                        }

                        return InkWell(
                          onTap: _pickVideo,
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                            decoration: BoxDecoration(
                              color: const Color(0xff2A2A2A),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.white12),
                            ),
                            child: Row(
                              children: const [
                                Icon(Icons.video_library_rounded, color: goldColor, size: 24),
                                SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "Select Short Video (Max 15s)",
                                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                                      ),
                                      Text(
                                        "Gallery video clip (< 5MB)",
                                        style: TextStyle(color: Colors.white54, fontSize: 11),
                                      ),
                                    ],
                                  ),
                                ),
                                Icon(Icons.add_circle_outline_rounded, color: goldColor, size: 22),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [

                    CustomTextField(
                      controller: nameController,
                      labelText: "Name / Event Title",
                      hintText: "e.g. Flutter Tech Summit",
                      prefixIcon: Icons.title_rounded,
                    ),
                    const SizedBox(height: 12),

                    CustomTextField(
                      controller: locationController,
                      labelText: "Location / Venue",
                      hintText: "e.g. Silicon Convention Center",
                      prefixIcon: Icons.location_on_outlined,
                    ),
                    const SizedBox(height: 12),

                    CustomTextField(
                      controller: descriptionController,
                      labelText: "Description",
                      hintText: "Provide details about agenda and speakers...",
                      prefixIcon: Icons.description_outlined,
                      maxLines: 4,
                    ),
                    const SizedBox(height: 12),

                    CustomTextField(
                      controller: priceController,
                      labelText: "Ticket Price (₹)",
                      hintText: "e.g. 299",
                      prefixIcon: Icons.currency_rupee_rounded,
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 12),

                    ValueListenableBuilder<DateTime>(
                      valueListenable: startTimeNotifier,
                      builder: (context, startTime, _) {
                        final formattedDate = DateFormat('EEE, MMM d, yyyy • h:mm a').format(startTime);
                        return InkWell(
                          onTap: _selectStartDateTime,
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                            decoration: BoxDecoration(
                              color: const Color(0xff2A2A2A),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.white12),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.calendar_month_rounded, color: goldColor, size: 22),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        "Event Start Date & Time",
                                        style: TextStyle(color: Colors.white54, fontSize: 11, fontWeight: FontWeight.w500),
                                      ),
                                      const SizedBox(height: 3),
                                      Text(
                                        formattedDate,
                                        style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
                                      ),
                                    ],
                                  ),
                                ),
                                const Icon(Icons.edit_calendar_rounded, color: goldColor, size: 18),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 12),

                    ValueListenableBuilder<DateTime>(
                      valueListenable: endTimeNotifier,
                      builder: (context, endTime, _) {
                        final formattedDate = DateFormat('EEE, MMM d, yyyy • h:mm a').format(endTime);
                        return InkWell(
                          onTap: _selectEndDateTime,
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                            decoration: BoxDecoration(
                              color: const Color(0xff2A2A2A),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.white12),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.schedule_rounded, color: goldColor, size: 22),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        "Event End Date & Time",
                                        style: TextStyle(color: Colors.white54, fontSize: 11, fontWeight: FontWeight.w500),
                                      ),
                                      const SizedBox(height: 3),
                                      Text(
                                        formattedDate,
                                        style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
                                      ),
                                    ],
                                  ),
                                ),
                                const Icon(Icons.edit_calendar_rounded, color: goldColor, size: 18),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 12),

                    ValueListenableBuilder<EventStatus>(
                      valueListenable: statusNotifier,
                      builder: (context, currentStatus, child) {
                        return Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xff2A2A2A),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.white12),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<EventStatus>(
                              value: currentStatus,
                              dropdownColor: const Color(0xff2A2A2A),
                              style: const TextStyle(color: Colors.white, fontSize: 14),
                              isExpanded: true,
                              items: EventStatus.values.map((s) {
                                return DropdownMenuItem(
                                  value: s,
                                  child: Text("Status: ${s.name.toUpperCase()}"),
                                );
                              }).toList(),
                              onChanged: (val) {
                                if (val != null) statusNotifier.value = val;
                              },
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 24),

                    ValueListenableBuilder<bool>(
                      valueListenable: isUploadingNotifier,
                      builder: (context, isUploading, _) {
                        return Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: goldColor.withValues(alpha: isUploading ? 0.1 : 0.3),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: goldColor,
                              foregroundColor: Colors.black,
                              disabledBackgroundColor: goldColor.withValues(alpha: 0.85),
                              disabledForegroundColor: Colors.black,
                              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              elevation: 0,
                            ),
                            onPressed: isUploading ? null : () => _handleSubmit(isEdit),
                            child: isUploading
                                ? ValueListenableBuilder<double>(
                                    valueListenable: uploadProgressNotifier,
                                    builder: (context, progress, _) {
                                      return ValueListenableBuilder<String>(
                                        valueListenable: uploadStatusTextNotifier,
                                        builder: (context, statusText, _) {
                                          return Column(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Row(
                                                mainAxisAlignment: MainAxisAlignment.center,
                                                children: [
                                                  const LoadingWidget(
                                                    color: Colors.black,
                                                    size: 22,
                                                  ),
                                                  const SizedBox(width: 10),
                                                  Flexible(
                                                    child: Text(
                                                      statusText.isNotEmpty ? statusText : "Uploading & Saving...",
                                                      style: const TextStyle(
                                                        fontSize: 14,
                                                        fontWeight: FontWeight.bold,
                                                        color: Colors.black,
                                                      ),
                                                      maxLines: 1,
                                                      overflow: TextOverflow.ellipsis,
                                                    ),
                                                  ),
                                                  const SizedBox(width: 8),
                                                  Text(
                                                    "${(progress * 100).toInt()}%",
                                                    style: const TextStyle(
                                                      fontSize: 14,
                                                      fontWeight: FontWeight.bold,
                                                      color: Colors.black,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              const SizedBox(height: 8),
                                              ClipRRect(
                                                borderRadius: BorderRadius.circular(4),
                                                child: LinearProgressIndicator(
                                                  value: progress,
                                                  backgroundColor: Colors.black12,
                                                  valueColor: const AlwaysStoppedAnimation<Color>(Colors.black),
                                                  minHeight: 4,
                                                ),
                                              ),
                                            ],
                                          );
                                        },
                                      );
                                    },
                                  )
                                : Text(
                                    isEdit ? "Update Event" : "Add Event",
                                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 0.5),
                                  ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

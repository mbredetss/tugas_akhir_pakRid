import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'file_attachment_handler.dart';
import 'file_uploader.dart';
import 'task_manager.dart';

class TaskInstructionScreen extends StatefulWidget {
  final String courseName;
  final String taskTitle;
  final String? dueDate; // Dapat bernilai null
  final String dueTime;
  final String? submissionDate; // Dapat bernilai null
  final String instructions;
  final bool isComplete;
  final String taskId;
  final Function(String taskTitle)? onTaskCompleted;

  TaskInstructionScreen({
    required this.courseName,
    required this.taskTitle,
    this.dueDate,
    required this.dueTime,
    this.submissionDate,
    required this.instructions,
    required this.isComplete,
    required this.taskId,
    this.onTaskCompleted,
  });

  @override
  _TaskInstructionScreenState createState() => _TaskInstructionScreenState();
}

class _TaskInstructionScreenState extends State<TaskInstructionScreen> {
  FileAttachmentHandler fileHandler = FileAttachmentHandler();
  FileUploader fileUploader = FileUploader();
  bool showSubmitButton = false;
  double uploadProgress = 0.0;

  void handleFileSelected(bool showSubmit) {
    setState(() {
      showSubmitButton = showSubmit;
    });
  }

  void handleUploadProgress(double progress) {
    setState(() {
      uploadProgress = progress;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isLateSubmission = widget.submissionDate != null &&
        widget.dueDate != null &&
        DateFormat("dd/MM/yyyy HH:mm").parse(widget.submissionDate!).isAfter(
          DateFormat("dd/MM/yyyy HH:mm").parse(
            '${widget.dueDate!} ${widget.dueTime}',
          ),
        );

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.courseName),
      ),
      body: Stack(
        children: [
          Padding(
            padding: EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (widget.isComplete && isLateSubmission)
                  TaskManager.buildLateSubmissionWidget(widget.submissionDate, widget.dueDate),
                if (widget.isComplete && !isLateSubmission)
                  TaskManager.buildCompletionWidget(widget.submissionDate),
                SizedBox(height: 16),
                Text(widget.taskTitle, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                SizedBox(height: 8),
                Text('Jatuh tempo ${widget.dueDate} ${widget.dueTime}', style: TextStyle(color: Colors.grey[600])),
                SizedBox(height: 16),
                Text('Instruksi', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                SizedBox(height: 8),
                Text(widget.instructions),
                Spacer(),
                if (fileHandler.selectedFile != null)
                  fileHandler.buildFileWidget(
                    onDelete: () {
                      fileHandler.clearSelectedFile();
                      handleFileSelected(false);
                    },
                  ),
                SizedBox(height: 16),
                if (!widget.isComplete && fileHandler.selectedFile == null)
                  ElevatedButton.icon(
                    icon: Icon(Icons.attach_file),
                    label: Text('Lampirkan'),
                    onPressed: () async {
                      await fileHandler.openFileExplorer();
                      handleFileSelected(fileHandler.selectedFile != null);
                    },
                  ),
                if (showSubmitButton)
                  ElevatedButton(
                    onPressed: () async {
                      if (fileHandler.selectedFile != null) {
                        await fileUploader.uploadFile(
                          fileHandler.selectedFile!,
                          widget.courseName,
                          widget.taskTitle,
                          onProgress: handleUploadProgress,
                          onComplete: () {
                            TaskManager.moveToCompletedTab(
                              widget.courseName,
                              widget.taskTitle,
                              widget.onTaskCompleted,
                            );
                          },
                        );
                        handleFileSelected(false);
                      }
                    },
                    child: Text('Kumpulkan'),
                  ),
              ],
            ),
          ),
          if (fileUploader.isUploading)
            fileUploader.buildUploadProgressIndicator(uploadProgress),
        ],
      ),
    );
  }
}

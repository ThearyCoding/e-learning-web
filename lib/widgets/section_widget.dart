
import 'package:e_learningapp_admin/widgets/lecture_widget.dart';
import 'package:flutter/material.dart';

import '../models/lecture_model.dart';
import '../models/section_model.dart';

class SectionWidget extends StatefulWidget {
  final Section section;
  final VoidCallback onAddLecture;
  final VoidCallback onRemoveSection;
  final ValueChanged<String> onEditSectionTitle;
  final ValueChanged<String> onEditLearningObjective;
  final ValueChanged<int> onRemoveLecture;
  final Function(int, Lecture) onEditLecture;
  final int index;

  const SectionWidget({
    super.key,
    required this.section,
    required this.onAddLecture,
    required this.onRemoveSection,
    required this.onEditSectionTitle,
    required this.onEditLearningObjective,
    required this.onRemoveLecture,
    required this.onEditLecture,
    required this.index,
  });

  @override
  SectionWidgetState createState() => SectionWidgetState();
}

class SectionWidgetState extends State<SectionWidget> {
  TextEditingController txttitle = TextEditingController();
  final TextEditingController txtlearningObjective = TextEditingController();
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    txttitle.text = widget.section.title;
    txtlearningObjective.text = widget.section.learningObjective;
  }

  void _toggleEditSection() {
    setState(() {
      _isEditing = !_isEditing;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (_isEditing)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              maxLines: 1,
                              'Section ${widget.index + 1}: ',style: const TextStyle(
                              overflow: TextOverflow.ellipsis,
                              
                            )),
                            const SizedBox(
                              height: 10,
                            ),
                            TextField(
                              controller: txttitle,
                              decoration: InputDecoration(
                                hintText: 'Section Title',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  gapPadding: 1,
                                ),
                              ),
                              onSubmitted: (value) {
                                widget.onEditSectionTitle(value);
                                _toggleEditSection();
                              },
                            ),
                            const SizedBox(height: 8.0),
                            TextField(
                              controller: txtlearningObjective,
                              decoration: InputDecoration(
                                hintText: 'Enter a Learning Objective',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  gapPadding: 1,
                                ),
                              ),
                              onSubmitted: (value) {
                                widget.onEditLearningObjective(value);
                                _toggleEditSection();
                              },
                            ),
                            const SizedBox(height: 8.0),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                TextButton(
                                  onPressed: _toggleEditSection,
                                  child: const Text('Cancel'),
                                ),
                                const SizedBox(width: 8.0),
                                ElevatedButton(
                                  onPressed: () {
                                    widget.onEditSectionTitle(txttitle.text);
                                    widget.onEditLearningObjective(
                                        txtlearningObjective.text);
                                    _toggleEditSection();
                                  },
                                  child: const Text('Save Section'),
                                ),
                              ],
                            ),
                          ],
                        )
                      else
                        Row(
                          children: [
                            Text(
                              'Section ${widget.index + 1}: ${widget.section.title}',
                              style: const TextStyle(
                                  fontSize: 14, fontWeight: FontWeight.w500),
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                            const Spacer(),
                            const SizedBox(
                              height: 10,
                            ),
                            IconButton(
                              icon: const Icon(Icons.edit),
                              onPressed: _toggleEditSection,
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete),
                              onPressed: widget.onRemoveSection,
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8.0),
            ...widget.section.lectures.asMap().entries.map((entry) {
              int index = entry.key;
              Lecture lecture = entry.value;
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 50),
                child: LectureWidget(
                  lecture: lecture,
                  onRemove: () => widget.onRemoveLecture(index),
                  onEdit: (updatedLecture) =>
                      widget.onEditLecture(index, updatedLecture),
                ),
              );
            }).toList(),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 50),
              child: ElevatedButton.icon(
                onPressed: () {
                  widget.onAddLecture();
                },
                icon: const Icon(Icons.add),
                label: const Text("Curriculum item"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

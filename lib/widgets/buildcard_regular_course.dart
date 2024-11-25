import 'package:e_learningapp_admin/export/export.dart';

class BuildCardRegularAdmin extends StatelessWidget {
  const BuildCardRegularAdmin({
    super.key,
    required this.courseModel,
  });

  final CourseModel courseModel;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        //showDialogTopicByCourseCategory(context, courseModel);
      },
      child: Container(
        width: 400,
        height: 400,
        padding: const EdgeInsets.all(25),
        decoration: const BoxDecoration(
          color: Colors.white,
        ),
        child: SizedBox(
          width: 350,
          height: 350,
          child: Column(
            children: [
              Expanded(
                child: Image.network(
                  courseModel.imageUrl,
                  fit: BoxFit.contain,
                  height: 150,
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Flexible(
                    child: Text(
                      courseModel.title,
                      style: const TextStyle(
                        fontSize: 16,
                        overflow: TextOverflow.clip,
                      ),
                      maxLines: 2,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

}

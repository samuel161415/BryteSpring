import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:mobile/features/verse_join/presentation/components/top_part_widget.dart';

class GetToKnowRoleWidget extends StatefulWidget {
  const GetToKnowRoleWidget({super.key});

  @override
  State<GetToKnowRoleWidget> createState() => _GetToKnowRoleWidgetState();
}

class _GetToKnowRoleWidgetState extends State<GetToKnowRoleWidget> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(8.0),
      child: Container(
        height: 600,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
          padding: EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              TopHeader(),

              SizedBox(height: 24),
              Text(
                'join_verse.greeting_name'.tr(),
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900),
              ),
              SizedBox(height: 36),

              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [Icon(Icons.close)],
              ),
              SizedBox(height: 24),
              Text(
                'join_verse.role.title'.tr(),
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
              ),
              SizedBox(height: 12),
              Text(
                'join_verse.role.intro'.tr(),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 16),
              _ChecklistItem(text: 'join_verse.role.bullet_1'.tr()),
              _ChecklistItem(text: 'join_verse.role.bullet_2'.tr()),
              _ChecklistItem(text: 'join_verse.role.bullet_3'.tr()),
              _ChecklistItem(text: 'join_verse.role.bullet_4'.tr()),
              const SizedBox(height: 12),
              Text(
                'join_verse.role.hint'.tr(),
                style: TextStyle(fontSize: 12, color: Colors.black87),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              Container(
                width: 230,
                height: 40,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.black, width: 4),
                ),
                child: Center(child: Text('join_verse.role.cta'.tr())),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ChecklistItem extends StatelessWidget {
  final String text;
  const _ChecklistItem({required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          const Icon(Icons.check, color: Color(0xFF3EC1B7), size: 18),
          const SizedBox(width: 8),
          Expanded(child: Text(text)),
        ],
      ),
    );
  }
}

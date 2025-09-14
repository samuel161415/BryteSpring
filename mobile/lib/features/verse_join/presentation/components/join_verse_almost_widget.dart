import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile/core/routing/routeLists.dart';
import 'package:mobile/features/verse_join/presentation/components/top_part_widget.dart';

class JoinVerseAlmostComponent extends StatefulWidget {
  const JoinVerseAlmostComponent({super.key});

  @override
  State<JoinVerseAlmostComponent> createState() =>
      _JoinVerseAlmostComponentState();
}

class _JoinVerseAlmostComponentState extends State<JoinVerseAlmostComponent> {
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
                'join_verse.almost_done_title'.tr(),
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700),
              ),
              SizedBox(height: 16),
              Text(
                'join_verse.almost_done_desc'.tr(),
                textAlign: TextAlign.center,
                style: TextStyle(),
              ),
              SizedBox(height: 36),
              GestureDetector(
                onTap: () {
                  context.pushNamed(Routelists.joinVerse);
                },
                child: Container(
                  width: 200,
                  height: 40,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.black, width: 4),
                  ),
                  child: Center(
                    child: Text('join_verse.create_verse_button'.tr()),
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

import 'package:flutter/material.dart';

import 'main.dart';

runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => MemoService()),
      ],
      child: const MyApp(),
    ),
  );
class Memo {
  Memo({
    required this.content,
  });

  String content;
}

// Memo 데이터는 모두 여기서 관리
class MemoService extends ChangeNotifier {
  List<Memo> memoList = [
    Memo(content: '장보기 목록: 사과, 양파'), // 더미(dummy) 데이터
    Memo(content: '새 메모'), // 더미(dummy) 데이터
  ];
}

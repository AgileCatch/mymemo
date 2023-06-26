import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

import 'memo_service.dart';

late SharedPreferences prefs;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  prefs = await SharedPreferences.getInstance();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => MemoService()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: HomePage(),
    );
  }
}

// 홈 페이지
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Consumer<MemoService>(
      builder: (context, memoService, child) {
        // memoService로 부터 memoList 가져오기
        List<Memo> memoList = memoService.memoList;

        // 위쪽에 고정된 메모와 고정되지 않은 메모를 분리하여 처리
        List<Memo> pinnedMemos =
            memoList.where((memo) => memo.isPinned).toList();
        List<Memo> unpinnedMemos =
            memoList.where((memo) => !memo.isPinned).toList();

        // 위쪽에 고정된 메모를 우선적으로 보여주기 위해 합침
        List<Memo> sortedMemos = [...pinnedMemos, ...unpinnedMemos];

        return Scaffold(
          appBar: AppBar(
            title: Text("mymemo"),
          ),
          body: memoList.isEmpty
              ? Center(child: Text("메모를 작성해 주세요"))
              : ListView.builder(
                  itemCount: sortedMemos.length, // memoList 개수 만큼 보여주기 수정됨
                  itemBuilder: (context, index) {
                    Memo memo = sortedMemos[index]; // index에 해당하는 memo 가져오기
                    return ListTile(
                      // 메모 고정 아이콘,클릭시
                      leading: IconButton(
                        icon: Icon(
                          memo.isPinned
                              ? CupertinoIcons.pin_fill
                              : CupertinoIcons.pin,
                        ),
                        onPressed: () {
                          setState(() {
                            memo.isPinned = !memo.isPinned;

                            if (memo.isPinned) {
                              sortedMemos.removeAt(index);
                              sortedMemos.insert(0, memo);
                            } else {
                              sortedMemos.removeAt(index);
                              sortedMemos.add(memo);
                            }
                          });
                          print('$memo : pin 클릭 됨');
                        },
                      ),
                      // 메모 내용 (최대 3줄까지만 보여주도록)
                      title: Row(
                        mainAxisAlignment: MainAxisAlignment
                            .spaceBetween, // 시간과 날짜를 오른쪽으로 정렬하기 위해 사용
                        children: [
                          Text(
                            memo.content,
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            // 시간추가
                            DateFormat('yyyy-MM-dd HH:mm').format(memo.time),
                          ),
                        ],
                      ),
                      onTap: () {
                        // 아이템 클릭시
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => DetailPage(
                              index: index,
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
          floatingActionButton: FloatingActionButton(
            child: Icon(Icons.add),
            onPressed: () {
              // + 버튼 클릭시 메모 생성 및 수정 페이지로 이동
              memoService.createMemo(content: '');
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => DetailPage(
                    index: memoService.memoList.length - 1,
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}

// 메모 생성 및 수정 페이지
class DetailPage extends StatelessWidget {
  DetailPage({super.key, required this.index});

  final int index;

  TextEditingController contentController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    MemoService memoService = context.read<MemoService>();
    Memo memo = memoService.memoList[index];

    contentController.text = memo.content;

    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            onPressed: () {
              // 삭제 버튼 클릭시

              showDeleteDialog(context, memoService);
            },
            icon: Icon(Icons.delete),
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: TextField(
          controller: contentController,
          decoration: InputDecoration(
            hintText: "메모를 입력하세요",
            border: InputBorder.none,
          ),
          autofocus: true,
          maxLines: null,
          expands: true,
          keyboardType: TextInputType.multiline,
          onChanged: (value) {
            // 텍스트필드 안의 값이 변할 때
            memoService.updateMemo(index: index, content: value);
          },
        ),
      ),
    );
  }

  void showDeleteDialog(BuildContext context, MemoService memoService) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          actions: [
            // 취소 버튼
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text("취소"),
            ),
            // 확인 버튼
            TextButton(
              onPressed: () {
                memoService.deleteMemo(index: index);
                Navigator.pop(context); // 팝업 닫기
                Navigator.pop(context); // HomePage 로 가기
              },
              child: Text(
                "확인",
                style: TextStyle(color: Colors.pink),
              ),
            ),
          ],
          title: Text("정말로 삭제하시겠습니까?"),
        );
      },
    );
  }
}

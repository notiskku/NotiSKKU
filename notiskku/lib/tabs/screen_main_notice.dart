import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:notiskku/tabs/screen_main_search.dart';
import 'package:notiskku/widget/bar/bar_categories.dart';
import 'package:notiskku/widget/bar/bar_notices.dart';
import 'package:notiskku/google/google_sheets_api.dart';

class ScreenMainNotice extends StatefulWidget {
  const ScreenMainNotice({Key? key}) : super(key: key);

  @override
  _ScreenMainNoticeState createState() => _ScreenMainNoticeState();
}

class _ScreenMainNoticeState extends State<ScreenMainNotice> {
  List<Map<String, String>> sheetData = [];
  int currentRow = 1;
  bool isLoading = false;
  bool hasMoreData = true;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _loadSheetData();
    _scrollController.addListener(_scrollListener);
  }

  void _scrollListener() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 100) {
      _loadSheetData();
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadSheetData() async {
    if (isLoading || !hasMoreData) return;
    setState(() => isLoading = true);

    final data = await GoogleSheetsAPI.readData(startRow: currentRow, limit: 10);

    if (data.isEmpty) {
      setState(() {
        hasMoreData = false; 
      });
    } else {
      List<Map<String, String>> parsedData = data.map((row) {
        return {
          "id": row.isNotEmpty ? row[0] : "",
          "category": row.length > 1 ? row[1] : "",
          "title": row.length > 2 ? row[2] : "",
          "date": row.length > 3 ? row[3] : "",
          "uploader": row.length > 4 ? row[4] : "",
          "views": row.length > 5 ? row[5] : "",
          "link": row.length > 6 ? row[6] : "",
        };
      }).toList();

      setState(() {
        sheetData.addAll(parsedData);
        currentRow += 10;
      });
    }

    setState(() => isLoading = false);
  }

  void _launchURL(String url) async {
    final Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      bool launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (launched) {
        print("URL Opened: $url");
      } else {
        print("CANNOT OPEN ERROR: $url");
      }
    } else {
      print("INVALID ERROR: $url");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const _NoticeAppBar(),
      backgroundColor: Colors.white,
      body: Column(
        children: [
          BarNotices(),
          SizedBox(height: 6.h),
          BarCategories(),
          SizedBox(height: 10.h),
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              itemCount: sheetData.length + (hasMoreData ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == sheetData.length) {
                  return Center(child: CircularProgressIndicator()); 
                }

                final notice = sheetData[index];
                return ListTile(
                  title: Text(
                    "${notice['id']} | ${notice['category']} | ${notice['title']} | ${notice['date']} | ${notice['uploader']} | ${notice['views']}",
                    style: TextStyle(color: Colors.black),
                  ),
                  onTap: () {
                    if (Uri.parse(notice['link'] ?? "").isAbsolute) {
                      _launchURL(notice['link']!);
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('잘못된 URL 형식: ${notice['link']}')),
                      );
                    }
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _NoticeAppBar extends StatelessWidget implements PreferredSizeWidget {
  const _NoticeAppBar({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      scrolledUnderElevation: 0,
      leading: Padding(
        padding: EdgeInsets.all(10.0),
        child: Image.asset('assets/images/greenlogo_fix.png', width: 40),
      ),
      title: Text(
        "공지사항",
        style: TextStyle(
          fontSize: 18.sp,
          fontWeight: FontWeight.bold,
          color: Colors.black,
        ),
        overflow: TextOverflow.ellipsis,
      ),
      actions: [
        Padding(
          padding: EdgeInsets.all(15.0),
          child: GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ScreenMainSearch(),
                ),
              );
            },
            child: Image.asset('assets/images/search_fix.png', width: 30),
          ),
        ),
      ],
      centerTitle: true,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
import 'package:flutter/material.dart';
import 'package:notiskku_demo/data/keyword_data.dart';
import 'package:notiskku_demo/models/keyword.dart';
import 'package:notiskku_demo/services/preference_services.dart';
import 'package:notiskku_demo/widgets/do_not_select.dart';

class KeywordsGrid extends StatefulWidget {
  const KeywordsGrid({
    super.key,
    required this.selectedKeyword,
    required this.onselectedKeywordChanged,
  });

  final List<String> selectedKeyword;
  final Function(List<String>) onselectedKeywordChanged;

  @override
  State<StatefulWidget> createState() {
    return _KeywordsGridState();
  }
}

class _KeywordsGridState extends State<KeywordsGrid> {
  List<String> selectedKeywords = [];
  bool _isDoNotSelect = false; // Track "Do Not Select" state

  @override
  void initState() {
    super.initState();
    loadSelectedKeywords(); // 초기화 시 선택된 키워드 불러오기
  }

  // 저장된 키워드 목록 불러오는 메서드
  Future<void> loadSelectedKeywords() async {
    List<String>? loadedKeywords = await getSelectedKeywords();
    if (loadedKeywords != null) {
      setState(() {
        selectedKeywords = loadedKeywords; // 불러온 키워드 목록으로 초기화
        widget.onselectedKeywordChanged(selectedKeywords);
      });
    }
  }

  // 선택된 키워드를 저장하는 메서드
  Future<void> saveSelectedKeywordsToPrefs() async {
    await saveSelectedKeywords(selectedKeywords);
  }

  void _selectKeyword(BuildContext context, Keyword keyword) {
    setState(() {
      if (selectedKeywords.contains(keyword.keyword)) {
        selectedKeywords.remove(keyword.keyword); // 선택된 버튼 해제
      } else {
        selectedKeywords.add(keyword.keyword); // 버튼 선택
      }
      // Reset "Do Not Select" state if a keyword is chosen
      _isDoNotSelect = false;


      widget.onselectedKeywordChanged(selectedKeywords);
      saveSelectedKeywordsToPrefs();
    });
  }

  // Callback to handle "Do Not Select" button press
  void _toggleDoNotSelect() {
    setState(() {
      _isDoNotSelect = !_isDoNotSelect;
      if (_isDoNotSelect) {
        selectedKeywords.clear(); // Clear any selected keywords
        selectedKeywords.add('없음');
      }
      widget.onselectedKeywordChanged(selectedKeywords);
      saveSelectedKeywordsToPrefs();
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width; // 화면 너비 가져오기
    final buttonWidth = (screenWidth - 80) / 3; // 버튼 너비 조정 (여백을 고려하여 3개로 나누기)

    // 비율 86:37로 버튼 높이 계산
    final buttonHeight = buttonWidth * (37 / 86);

    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          DoNotSelect(
            onPressed: _toggleDoNotSelect, // Pass toggle callback
            isSelected: _isDoNotSelect, // Reflect selection state
          ),
          const SizedBox(height: 10), 
          Expanded(
            child: GridView.builder(
              padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.075), // 좌우 7.5% 여백 설정
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                childAspectRatio: (buttonWidth / buttonHeight),
                crossAxisSpacing: 19,
                mainAxisSpacing: 30,
              ),
              itemCount: keywords.length,
              itemBuilder: (context, index) {
                final keywordObj = keywords[index];
                bool isSelected = selectedKeywords.contains(keywordObj.keyword);
                return GestureDetector(
                  onTap: () => _selectKeyword(context, keywordObj),
                  child: Container(
                    width: buttonWidth, // 동적 버튼 너비
                    height: buttonHeight, // 동적 버튼 높이
                    padding: const EdgeInsets.all(10), // 버튼 안쪽 여백
                    decoration: BoxDecoration(
                      color: isSelected ? const Color(0xB20B5B42) : const Color(0x99D9D9D9),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Center(
                      child: Text(
                        keywordObj.keyword,
                        style: TextStyle(
                          fontSize: buttonWidth * 0.16, // 버튼 너비에 따라 텍스트 크기 조정
                          color: isSelected ? const Color(0xFFFFFFFF) : const Color(0xFF979797),
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
